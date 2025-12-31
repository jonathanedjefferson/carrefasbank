@IsTest
public class FlowHelperComunicadoPickerTest {
    
    @IsTest
    static void testArquivoDinamico() {
        //Cria e insere um novo ContentVersion.
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;

        //Seleciona o ContentDocument automaticamente criado.
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument];

        //Cria os outputs para chamada da classe e faz o chamado.
        FlowHelperComunicadoPicker.Input input = new FlowHelperComunicadoPicker.Input();
        input.contentVersionId = testContentVersion.Id;
        List<FlowHelperComunicadoPicker.Input> inputs = new List<FlowHelperComunicadoPicker.Input>();
        inputs.add(input);
        Test.startTest();
        List<FlowHelperComunicadoPicker.Output> outputs = FlowHelperComunicadoPicker.ArquivoDinamico(inputs);
        Test.stopTest();

        System.assertNotEquals(0, outputs.size(), 'Outputs should not be empty');
        List<ContentVersion> insertedContentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'Test Document%' AND Id != :testContentVersion.Id];
        System.assertEquals(1, insertedContentVersions.size(), 'One new ContentVersion should be inserted');
        System.assert(insertedContentVersions[0].Title.contains('.pdf'), 'The inserted ContentVersion title should end with .pdf');
    }
}