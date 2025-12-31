public class ServerToServerCashback {

    public static ResponseToken GetTokenServerToServer(String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ServerToServerCashback');
        String endpoint = config.Endpoint__c + config.Path__c;
        String body = config.Body__c.replace('{cpf}', cpf);
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
            
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Token Cashback', 
            endpoint, 
            metodo, 
            body, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );   

        return ResponseBodyToResponseToken(objHttpResponse.getBody());
    }
    
    public class Input{
        @InvocableVariable
        public String canal;
        @InvocableVariable
        public String cpf;
    }

    public class ResponseToken {
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public Integer expiresIn;
        @InvocableVariable
        public Integer refreshExpiresIn;
        @InvocableVariable
        public String tokenType;
        @InvocableVariable
        public String scope;
        @InvocableVariable
        public String accountId;
    }

    public static ResponseToken ResponseBodyToResponseToken (String objHttpResponse) {
        return (ResponseToken)Json.deserialize(objHttpResponse, ResponseToken.class);
    }
}