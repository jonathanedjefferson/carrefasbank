@isTest
global class FlowAbrirIncidenteTest {   
    @IsTest
    static void testFlow() {
        List<FlowAbrirIncidente.Input> inputList = new List<FlowAbrirIncidente.Input>();
        FlowAbrirIncidente.Input inLst = new FlowAbrirIncidente.Input();
        inLst.orderId = 'asddfsds1245';
        inLst.consignmentId = '123';
        inLst.orderLineId = '12345';
        inLst.contactReason = 'test';
        inLst.brand = 'CARREFOUR';
        inputList.add(inLst); 
        Test.setMock(HttpCalloutMock.class, new FlowAbrirIncidenteTest.AbrirIncidentMock());        
        FlowAbrirIncidente.callAPI(inputList);        
    }
    
    
    global with sharing class AbrirIncidentMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setBody('{"status":1, "message":"teste"}');
            response.setStatusCode(201);
            return response;
        }
    }
}