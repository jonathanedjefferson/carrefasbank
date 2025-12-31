public with sharing class CadastrarUsuarioHSM {
    public static CadastrarUsuarioHSMTO.resposneWrapper makeAPIRequest(String phone, String name, String acronymLoja) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('CadastrarUsuarioHSM');
        String apiUrl = config.endpoint__c;
        String calloutMethod = config.method__c;
        
        if(name == null) {
            name = '';
        }

        //Caso o telefone tenha menos que 13 caracteres, adiciona um 9 após o ddd.
        if (phone.length() < 13) {
            if (phone.length() >= 2) {
                String firstTwoDigits = phone.substring(0, 4);
                String remainingDigits = phone.substring(4);
                phone = firstTwoDigits + '9' + remainingDigits;
            }
        }

        String apiToken;
        if (Test.isRunningTest()) {
            apiToken = 'teste';
        } else {
            apiToken = GerarTokenAutenticacao.makeAPIRequest().token;
        }
        
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        CadastrarUsuarioHSMTO calloutData = new CadastrarUsuarioHSMTO();
        calloutData.phone = phone;
        calloutData.name = name;
        calloutData.acronymLoja = acronymLoja;
        
        String body = JSON.serialize(calloutData);        
        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', apiToken);
        request.setBody(body);

        HttpResponse response = http.send(request);
        CadastrarUsuarioHSMTO.resposneWrapper responseBody = new CadastrarUsuarioHSMTO.resposneWrapper();
        LogIntegracaoBO.InsertLog('Cadastrar usuário HSM', apiUrl, calloutMethod, body, 'vazio', String.valueOf(responseBody.statusCode), response.getBody(), 'CRF');

        try {
            responseBody = (CadastrarUsuarioHSMTO.resposneWrapper) Json.deserialize(response.getBody(), CadastrarUsuarioHSMTO.resposneWrapper.class);
            responseBody.statusCode = response.getStatusCode();
        } catch (Exception e) {
            responseBody = new CadastrarUsuarioHSMTO.resposneWrapper();
            responseBody.statusCode = 999;
        }


        return responseBody;
    }
}