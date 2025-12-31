@IsTest
global with sharing class FlowCaseCreationWithDocumentTest {
    
    @IsTest
    static void testFlow_Success() {

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.png',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        // Cria lista de entrada com dados válidos
        List<FlowCaseCreationWithDocument.Input> inputList = new List<FlowCaseCreationWithDocument.Input>();
        FlowCaseCreationWithDocument.Input inLst = new FlowCaseCreationWithDocument.Input();
        inLst.preferenceContact = 'email';
        inLst.orderNumber = '123';
        inLst.consignmentCode = '12345';
        inLst.origin = 'test';
        inLst.channel = 'test';
        inLst.typeorder = 'test';
        inLst.subjectReasonContact = 'test';
        inLst.event = 'test';
        inLst.emailClient = 'test@test.com';
        inLst.customerName = 'Test Silva';
        inLst.telephone = '11999999999';
        inLst.description = 'Create test';
        inLst.brand = 'Carrefour';
        inLst.store = 'ecommerce';
        inLst.fileId = testContentVersion.Id;
        inLst.extencaoArquivo = 'png';
        inputList.add(inLst);
        
        // Define mock para sucesso
        Test.setMock(HttpCalloutMock.class, new APICreateCaseMock());
        
        Test.startTest();
        FlowCaseCreationWithDocument.callAPI(inputList);
        Test.stopTest();
            }
    
    @IsTest
    static void testFlow_Failure() {
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        List<FlowCaseCreationWithDocument.Input> inputList = new List<FlowCaseCreationWithDocument.Input>();
        FlowCaseCreationWithDocument.Input inLst = new FlowCaseCreationWithDocument.Input();
        inLst.preferenceContact = 'email';
        inLst.orderNumber = '123';
        inLst.consignmentCode = '12345';
        inLst.origin = 'test';
        inLst.channel = 'test';
        inLst.typeorder = 'test';
        inLst.subjectReasonContact = 'test';
        inLst.event = 'test';
        inLst.emailClient = 'test@test.com';
        inLst.customerName = 'Test Silva';
        inLst.telephone = '11999999999';
        inLst.description = 'Create test';
        inLst.brand = 'Carrefour';
        inLst.store = 'ecommerce';
        inLst.fileId = testContentVersion.Id;
        inLst.extencaoArquivo = 'png';
        inputList.add(inLst);
        
        // Define mock para falha (404)
        Test.setMock(HttpCalloutMock.class, new APICreateCaseNullMock());
        
        Test.startTest();
        FlowCaseCreationWithDocument.callAPI(inputList);
        Test.stopTest();
    }

    
    global with sharing class APICreateCaseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"success":true,"id":"1234"}');
            res.setStatusCode(201);
            return res;
        }
    }

    global with sharing class APICreateCaseNullMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            return res;
        }
    }
}