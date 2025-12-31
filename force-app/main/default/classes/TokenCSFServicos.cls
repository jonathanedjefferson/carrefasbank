public class TokenCSFServicos {
    public static ResponseToken GetToken(String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenCSFServicos');

        String uat = config.UAT__c != null ? config.UAT__c : '';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',  
                'x-uat' => uat
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token CSF Serviços', 
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

    public static ResponseToken GetTokenV2(String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenCSFServicosV2');

        String uat = config.UAT__c != null ? config.UAT__c : '';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'x-uat' => uat
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token CSF Serviços V2', 
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

    public static ResponseToken getTokenByCPF(String canal, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenCSFServicosCPF');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',  
                'x-uat' => config.UAT__c != null ? config.UAT__c : ''
            }, 
            config.Body__c.replace('{cpfCliente}', cpf), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token CSF Serviços CPF', 
            config.Endpoint__c, 
            config.Method__c, 
            config.Body__c.replace('{cpfCliente}', cpf), 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );        
        
        return ResponseBodyToResponseToken(objHttpResponse.getBody());
    }

    public static ResponseToken GetTokenAquisicao(String canal, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenCSFServicosAquisicao');
        String body = config.Body__c.replace('{cpf}', cpf);

        String uat = config.UAT__c != null ? config.UAT__c : '';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'x-uat' => uat
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token CSF Serviços Aquisicao', 
            config.Endpoint__c, 
            config.Method__c, 
            body, 
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );        
        
        return ResponseBodyToResponseToken(objHttpResponse.getBody());
    }

    public static ResponseToken GetTokenContaDigital(String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenCSFServicosContaDigital');
        String uat = config.UAT__c != null ? config.UAT__c : '';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',  
                'x-uat' => uat
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token CSF Serviços ContaDigital', 
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

    public static ResponseToken getTokenSmsControleTotal(String canal, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenCSFServicosSMSControle');
        String body = config.Body__c.replace('{cpf}', cpf);

        String uat = config.UAT__c != null ? config.UAT__c : '';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'x-uat' => uat
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token CSF Serviços SMS Controle Total', 
            config.Endpoint__c, 
            config.Method__c, 
            body, 
            cpf,
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