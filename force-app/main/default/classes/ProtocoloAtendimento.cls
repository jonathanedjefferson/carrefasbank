public with sharing class ProtocoloAtendimento {
    public static ProtocoloAtendimento.ConsultaAPI protocoloAtendimento(String cpf,  String unidadeNegocio, String canal) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarProtocolos');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{cpf}', cpf), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            null, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar protocolo de atendimento', 
            config.Endpoint__c + config.Path__c.replace('{cpf}', cpf), 
            config.Method__c, 
            null, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio
        );

        ProtocoloAtendimento.ConsultaAPI retorno = new ProtocoloAtendimento.ConsultaAPI();

        if(objHttpResponse.getStatusCode() == 200 || objHttpResponse.getStatusCode() == 204){
            retorno = (ProtocoloAtendimento.ConsultaAPI) JSON.deserialize(objHttpResponse.getBody(), ProtocoloAtendimento.ConsultaAPI.class);
            retorno.descricao = 'OK';
        }else{
            retorno.descricao = 'ERRO';
        }
        
        return retorno;
    }

    public class ConsultaAPI {
        public Exchange exchange;
        public String Status;
        public String Message;
        public String Code;
        public String descricao;
        public ConsultaAPI(){
            exchange = new Exchange();
        }
    }

    public class Exchange {
        public List<Protocolos> protocolos;
        public String QuantidadeProtocolo;
        public Exchange(){
            protocolos = new List<Protocolos>();
        }
    }

    public class Protocolos {
        public String Assunto;
        public String EventoPadrao;
        public String IndicadorDentroPrazo;
        public String IndicadorOuvidoria;
        public String NumeroProtocolo;
        public String Unidade;
    }
}