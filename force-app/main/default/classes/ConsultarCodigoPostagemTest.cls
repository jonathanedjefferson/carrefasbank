@isTest
global with sharing class ConsultarCodigoPostagemTest {
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new ConsultarCodigoPostagemMock());
        ConsultarCodigoPostagem.makeAPIRequest('123445');
    }

    global with sharing class ConsultarCodigoPostagemMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{' +
                '"orders" : [' +
                '{' +
                    '"shipping_deadline" : "2023-09-26T01:50:04.893Z",' +
                    '"last_updated_date" : "2023-09-30T18:05:06Z",' +
                    '"order_lines" :[ ' +
                        '{' +
                            '"order_line_state" : "REFUNDED",' +
                            '"order_line_state_reason_code" : null,' +
                            '"order_line_state_reason_label" : null,' +
                            '"shipped_date" : "2023-09-22T23:14:37Z"' +
                        '}' +
                    '],' +
                        '"order_additional_fields" : [' +
                            '{' +
                                '"code" : "bairro-seller",' +
                                '"type" : "STRING",' +
                                '"value" : "Mooca"' +
                            '}, {' +
                                '"code" : "codigo-postagem-reversa",' +
                                '"type" : "STRING",' +
                                '"value" : "2660488632"' +
                            '}, {' +
                                '"code" : "shipping-priority-name",' +
                                '"type" : "STRING",' +
                                '"value" : "ENVIOS"' +
                            '}, {' +
                                '"code" : "wevo-tracking-received",' +
                                '"type" : "BOOLEAN",' +
                                '"value" : "true"' +
                            '}' +
                        ']' +
                    '}' +
                ']' +
            '}';
        
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}