public class MelhorDiaCompraCockpit {
    public static String getMelhorDiaCompra(String numeroConta, String cpf, String unidade, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('MelhorDiaCompra');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String retorno = 'ERROR';
        // SETANDO VARIÁVEIS PARA INTEGRAÇÃO
        String endpoint = config.Endpoint__c.replace('{numeroConta}', numeroConta);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'cpf' => cpf,
            'Authorization' => 'Bearer ' + ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
            'idEmpresa' => unidade,
            'x-uat' => config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        if (objHttpResponse.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(objHttpResponse.getBody());
            if (jsonResponse.containsKey('melhorDiaCompra')) {
                retorno = String.valueOf(jsonResponse.get('melhorDiaCompra'));
            } 
        }

        LogIntegracaoBO.InsertLog(
            'Melhor dia de Compra Cockpit', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidade,
            canal.capitalize()
        );

        return retorno;
    }
    public static ResponseAPI getDataULtimaFatura(String numeroConta, String unidade, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterResumoUltimaFaturaFechada');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        ResponseAPI retorno;

        // SETANDO VARIÁVEIS PARA INTEGRAÇÃO
        String endpoint = config.Endpoint__c + config.path__c.replace('{numeroConta}', numeroConta);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'cpf' => cpf,
            'Authorization' => 'Bearer ' + ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
            'idEmpresa' => unidade,
            'x-uat' => config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        if (objHttpResponse.getStatusCode() == 200) {
            retorno = (ResponseAPI) System.JSON.deserialize(objHttpResponse.getBody(), ResponseAPI.class);
        }

        LogIntegracaoBO.InsertLog(
            'Resumo última da fatura fechada Cockpit', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidade,
            canal.capitalize()
        );

        return retorno;
    }

    public class Valor {
        @AuraEnabled
        public Decimal valor;
        @AuraEnabled
        public String moeda;
    }
    
    public class ResponseAPI {
        @AuraEnabled
        public String dataVencimento;
        @AuraEnabled
        public Valor valorFatura;
        @AuraEnabled
        public Valor pagameValortoMinimo;
        @AuraEnabled
        public Valor creditos;
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String codigoBarras;
    }

}