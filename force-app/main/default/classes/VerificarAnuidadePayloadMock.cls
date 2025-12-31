@isTest
global with sharing class VerificarAnuidadePayloadMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String body = 
        '{"success": true, "payload": "Sócio não possui valor de anuidade ou renovação a ser pago.", "error": null}';

        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
}