@isTest
public with sharing class NeoAssistAPITest{
    @isTest
    public static void testNeoAssistAPI() {
        Test.setMock(HttpCalloutMock.class, new NeoAssistAPIMock());
        NeoAssistAPI.makeAPIRequest('test', 'test', 'test', 'test', 'test', 123, 'test', 'test', 123, 123);
    }

    @isTest
    public static void testNeoAssistAPIAnexo() {
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;

        List<ContentDocument> testContentDocumentBefore = [SELECT Id FROM ContentDocument];
        Test.setMock(HttpCalloutMock.class, new NeoAssistAPIMock());
        Test.startTest();
        NeoAssistAPIAnexo.makeAPIRequest('teste', 'teste', testContentVersion.Id, 'teste', 'teste', 'teste', 123, 'teste', 'teste', 123, 123, 'teste', 'teste', 123, 'teste', 'teste', 'teste');
        Test.stopTest();

        List<ContentDocument> testContentDocumentAfter = [SELECT Id FROM ContentDocument];
        System.assertEquals(false, testContentDocumentBefore.isEmpty());
        System.assertEquals(true, testContentDocumentAfter.isEmpty());
    }
}