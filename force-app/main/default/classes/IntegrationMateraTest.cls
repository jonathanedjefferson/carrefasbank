@isTest
private class IntegrationMateraTest {
    private static final Id MATERA_QUEUEID;

    static {
        List<QueueSObject> lLstQueueMatera = [SELECT QueueId FROM QueueSObject WHERE Queue.DeveloperName = 'Matera'];
        MATERA_QUEUEID = lLstQueueMatera[0].QueueId;
    }

    @TestSetup
    private static void makeData(){
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CFI_ContaFinanceira').getRecordTypeId();
        String recordTypeIdContaPessoal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BCSF_RT_PAC_ClientePessoalCarrefour').getRecordTypeId();
        String recordTypeIdCasoSAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_SAC').getRecordTypeId();

        Account accountNomeCliente = new Account(
            RecordTypeId = recordTypeIdContaPessoal,
            LastName = 'Teste Account',
            CPF__c = '49599020006'
        );
        insert accountNomeCliente;

        ContaFinanceira__c contaFinceira = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroConta__c = '00977880022825672'
        );
        insert contaFinceira;

        InstituicaoFinanceira__c banco = new InstituicaoFinanceira__c(
            AcessoPrincipal__c = 'ABC',
            InicioOperacao__c = Date.today(),
            ISPB__c = '1122',
            NomeExtenso__c = 'Banco para teste', 
            NomeReduzido__c = 'Banco',
            NumeroCodigo__c = '1234',
            ParticipaCompe__c = 'Sim'
        );
        insert banco;

        Case sendToIntegrationCase = new Case(
            AccountId = accountNomeCliente.Id,
            ContaFinanceira__c = contaFinceira.Id,
            Banco__c = banco.Id,
            Status = 'Em tratativa',
            Type = 'Solicitação',
            Assunto__c = 'Pagamento',
            Evento__c = 'Reembolso', 
            ContaOrigem__c = '12345',
            TipoConta__c = 'Corrente',
            NomeCompleto__c = 'Caso para Integrar',
            NumeroDocumento__c = '49599020006',
            Valor__c = 5,
            ContaDebitar__c = '202',
            OwnerId = MATERA_QUEUEID,
            RecordTypeId = recordTypeIdCasoSAC,
            NumeroAgencia__c = 8411,
            NumeroConta__c = 28145, 
            DigitoConta__c = 7
        );

        Case integratedCase = new Case(
            AccountId = accountNomeCliente.Id,
            ContaFinanceira__c = contaFinceira.Id,
            Banco__c = banco.Id,
            Status = 'Em tratativa',
            Type = 'Solicitação',
            Assunto__c = 'Pagamento',
            Evento__c = 'Reembolso',
            ContaOrigem__c = '12345',
            TipoConta__c = 'Corrente',
            NomeCompleto__c = 'Caso Integrado',
            NumeroDocumento__c = '49599020006',
            Valor__c = 5,
            ContaDebitar__c = '202',
            IdLiquidacaoFinanceiraMatera__c = '09876',
            OwnerId = MATERA_QUEUEID,
            RecordTypeId = recordTypeIdCasoSAC,
            Quantidade__c = 1, 
            DataHora__c = DateTime.now()
        );
        insert new List<Case>{sendToIntegrationCase, integratedCase};

