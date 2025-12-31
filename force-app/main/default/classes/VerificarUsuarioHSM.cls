public with sharing class VerificarUsuarioHSM {
    public static VerificarUsuarioHSMTO.resposneWrapper makeAPIRequest(String phone) {
        //Caso o telefone tenha menos que 13 caracteres, adiciona um 9 após o ddd.
        if (phone.length() < 13) {
            if (phone.length() >= 2) {
                String firstTwoDigits = phone.substring(0, 4);
                String remainingDigits = phone.substring(4);
                phone = firstTwoDigits + '9' + remainingDigits;
            }
        }

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('VerificarUsuarioHSM');
        String apiUrl = config.endpoint__c + '?phone=' + phone;
        String calloutMethod = config.method__c;

        String apiToken;
        if (Test.isRunningTest()) {
            apiToken = 'teste';
        } else {
            apiToken = GerarTokenAutenticacao.makeAPIRequest().token;
        }
        
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', apiToken);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Verificar usuário HSM', apiUrl, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        VerificarUsuarioHSMTO.resposneWrapper responseBody = new VerificarUsuarioHSMTO.resposneWrapper();
        try {
            responseBody = (VerificarUsuarioHSMTO.resposneWrapper) Json.deserialize(response.getBody(), VerificarUsuarioHSMTO.resposneWrapper.class);
            responseBody.statusCode = response.getStatusCode();
        } catch (Exception e) {
            responseBody = new VerificarUsuarioHSMTO.resposneWrapper();
            responseBody.statusCode = 999;
        }

        return responseBody;
    }
}