public with sharing class GerarTokenAutenticacao {
    public static GerarTokenAutenticacaoTO.resposneWrapper makeAPIRequest() {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('ConcederTokenHSM');
        String clientId = config.clientId__c;
        String clientSecret = config.clientSecret__c;
        String grantType = config.username__c;
        String method = config.method__c;

        String apiUrl = config.endpoint__c;
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        GerarTokenAutenticacaoTO calloutData = new GerarTokenAutenticacaoTO();
        calloutData.clientId = clientId;
        calloutData.clientSecret = clientSecret;
        calloutData.grantType = grantType;
        
        String body = JSON.serialize(calloutData);        
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(apiUrl);
        request.setBody(body);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Gerar token de autenticação', apiUrl, method, body, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        GerarTokenAutenticacaoTO.resposneWrapper responseBody = new GerarTokenAutenticacaoTO.resposneWrapper();

        try {
            responseBody = (GerarTokenAutenticacaoTO.resposneWrapper) Json.deserialize(response.getBody(), GerarTokenAutenticacaoTO.resposneWrapper.class);
            responseBody.statusCode = response.getStatusCode();
        } catch (Exception e) {
            responseBody = new GerarTokenAutenticacaoTO.resposneWrapper();
            responseBody.statusCode = 999;
        }


        return responseBody;
    }
}