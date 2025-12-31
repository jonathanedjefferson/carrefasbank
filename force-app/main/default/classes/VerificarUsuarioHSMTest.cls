@isTest
global with sharing class VerificarUsuarioHSMTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new VerificarUsuarioHSMMock());
        VerificarUsuarioHSM.makeAPIRequest('12-99205-6397');
    }

    global with sharing class VerificarUsuarioHSMMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{"optin":true}';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}