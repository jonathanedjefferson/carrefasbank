public with sharing class StatusDePagamentoCallout {
    
public static RetornoAPI buscarStatusDePagamento(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterStatusPagamento');
        List<ServerToServerCSFServicos.Input> listInputToken = new List<ServerToServerCSFServicos.Input>();
        ServerToServerCSFServicos.Input inputToken = new ServerToServerCSFServicos.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        RetornoAPI  response;

        String endpoint =  config.Endpoint__c + config.Path__c;
        String body =  config.Body__c.replace('{numeroConta}', numeroConta);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerCSFServicos.GetTokenServerToServerCSFServicos(listInputToken).get(0).access_token,
                'cpf' => cpfCliente,
                'x-uat' => config.UAT__c
            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Status de Pagamento', 
            endpoint, 
            config.Method__c, 
            body, 
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );  

        if(objHttpResponse.getStatusCode() == 200){
            response = (RetornoAPI) JSON.deserialize(objHttpResponse.getBody(), RetornoAPI.class);
        }

        return response;
    }

    public class RetornoAPI{
        String numeroConta;
        List<Fatura> faturas;
    }

    public class Fatura{
        Boolean ultimaFechada;
        Valor valorDescontos;
        Boolean habilitaBotaoPagamento;
        Boolean principal;
        Valor saldo;
        Datetime dataVencimento;
        Integer idFatura;
        String tipoFatura;
        Integer idTipoFatura;
        Integer melhorDiaCompra;
        List<String> faturasAnteriores;
        Datetime dataFechamento;
        Valor valorFatura;
        Valor valorMinimo;
        Valor totalEmAberto;
        Valor valorPago;
        Valor totalDescontosUltimoAno;
        Valor pagamentosEfetuadosCreditos;
        Valor lancamentosAtuaisDebitos;
        Valor totalJurosRotativoRemuneratorio;
        Valor limiteTotal;
        Valor limiteDisponivel;
    }

    public class Valor{
        Double valor;
        String moeda;
    }

}