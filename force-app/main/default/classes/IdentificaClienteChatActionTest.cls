@isTest
private class IdentificaClienteChatActionTest {
    @TestSetup
    static void makeData(){

        User runAsUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String channelId;
        System.runAs(runAsUser) {
           channelId = createMessagingChannel('279492398577777');
        }

        MessagingEndUser messagingEndUser = new MessagingEndUser();
        messagingEndUser.Name = 'Messaging User';
        messagingEndUser.MessagingChannelId = channelId;
        messagingEndUser.MessageType = 'EmbeddedMessaging';
        messagingEndUser.MessagingPlatformKey = '279492398577777';
        insert messagingEndUser;

        MessagingSession messagingSession = new MessagingSession();
        messagingSession.MessagingEndUserId = messagingEndUser.Id;
        messagingSession.MessagingChannelId = channelId;
        messagingSession.Status = 'Active';
        messagingSession.ChaveContaFinanceira__c = '53722165445';
        messagingSession.IdSessaoApp__c = '0199e992-a949-7765-9e8e-1ed63b23be7c';
        insert messagingSession;
        
        Account novaConta = new Account();
        novaConta.CPF__c = '28160641230';
        novaConta.FirstName = 'Teste';
        novaConta.LastName = 'Teste';
        novaConta.RecordTypeId = IdentificaClienteChatDAO.getPersonRecordType().Id;
        insert novaConta;

        ContaFinanceira__c novaCF = new ContaFinanceira__c();
        novaCF.NomeCliente__c = novaConta.Id;
        novaCF.NumeroConta__c = '53722165445';
        novaCF.StatusConta__c = 'NORM';
        novaCF.UnidadeNegocio__c = '1';
        novaCF.IdConta__c = '813268';
        insert novaCF;
    }

    @isTest
    public static void IdentificarClienteTestOK(){

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaClienteChatV2');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        MessagingSession messagingSession = [SELECT Id FROM MessagingSession LIMIT 1];

        List<IdentificaClienteChatAction.Input> listInput = new List<IdentificaClienteChatAction.Input>();
        IdentificaClienteChatAction.Input input = new IdentificaClienteChatAction.Input();
        input.RoutableId = messagingSession.Id;
        input.idEmpresa = '1';
        input.unidadeNegocio = 'CSF';
        listInput.add(input);

        Test.StartTest();
        List<IdentificaClienteChatAction.Output> retorno = IdentificaClienteChatAction.IdentificarCliente(listInput);
        Test.StopTest();

        Assert.areEqual(retorno[0].ClienteIdentificado, true);
        Assert.areEqual(retorno[0].CpfCliente, '28160641230');
        Assert.areEqual(retorno[0].Email, 'teste@gmail.com');
        Assert.areEqual(retorno[0].EmailMascarado, 'tes**@gmail.com');
        Assert.areEqual(retorno[0].IdCartaoPrimario, '56298928');
        Assert.areEqual(retorno[0].PrimeiroNome, 'MARINA');
        Assert.areEqual(retorno[0].StatusCodeApi, 200);
        Assert.areEqual(retorno[0].TemCelularSeguro, true);
        Assert.areEqual(retorno[0].NumeroCelularSeguro, '(**) *****-9855');
        Assert.areEqual(retorno[0].LimiteTotal, 'R$ 1.100,00');
        Assert.areEqual(retorno[0].LimiteDisponivel, 'R$ 592,44');
        Assert.areEqual(retorno[0].nomeMae, 'DORALICE FLORES OLIVEIRA');
        Assert.areEqual(retorno[0].genero, 'F');
        Assert.areEqual(retorno[0].ddd, '11');
        Assert.areEqual(retorno[0].telefone, '283529855');
    }


    @isTest
    public static void IdentificarClienteTestError(){

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(404);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        MessagingSession messagingSession = [SELECT Id FROM MessagingSession LIMIT 1];

        List<IdentificaClienteChatAction.Input> listInput = new List<IdentificaClienteChatAction.Input>();
        IdentificaClienteChatAction.Input input = new IdentificaClienteChatAction.Input();
        input.RoutableId = messagingSession.Id;
        input.idEmpresa = '1';
        input.unidadeNegocio = 'CSF';
        listInput.add(input);

        Test.StartTest();
        List<IdentificaClienteChatAction.Output> retorno = IdentificaClienteChatAction.IdentificarCliente(listInput);
        Test.StopTest();

        Assert.areEqual(retorno[0].StatusCodeApi, 404);
    }

