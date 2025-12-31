@IsTest
global class IdentificacaoPositivaClienteTest {
    @IsTest
    static void testGetInfoSocio() {
        Test.setMock(HttpCalloutMock.class, new IdentificacaoPositivaClienteMock());
        IdentificacaoPositivaCliente.makeAPIRequest('53058919816');
    }

    global class IdentificacaoPositivaClienteMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBody('[ { "email" : "ayamegomes@gmail.com", "firstName" : "Ayame", "lastName" : "Gomes", "document" : "53058919816", "homePhone" : "+5512992056397", "birthDate" : "1994-09-22T00:00:00.000+0000", "updatedIn" : "2024-02-20T12:00:14.160+0000", "ordersQuantity" : 2, "totalOrdersValue" : 4050.33, "returnedOrdersValue" : 0.0 } ]');
            return response;
        }
    }
}