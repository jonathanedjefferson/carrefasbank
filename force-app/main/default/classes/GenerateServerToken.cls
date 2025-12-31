public class GenerateServerToken {

    public static ResponseToken GetToken(String metadataLabel, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel(metadataLabel);

        String uat = config.UAT__c != null ? config.UAT__c : '';
        ResponseToken token = null;
        if(config != null){
            String endpoint = config.Endpoint__c;
            String body = config.Body__c;
            String metodo = config.Method__c;
            Integer timeout = Integer.valueof(config.Timeout__c);
            Map<String, String> header = new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'x-uat' => uat
            };

            HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);
            LogIntegracaoBO.InsertLog(
                'Token ' + metadataLabel, 
                endpoint, 
                metodo, 
                body, 
                null, 
                String.valueOf(objHttpResponse.getStatusCode()), 
                objHttpResponse.getBody(),
                null,
                canal
            );        

            token = (ResponseToken) System.JSON.deserialize(objHttpResponse.getBody(), ResponseToken.class);    
        } 

        return token;
    }

    public class ResponseToken {
        @InvocableVariable
        public String access_token;
        @InvocableVariable
        public Integer expires_in;
        @InvocableVariable
        public Integer refresh_expires_in;
        @InvocableVariable
        public String refresh_token;
        @InvocableVariable
        public String token_type;
        @InvocableVariable
        public Integer not_before_policy;
        @InvocableVariable
        public String session_state;
        @InvocableVariable
        public String scope;
    }


}