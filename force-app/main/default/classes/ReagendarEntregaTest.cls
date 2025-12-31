@isTest
global with sharing class ReagendarEntregaTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new ReagendarEntregaMock());
        ReagendarEntrega.makeAPIRequest('123', '123', '123', '123', '121', 'teste', '123');
    }

    global with sharing class ReagendarEntregaMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}