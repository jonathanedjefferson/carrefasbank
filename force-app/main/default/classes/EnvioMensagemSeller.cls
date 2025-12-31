public with sharing class EnvioMensagemSeller {
    public static EnvioMensagemSellerTO makeAPIRequest(String consigmentCode, String bodyMessage) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Enviar mensagem ao seller');
        String apiUrl = config.endpoint__c + consigmentCode + '-A/threads';
        String calloutMethod = config.method__c;
        String token = config.token__c;
        System.debug(consigmentCode + '-A');

        HttpRequest request = new HttpRequest();
        Http http = new Http();
  
        String boundary = '-------------------------' + String.valueOf(Datetime.now().getTime());
        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Authorization', token);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        request.setHeader('Content-Length', '0');
        String messageBody = '{"body":"'+ bodyMessage +'","topic":{"type":"FREE_TEXT","value":"Comunicado Carrefour"},"to":["SHOP"]}}';
        String body = '--' + boundary + '\r\n' +
                      'Content-Disposition: form-data; name="thread_input"' + '\r\n' +
                      'Content-Type: application/json' + '\r\n\r\n' +
                      messageBody + '\r\n' +
                      '--' + boundary + '--';
        request.setBody(body);

        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        LogIntegracaoBO.InsertLog('Enviar mensagem ao seller', apiUrl, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        EnvioMensagemSellerTO responseBody = (EnvioMensagemSellerTO) Json.deserialize(response.getBody(), EnvioMensagemSellerTO.class);
        responseBody.statusCode = response.getStatusCode();
        System.debug(responseBody);
        return responseBody;
    }
}