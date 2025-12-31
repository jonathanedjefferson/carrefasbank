public  class TokenAntecipacao {

    public static ResponseToken obterToken(String canal, String cpf, String cpfDrtOperador, String perfilOperador){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenAntecipacao');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'cpf' => cpf,
                'operador' => cpfDrtOperador,
                'perfilOperador' => perfilOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token Antecipação', 
            config.Endpoint__c, 
            config.Method__c, 
            config.Body__c, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );        
        
        return ResponseBodyToResponseToken(objHttpResponse.getBody());
    }

    public class Input{
        public String canal;
    }

    public class ResponseToken {
        public String access_token;
        public Integer expires_in;
        public Integer refresh_expires_in;
        public String token_type;
        public Integer not_before_policy;// in json: not-before-policy
        public String scope;
    }

    public static ResponseToken ResponseBodyToResponseToken (String objHttpResponse) {
        return (ResponseToken)Json.deserialize(objHttpResponse, ResponseToken.class);
    }
}