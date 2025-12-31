@isTest
global class CancelOrderWithoutInvoiceTest {
    @IsTest
    static void testCancelOrder() {
        Test.setMock(HttpCalloutMock.class, new cancelOrderMock());
        APICancelOrderWithoutInvoice.cancelOrder('CARREFOUR', '12345');
    }
    @IsTest
    static void testErrorOrder() {
        Test.setMock(HttpCalloutMock.class, new cancelOrderErrorMock());
        APICancelOrderWithoutInvoice.cancelOrder('CARREFOUR', '12345');
    }
    global class cancelOrderMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBody('{"orderId": "abxoajshdayusha12", "receipt": "receipt", "date":"2025-04-02T11:25:12.345678"}');
            return response;
        }
    }
    
    global class cancelOrderErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(422);
            response.setBody('{"timestamp": "2025-04-03T11:51:40.821+00:00", "status": 422,"error": "Unprocessable Entity","message": "error [422] trying to contact with order cancellation: Qtd pedido de entrega [1] Qtd pedido com sucesso [0] Qtd pedido com erro [1] \n555813955 - Pedido de Entrega nao existe no sistema GOLD para cancelamento","path": "/v1/orders/555813955/cancel"}');
            return response;
        }
    }
    
}