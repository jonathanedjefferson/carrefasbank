public class TokenWhatsApp {
    public static String generateTokenWhatsAppCallout() {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('API Gerar token de autenticação v1');
        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c;
        String clientId = config.clientId__c;
        String clientSecret = config.clientSecret__c;
        String apiKey = config.apiKey__c;

        TokenWhatsAppTO.Body requestBody = new TokenWhatsAppTO.Body();
        requestBody.client_id = clientId;
        requestBody.client_secret = clientSecret;
        String requestBodyJson = Json.serialize(requestBody);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(config.endpoint__c);
        request.setMethod(config.method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', apiKey);
        request.setHeader('auth-key', config.token__c);
        request.setBody(requestBodyJson);

        HttpResponse response = new Http().send(request);
        LogIntegracaoBO.InsertLog('Gerar token whatsapp', config.endpoint__c, 'POST', requestBodyJson, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'SAMS');
        if(response.getStatusCode() == 200) {
            TokenWhatsAppTO.ResponseWrapper responseWrapper = (TokenWhatsAppTO.ResponseWrapper) JSON.deserialize(response.getBody(), TokenWhatsAppTO.ResponseWrapper.class);
            return responseWrapper.token;
        } else {
            System.debug('erro na api');
            return null;
        }
    }
}