        insert new CaseIntegrations__c(
            Name = 'Matera', 
            Assunto__c = 'Pagamento;Desenrola', 
            Evento__c = 'Reembolso;Devolução desenrola'
        );
    }

    @isTest
    private static void testScheduleSendMatera() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(201, 'MockSendMatera');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        String jobId = BatchIntegrationMatera.runSchedule();
        Test.stopTest();

        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

      	Assert.areEqual(0, ct1.TimesTriggered);
    }

    @isTest
    private static void testScheduleGetStatusMatera() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(201, 'MockGetStatusTransactionCompleted');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        String jobId = BatchGetStatusTransactionMatera.runSchedule();
        Test.stopTest();

        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

      	Assert.areEqual(0, ct1.TimesTriggered);
    }

    @isTest
    private static void sendDataTestSuccess() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(201, 'MockSendMatera');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        Case lCase = [SELECT Id, IdLiquidacaoFinanceiraMatera__c, Quantidade__c, DataHora__c
            FROM Case WHERE NomeCompleto__c = 'Caso para Integrar' LIMIT 1];

        update new Case(
            Id = lCase.Id, 
            Status = 'Em tratativa'
        );

        Test.startTest();
        Database.executeBatch(new BatchIntegrationMatera());
        Test.stopTest();

        lCase = [SELECT Id, IdLiquidacaoFinanceiraMatera__c, Quantidade__c, DataHora__c
            FROM Case WHERE NomeCompleto__c = 'Caso para Integrar' LIMIT 1];

        Assert.areEqual('246692', lCase.IdLiquidacaoFinanceiraMatera__c);
        Assert.areNotEqual(null, lCase.DataHora__c);
    }

    @isTest
    private static void sendDataTestError() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        Database.executeBatch(new BatchIntegrationMatera());
        Test.stopTest();

        Case lCase = [SELECT Id, IdLiquidacaoFinanceiraMatera__c FROM Case WHERE NomeCompleto__c = 'Caso para Integrar' LIMIT 1];

        Assert.areEqual(null, lCase.IdLiquidacaoFinanceiraMatera__c);
    }

    @isTest
    private static void getStatusTransactionCompleted() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockGetStatusTransactionCompleted');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Case lCase = [SELECT Id, Finalizacao__c, Status FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];

        update new Case(
            Id = lCase.Id, 
            Status = 'Em tratativa'
        );

        Test.startTest();
        Database.executeBatch(new BatchGetStatusTransactionMatera());
        Test.stopTest();

        lCase = [SELECT Id, Finalizacao__c, Status FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];

        Assert.areEqual('Liquidado', lCase.Finalizacao__c);
        Assert.areEqual('Closed', lCase.Status);
    }

    @isTest
    private static void getStatusTransactionPending() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockGetStatusTransactionPending');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Case lCase = [SELECT Id, Finalizacao__c, Status FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];
        
        update new Case(
            Id = lCase.Id, 
            Status = 'Em tratativa'
        );

        Test.startTest();
        Database.executeBatch(new BatchGetStatusTransactionMatera());
        Test.stopTest();

        lCase = [SELECT Id, Finalizacao__c FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];

        Assert.areEqual(null, lCase.Finalizacao__c);
    }

    @isTest
    private static void getStatusTransactionDanied() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockGetStatusTransactionDenied');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Case lCase = [SELECT Id, Finalizacao__c, Status FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];
        
        update new Case(
            Id = lCase.Id, 
            Status = 'Em tratativa'
        );

        Test.startTest();
        Database.executeBatch(new BatchGetStatusTransactionMatera());
        Test.stopTest();

        lCase = [SELECT Id, Finalizacao__c FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];

        Assert.areEqual('Devolvido', lCase.Finalizacao__c);
    }

    @isTest
    private static void getStatusTransactionCanceled() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400, 'MockGetStatusTransactionCanceled');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Case lCase = [SELECT Id, Finalizacao__c, Status FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];
        
        update new Case(
            Id = lCase.Id, 
            Status = 'Em tratativa'
        );

        Test.startTest();
        Database.executeBatch(new BatchGetStatusTransactionMatera());
        Test.stopTest();

        lCase = [SELECT Id, Finalizacao__c FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];

        Assert.areEqual('Devolvido', lCase.Finalizacao__c);
    }

    @isTest
    private static void getStatusTransactionError() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Case lCase = [SELECT Id, Finalizacao__c, Status FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];
        
        update new Case(
            Id = lCase.Id, 
            Status = 'Em tratativa'
        );

        Test.startTest();
        Database.executeBatch(new BatchGetStatusTransactionMatera());
        Test.stopTest();

        lCase = [SELECT Id, Finalizacao__c FROM Case WHERE NomeCompleto__c = 'Caso Integrado' LIMIT 1];

        Assert.areEqual(null, lCase.Finalizacao__c);
    }
}