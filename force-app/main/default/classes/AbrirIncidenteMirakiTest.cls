@isTest
global with sharing class AbrirIncidenteMirakiTest {
        @isTest
        public static void test() {
            Test.setMock(HttpCalloutMock.class, new AbrirInicidenteMirakiMock());
            AbrirIncidenteMiraki.makeAPIRequest('12345', '1');
        }

        global with sharing class AbrirInicidenteMirakiMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{' +
                '"message" : "Not Found",' +
                '"status" : 404' +
            '}';

            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(404);
            return response;
        }
    }
}