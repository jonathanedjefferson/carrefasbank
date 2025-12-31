@IsTest
public class RESTMock implements HttpCalloutMock {

    @TestVisible
    private static List<HttpResponse> responses = new List<HttpResponse>();
    @TestVisible
    private static Integer counter = 0;

    public static void setResponse(HttpResponse res) {
        responses.add(res);
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = responses.get(counter);
        counter += 1;
        return res; 
    }

    @IsTest
    static void test_self() {
        HttpResponse res200 = new HttpResponse();
        res200.setStatusCode(200);

        HttpResponse res404 = new HttpResponse();
        res404.setStatusCode(404);

        System.assertNotEquals(null, RESTMock.responses, 'A lista de respostas não pode ser nula.');
        System.assertEquals(0, RESTMock.responses.size(), 'A lista de respostas deve estar vazia.');

        RESTMock.setResponse(res200);
        RESTMock.setResponse(res404);

        Test.startTest();
        System.assertNotEquals(null, RESTMock.responses, 'A lista de respostas não pode ser nula.');
        System.assertEquals(2, RESTMock.responses.size(), 'A lista de respostas não deve estar vazia.');

        RESTMock mock = new RESTMock();
        System.assertEquals(200, mock.respond(null).getStatusCode(), 'Deveria corresponder à primeira resposta.');
        System.assertEquals(404, mock.respond(null).getStatusCode(), 'Deveria corresponder à segunda resposta.');
        Test.stopTest();
    }
}