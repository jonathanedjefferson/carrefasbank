@isTest
global with sharing class GerarTokenAutenticacaoTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new GerarTokenAutenticacaoMock());
        GerarTokenAutenticacao.makeAPIRequest();
    }

    global with sharing class GerarTokenAutenticacaoMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRJZCI6InNhbGVzZm9yY2UiLCJjbGllbnRTZWNyZXQiOiIyZTc4YzVhNy0zZGQ1LTQ2OWItYjNhZS1iODVkYTc1OTE4MzMiLCJncmFudFR5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJpYXQiOjE2OTE2OTEwMjEsImV4cCI6MTY5MTY5MTkyMX0.4eSFEhr7tk7Kd_Qj7sDE7fVa_1W8SUICQk6CoiUl1M0"}';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}