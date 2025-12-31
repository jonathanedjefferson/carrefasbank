public with sharing class VerificarAnuidadePayload {
    public static VerificarAnuidadePayloadTO.resposneWrapper makeAPIRequest(String codMembership) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('API Verificar Anuidade');
        String apiKey = config.apiKey__c;
        String calloutMethod = config.method__c;
        String apiUrl = config.endpoint__c;

        String authToken;
        if(!Test.isRunningTest()) {
            authToken = TokenWhatsApp.generateTokenWhatsAppCallout();
        } else {
            authToken = 'teste';
        }

        VerificarAnuidadePayloadTO body = new VerificarAnuidadePayloadTO();
        body.codigoMembership = codMembership;
        body.urlRetorno = 'http://www.cielo.com.br';
        body.saleschannel = 1;
        body.envio = 'email';

        String fullBody = JSON.serialize(body);

        HttpRequest request = new HttpRequest();
        request.setMethod(calloutMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setHeader('x-api-key', apiKey);
        request.setBody(fullBody);
        request.setEndpoint(apiUrl);
        request.setTimeout(60000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        LogIntegracaoBO.InsertLog('Verificar anuidade do sócio', apiUrl, calloutMethod, fullBody, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'SAMS');
        
        if (response.getStatusCode() == 200) {
            VerificarAnuidadePayloadTO.resposneWrapper responseBody = (VerificarAnuidadePayloadTO.resposneWrapper) Json.deserialize(response.getBody(), VerificarAnuidadePayloadTO.resposneWrapper.class);
            return responseBody;
        } else {
            return null;
        }
    }
}