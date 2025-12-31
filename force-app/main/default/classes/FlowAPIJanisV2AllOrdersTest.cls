@isTest 
global with sharing class FlowAPIJanisV2AllOrdersTest {
    @isTest 
    static void testFlow() {
        List<FlowAPIJanisV2AllOrders.Input> inputList = new List<FlowAPIJanisV2AllOrders.Input>();
        FlowAPIJanisV2AllOrders.Input input = new FlowAPIJanisV2AllOrders.Input();
        input.orderCode = '526093901';
        input.email = '1';
        inputList.add(input);
        APIJanisV2Mock mock = new APIJanisV2Mock();
        Test.setMock(HttpCalloutMock.class, mock);        
        FlowAPIJanisV2AllOrders.chamarAPI(inputList);        
    }

    @isTest 
    static void testFlowWithoutObjects() {
        List<FlowAPIJanisV2AllOrders.Input> inputList = new List<FlowAPIJanisV2AllOrders.Input>();
        FlowAPIJanisV2AllOrders.Input input = new FlowAPIJanisV2AllOrders.Input();
        input.orderCode = '526093901';
        input.email = '1';
        inputList.add(input);
        APIJanisV2MockWithOutObjects mock = new APIJanisV2MockWithOutObjects();
        Test.setMock(HttpCalloutMock.class, mock);        
        FlowAPIJanisV2AllOrders.chamarAPI(inputList);        
    }



    global with sharing class APIJanisV2Mock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{' +
                '"objects":[' +
                   '{' +
                      '"orderCode":"526093901",' +
                      '"orderDate":"2023-01-15",' +
                      '"principalCode":"1303386093901-01",' +
                      '"sellersName":"Electrolux",' +
                      '"totalValue":395.83,' +
                      '"consignments":[' +
                         '{' +
                            '"consignmentCode":"5260939010001",' +
                            '"state":"DELIVERED",' +
                            '"totalValue":395.83,' +
                            '"type":"MARKETPLACE_IN",' +
                            '"delivery":{' +
                               '"modality":"MARKETPLACE",' +
                               '"estimateDate":"2023-01-26T01:41:23.820569600Z[UTC]",' +
                               '"store":"",' +
                               '"isPickupStore":false,' +
                               '"shippingAddress":{' +
                                  '"addressType":"residential",' +
                                  '"postalCode":"03729-080",' +
                                  '"state":"SP",' +
                                  '"neighborhood":"Jardim Danfer",' +
                                  '"complement":"Casa 03",' +
                                  '"number":"472",' +
                                  '"country":"BRA",' +
                                  '"street":"Rua Canarana",' +
                                  '"city":"São Paulo"' +
                               '}' +
                            '},' +
                            '"items":[' +
                               '{' +
                                  '"price":379,' +
                                  '"basePrice":379,' +
                                  '"discount":0,' +
                                  '"quantity":1,' +
                                  '"sellerSku":"145",' +
                                  '"sellerName":"2041",' +
                                  '"imageUrl":"https://carrefourbr.vteximg.com.br/arquivos/ids/8282961-120-120/8370443_Depurador-de-Parede-Branco-Electrolux-DE60B-60cm-3-Velocidades---110V_1_Zoom.jpg?v=637357995317400000",' +
                                  '"name":"Depurador de Parede Branco Electrolux DE60B 60cm 3 Velocidades - 110V",' +
                                  '"ean":"7896584046083",' +
                                  '"productId":"20834",' +
                                  '"type":"NORMAL",' +
                                  '"vtexItemId":"20835"' +
                               '}' +
                            '],' +
                            '"status":{' +
                               '"status":"ERS",' +
                               '"creationTime":"2023-01-18T17:57:42.274Z[UTC]",' +
                               '"description":"Entrega Realizada pelo Parceiro",' +
                               '"color":"GREEN"' +
                            '},' +
                            '"totalChanges":0' +
                         '}' +
                      '],' +
                      '"origemApplication":"CustomerServices"' +
                   '}' +
                '],' +
                '"paging":{' +
                   '"limit":10,' +
                   '"offset":0,' +
                   '"totalPages":2,' +
                   '"totalRecords":13' +
                '}' +
             '}';

            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }

    global with sharing class APIJanisV2MockWithOutObjects implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{' +
                '"objects":[],' +
                '"paging":{' +
                   '"limit":10,' +
                   '"offset":0,' +
                   '"totalPages":2,' +
                   '"totalRecords":13' +
                '}' +
             '}';

            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}