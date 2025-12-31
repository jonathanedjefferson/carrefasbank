@isTest
global with sharing class EnvioMensagemSellerTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new EnvioMensagemSellerMock());
        EnvioMensagemSeller.makeAPIRequest('teste', 'teste');
    }

    global with sharing class EnvioMensagemSellerMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{ "message_id" : "a0c51765-5530-4081-a012-2b91d99525f1", "thread_id" : "58c2400c-06a4-4206-a4dc-f810fb0b0fd3" }';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}