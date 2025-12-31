public with sharing class ConsultarCreditoPessoal {
    public static ConsultaAPI consultarCreditoPessoal(String numeroConta, String cpf, String unidadeNegocio, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarCreditoPessoal');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' =>  config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{conta}', numeroConta).replace('{cpf}', cpf).replace('{negocio}', unidadeNegocio), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar crédito Pessoal', 
            config.Endpoint__c,
            config.Method__c, 
            config.Body__c.replace('{conta}', numeroConta).replace('{cpf}', cpf).replace('{negocio}', unidadeNegocio), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio
        );

        ConsultaAPI retorno;
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (ConsultaAPI) System.JSON.deserialize(objHttpResponse.getBody(), ConsultaAPI.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.resultado.descricao = retorno.saldoDisponivel >= 400 ? 'ELEGIVEL SEM CP' : 'ELEGIVEL COM CP';
        }else if( retorno.resultado.descricao == 'Não possui saldo pré aprovado.'){
            retorno.resultado.descricao = 'NAO ELEGIVEL';
        }else{
            retorno.resultado.descricao = 'ERRO';
        }
        return retorno;
    }

    public class ConsultaAPI {
        public Resultado resultado;
        public Decimal saldoDisponivel;
    }
    public class Resultado {
        public String descricao;
        public Boolean sucesso;
    }
}