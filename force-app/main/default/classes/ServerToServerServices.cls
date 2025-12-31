public class ServerToServerServices {
    @invocableMethod(label='Get Token ServerToServer')
    public static list<ResponseToken> GetTokenServerToServer(List<Input> inputs){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ServerToServerServices');

        // SETANDO VARIÁVEIS PARA INTEGRAÇÃO
        String endpoint = config.Endpoint__c;
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        // HttpResponse objHttpResponse = executarHttpRequest(
        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Server To Server', 
            endpoint, 
            metodo, 
            body, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            inputs[0].canal.capitalize()
        );        
        System.debug('body '+objHttpResponse.getBody());
        List<ResponseToken> lstRetorno = new List<ResponseToken>();
        lstRetorno.add(ResponseBodyToResponseToken(objHttpResponse.getBody()));
        System.debug('body '+lstRetorno);
        return lstRetorno;
    }

    public class Input{
        @InvocableVariable
        public String canal;
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
        public Integer not_before_policy;// in json: not-before-policy
        @InvocableVariable
        public String session_state;
        @InvocableVariable
        public String scope;
    }

    public static ResponseToken ResponseBodyToResponseToken (String objHttpResponse) {
        return (ResponseToken)Json.deserialize(objHttpResponse, ResponseToken.class);
    }
}