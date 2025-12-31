@IsTest
public class FlowHelperBuscarComunicationTest {
    
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

        //Cria os outputs para chamada da classe e faz o chamado.
        FlowHelperBuscarComunication.Input input = new FlowHelperBuscarComunication.Input();
        input.contentVersionTitle = testContentVersion.Title;
        List<FlowHelperBuscarComunication.Input> inputs = new List<FlowHelperBuscarComunication.Input>();
        inputs.add(input);
        Test.startTest();
        List<FlowHelperBuscarComunication.Output> outputs = FlowHelperBuscarComunication.ArquivoDinamico(inputs);
        Test.stopTest();

        List<ContentDistribution> listCreatedContentDistribution = [SELECT Id FROM ContentDistribution];
        System.assertEquals(false, listCreatedContentDistribution.isEmpty());
    }
}