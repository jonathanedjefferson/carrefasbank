@isTest
public with sharing class FlowCriarProtocoloTest {
    @isTest
    public static void test() {
        List<FlowCriarProtocolo.Input> lstInputs = new List<FlowCriarProtocolo.Input>();

        FlowCriarProtocolo.Input newInput = new FlowCriarProtocolo.Input();
        newInput.email = 'qualqueremail@gmail.com';
        newInput.numPedido = '1234';
        newInput.catedoryId = 12345;
        newInput.departamentoId = 45677;
        newInput.observacao = 'bom dia';
        newInput.prazo = 24;
        newInput.expertId = '123';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new NeoAssistAPIMock());
        FlowCriarProtocolo.chamarAPIProtocolo(lstInputs);
    }

    @isTest
    public static void testWithFile() {
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;

        List<FlowCriarProtocoloAnexo.Input> lstInputs = new List<FlowCriarProtocoloAnexo.Input>();

        FlowCriarProtocoloAnexo.Input newInput = new FlowCriarProtocoloAnexo.Input();
        newInput.email = 'qualqueremail@gmail.com';
        newInput.numPedido = '1234';
        newInput.catedoryId = 12345;
        newInput.departamentoId = 45677;
        newInput.observacao = 'bom dia';
        newInput.prazo = 24;
        newInput.expertId = '123';
        newInput.fileId = testContentVersion.Id;

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new NeoAssistAPIMock());
        Test.startTest();
        FlowCriarProtocoloAnexo.chamarAPIProtocolo(lstInputs);
        Test.stopTest();
    }
}