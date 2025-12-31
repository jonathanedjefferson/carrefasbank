@isTest
global with sharing class APICaseCreationTest {
    
    @IsTest
    static void testFlow() {
        List<FlowCaseCreation.Input> inputList = new List<FlowCaseCreation.Input>();
        FlowCaseCreation.Input inLst = new FlowCaseCreation.Input();
        inLst.preferenceContact = 'email';
        inLst.orderNumber = '123';
        inLst.consignmentCode = '12345';
        inLst.origin = 'test';
        inLst.channel = 'test';
        inLst.typeorder = 'test';
        inLst.subjectReasonContact = 'test';
        inLst.event = 'test';
        inLst.emailClient = 'test@test.com';
        inLst.customerName = 'test Silva';
        inLst.telephone = '1123456566767';
        inLst.description = 'Create test';
        inLst.brand = 'Carrefour';
        inLst.store = 'ecommerce';
        inputList.add(inLst);
        
        Test.setMock(HttpCalloutMock.class, new APICaseCreationTest.APICreateCaseMock());        
        FlowCaseCreation.callAPI(inputList);        
    }
    
    @IsTest
    static void testNullFlow() {
        List<FlowCaseCreation.Input> inputList = new List<FlowCaseCreation.Input>();
        FlowCaseCreation.Input inLst = new FlowCaseCreation.Input();
        inLst.preferenceContact = 'email';
        inLst.orderNumber = '123';
        inLst.consignmentCode = '12345';
        inLst.origin = 'test';
        inLst.channel = 'test';
        inLst.typeorder = 'test';
        inLst.subjectReasonContact = 'test';
        inLst.event = 'test';
        inLst.emailClient = 'test@test.com';
        inLst.customerName = 'test Silva';
        inLst.telephone = '1123456566767';
        inLst.description = 'Create test';
        inLst.brand = 'Carrefour';
        inLst.store = 'ecommerce';
        inputList.add(inLst);
        
        Test.setMock(HttpCalloutMock.class, new APICaseCreationTest.APICreateCaseNullMock());        
        FlowCaseCreation.callAPI(inputList);  
    }
    
    
    global with sharing class APICreateCaseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setBody('{"success":true, "id":"1234"}');
            response.setStatusCode(201);
            return response;
        }
    }
        global with sharing class APICreateCaseNullMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            return response;
        }
    }
    
}