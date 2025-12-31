@isTest
global with sharing class ConsultarStatusPedidoTest {
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new ConsultarStatusPedidoMock());
        ConsultarStatusPedido.notaFiscalEmitida('123445');
    }

    global with sharing class ConsultarStatusPedidoMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{' +
                '"orderCode" : "207311923",' +
                '"consignments" : [ {' +
                '"consignmentCode" : "2073119230001",' +
                '"status" : [ {' +
                    '"status" : "ETR",' +
                    '"creationTime" : "2019-01-23T02:20:07.637Z[UTC]",' +
                    '"description" : "Entrega Realizada",' +
                    '"color" : "GREEN"' +
                '}, {' +
                    '"status" : "NFE",' +
                    '"creationTime" : "2019-01-19T20:48:21.424Z[UTC]",' +
                    '"description" : "Nota Fiscal Emitida",' +
                    '"color" : "ORANGE"' +
                    '}]' +
                '} ]' +
            '}';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}