    @isTest
    public static void IdentificarClienteContaInexistente(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaClienteChatV2NewAccount');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        MessagingSession messagingSession = [SELECT Id FROM MessagingSession LIMIT 1];
        messagingSession.ChaveContaFinanceira__c = '31350484';
        update messagingSession;

        List<IdentificaClienteChatAction.Input> listInput = new List<IdentificaClienteChatAction.Input>();
        IdentificaClienteChatAction.Input inputDados = new IdentificaClienteChatAction.Input();
        inputDados.RoutableId = messagingSession.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatAction.Output> retorno = IdentificaClienteChatAction.IdentificarCliente(listInput);
        Test.StopTest();

        System.AssertEquals(retorno[0].ClienteIdentificado, true);
        System.AssertEquals(retorno[0].CpfCliente, '98390073277');
        System.AssertEquals(retorno[0].Email, 'teste@gmail.com');
        System.AssertEquals(retorno[0].EmailMascarado, 'tes**@gmail.com');
        System.AssertEquals(retorno[0].IdCartaoPrimario, '894928');
        System.AssertEquals(retorno[0].PrimeiroNome, 'MARIANA');
        System.AssertEquals(retorno[0].StatusCodeApi, 200);
        System.AssertEquals(retorno[0].TemCelularSeguro, true);
        System.AssertEquals(retorno[0].NumeroCelularSeguro, '(**) *****-1946');
        System.AssertEquals(retorno[0].LimiteTotal, 'R$ 50.000,00');
        System.AssertEquals(retorno[0].LimiteDisponivel, 'R$ 48.500,68');
        System.AssertEquals(retorno[0].nomeMae, 'DORALICE FLORES OLIVEIRA');
        System.AssertEquals(retorno[0].genero, 'F');
        System.AssertEquals(retorno[0].ddd, '11');
        System.AssertEquals(retorno[0].telefone, '932761946');
    }

    @isTest
    public static void IdentificarClienteMissingName(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaClienteChatV2NoName');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        MessagingSession messagingSession = [SELECT Id FROM MessagingSession LIMIT 1];
        messagingSession.ChaveContaFinanceira__c = '31350484';
        update messagingSession;

        List<IdentificaClienteChatAction.Input> listInput = new List<IdentificaClienteChatAction.Input>();
        IdentificaClienteChatAction.Input inputDados = new IdentificaClienteChatAction.Input();
        inputDados.RoutableId = messagingSession.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatAction.Output> retorno = IdentificaClienteChatAction.IdentificarCliente(listInput);
        Test.StopTest();

        Account result = [SELECT Id, FirstName, LastName FROM Account WHERE CPF__c = '98390073277' LIMIT 1];

        Assert.areEqual('MARINA', result.FirstName);
        Assert.areEqual('FLORES OLIVEIRA', result.LastName);
    }

    @isTest
    public static void verificarRetornoCartoesWCNP(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaClienteChatV2WCNP');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        MessagingSession messagingSession = [SELECT Id FROM MessagingSession LIMIT 1];

        List<IdentificaClienteChatAction.Input> listInput = new List<IdentificaClienteChatAction.Input>();
        IdentificaClienteChatAction.Input inputDados = new IdentificaClienteChatAction.Input();
        inputDados.RoutableId = messagingSession.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatAction.Output> retorno = IdentificaClienteChatAction.IdentificarCliente(listInput);
        Test.StopTest();

        Assert.areEqual('944286,955604', retorno[0].idCartoesBloqueadosLst);
    }

    @isTest
    public static void checkMultipleSessionsTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaClienteChatV2');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        User runAsUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String channelId;
        System.runAs(runAsUser) {
           channelId = createMessagingChannel('279492398599999');
        }

        MessagingEndUser messagingEndUser = new MessagingEndUser();
        messagingEndUser.Name = 'Messaging User';
        messagingEndUser.MessagingChannelId = channelId;
        messagingEndUser.MessageType = 'EmbeddedMessaging';
        messagingEndUser.MessagingPlatformKey = '279492398577777';
        insert messagingEndUser;

        MessagingSession messagingSession = new MessagingSession();
        messagingSession.MessagingEndUserId = messagingEndUser.Id;
        messagingSession.MessagingChannelId = channelId;
        messagingSession.Status = 'Active';
        messagingSession.ChaveContaFinanceira__c = '53722165445';
        messagingSession.IdSessaoApp__c = '019a4b67-15df-746a-abd3-e5a08fca86db';
        insert messagingSession;
       
        List<IdentificaClienteChatAction.Input> listInput = new List<IdentificaClienteChatAction.Input>();
        IdentificaClienteChatAction.Input inputDados = new IdentificaClienteChatAction.Input();
        inputDados.RoutableId = messagingSession.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatAction.Output> retorno = IdentificaClienteChatAction.IdentificarCliente(listInput);
        Test.StopTest();

        MessagingSession previousMessagingSession = [SELECT Id, ExpireIn__c FROM MessagingSession WHERE IdSessaoApp__c = '0199e992-a949-7765-9e8e-1ed63b23be7c'];

        Assert.areEqual('-1', previousMessagingSession.ExpireIn__c);
    }

    private static String createMessagingChannel(String aPlatformKey) {
        // MessagingChannel 
        MessagingChannel msgChannel = new MessagingChannel();
        msgChannel.MasterLabel = 'Test Channel';
        msgChannel.DeveloperName = 'Test_Channel' + aPlatformKey;
        msgChannel.IsActive = true;
        msgChannel.MessageType = 'Text'; 
        msgChannel.MessagingPlatformKey = aPlatformKey;
        insert msgChannel;

        return msgChannel.Id;
    }
}