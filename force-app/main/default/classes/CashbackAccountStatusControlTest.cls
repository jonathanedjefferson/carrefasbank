@isTest
private with sharing class CashbackAccountStatusControlTest {

    @TestSetup
    static void makeData(){
        String recordTypeIdComprouVoltou = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('Comprou_Voltou').getRecordTypeId();
        String recordTypeIdContaPessoal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BCSF_RT_PAC_ClientePessoalCarrefour').getRecordTypeId();

        Account accountNomeCliente = new Account(
            RecordTypeId = recordTypeIdContaPessoal,
            LastName = 'Teste Account',
            CPF__c = '49599020006'
        );
        insert accountNomeCliente;

        ContaFinanceira__c contaFinceira = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdComprouVoltou,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroContrato__c = '00977880022825672'
        );
        insert contaFinceira;
    }

    @isTest
    private static void getCashbackCustomerInfoTestSuccess() {
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        Test.startTest();
        ContaFinanceira__c lReturnedAccount = CashbackAccountStatusControlController.getCashbackCustomerInfo(lFinancialAccount.Id);
        Test.stopTest();

        Assert.isNotNull(lReturnedAccount, 'Deve retornar as informações da Conta Financeira');
    }

    @isTest
    private static void getCashbackCustomerInfoTestError() {
        Test.startTest();
        ContaFinanceira__c lReturnedAccount = CashbackAccountStatusControlController.getCashbackCustomerInfo('');
        Test.stopTest();

        Assert.isNull(lReturnedAccount, 'Não deve retornar dados da Conta Financeira quando não houver parâmetros');
    }

    @isTest
    private static void createCasePreventiveBlockingTestSuccess() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackPreventiveBlocking',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Bloqueio Preventivo',
            'event' => 'Bloqueio preventivo',
            'origin' => 'Fraudes',
            'reason' => 'Suspeita de fraude',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNotNull(lCreatedCase, 'O caso deve ser criado para o bloqueio temporário da conta financeira');
        Assert.isNull(ex, 'Não deve retornar nenhuma exceção durante a execução');
    }

    @isTest
    private static void createCasePreventiveBlockingTestError() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackPreventiveBlocking',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Bloqueio Preventivo',
            'event' => 'Bloqueio preventivo',
            'origin' => 'Fraudes',
            'reason' => 'Suspeita de fraude',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNull(lCreatedCase, 'O Caso não deve ser criado quando houver falha durante a integração com a API');
        Assert.isNotNull(ex, 'Deve gerar uma exceção quando houver falha durante a integração com a API');
    }

    @isTest
    private static void createCasePermanentBlockingTestSuccess() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackPermanentBlocking',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Bloqueio Definitivo',
            'event' => 'Bloqueio definitivo',
            'origin' => 'Fraudes',
            'reason' => 'Fraude confirmada',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNotNull(lCreatedCase, 'O caso deve ser criado para o bloqueio definitivo da conta financeira');
        Assert.isNull(ex, 'Não deve retornar nenhuma exceção durante a execução');
    }

    @isTest
    private static void createCasePermanentBlockingTestError() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackPermanentBlocking',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Bloqueio Definitivo',
            'event' => 'Bloqueio definitivo',
            'origin' => 'Fraudes',
            'reason' => 'Fraude confirmada',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNull(lCreatedCase, 'O Caso não deve ser criado quando houver falha durante a integração com a API');
        Assert.isNotNull(ex, 'Deve gerar uma exceção quando houver falha durante a integração com a API');
    }

    @isTest
    private static void createCaseUnlockAccountTestSuccess() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackUnlockAccount',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Desbloqueio',
            'event' => 'Desbloqueio de preventivo',
            'origin' => 'Fraudes',
            'reason' => 'Suspeita de fraude descartada',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNotNull(lCreatedCase, 'O caso deve ser criado para realizar o desbloqueio da conta financeira');
        Assert.isNull(ex, 'Não deve retornar nenhuma exceção durante a execução');
    }

    @isTest
    private static void createCaseUnlockAccountTestEmptyContractKey() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackUnlockAccount',
            'channel' => 'Interno',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Desbloqueio',
            'event' => 'Desbloqueio de preventivo',
            'origin' => 'Fraudes',
            'reason' => 'Suspeita de fraude descartada',
            'subject' => 'Comprou Voltou'
        };

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNull(lCreatedCase, 'O Caso não deve ser criado quando não for identificado a chave do contrato do cliente');
        Assert.isNotNull(ex, 'Deve gerar uma exceção quando houver falha durante a integração com a API');
    }

    @isTest
    private static void createCaseUnlockAccountTestError() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackUnlockAccount',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Desbloqueio',
            'event' => 'Desbloqueio de preventivo',
            'origin' => 'Fraudes',
            'reason' => 'Suspeita de fraude descartada',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNull(lCreatedCase, 'O Caso não deve ser criado quando houver falha durante a integração com a API');
        Assert.isNotNull(ex, 'Deve gerar uma exceção quando houver falha durante a integração com a API');
    }

    @isTest
    private static void createCaseRequestPreventiveUnlockTest() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackRequestUnlock',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Solicitar desbloqueio',
            'event' => 'Solicitar desbloqueio de preventivo',
            'origin' => 'Fraudes',
            'subject' => 'Comprou Voltou'
        };

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Group preventiveUnlockQueue = [SELECT Id FROM Group WHERE type = 'Queue' AND DeveloperName = 'AnaliseDesbloqueioPreventivoCPV' LIMIT 1];

        Assert.isNotNull(lCreatedCase, 'O caso deve ser criado para solicitar o desbloqueio da conta');
        Assert.areEqual(preventiveUnlockQueue.Id, lCreatedCase.OwnerId, 'O Caso deve ser atribuído a fila Análise de Desbloqueio Preventivo CPV');
        Assert.isNull(ex, 'Não deve retornar nenhuma exceção durante a execução');
    }

    @isTest
    private static void createCaseRequestPermanentUnlockTest() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackRequestUnlock',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Solicitar desbloqueio',
            'event' => 'Solicitar desbloqueio de definitivo',
            'origin' => 'Fraudes',
            'subject' => 'Comprou Voltou'
        };

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Group permanentUnlockQueue = [SELECT Id FROM Group WHERE type = 'Queue' 
            AND DeveloperName = 'AnaliseDesbloqueioDefinitivoCPV' LIMIT 1];

        Assert.isNotNull(lCreatedCase, 'O caso deve ser criado para solicitar o desbloqueio da conta');
        Assert.areEqual(permanentUnlockQueue.Id, lCreatedCase.OwnerId, 'O Caso deve ser atribuído a fila Análise de Desbloqueio Definitivo CPV');
        Assert.isNull(ex, 'Não deve retornar nenhuma exceção durante a execução');
    }

    @isTest
    private static void unlockAccountActionSuccess() {
        ContaFinanceira__c lFinancialAccount = [SELECT Id, CPFBanco__c, NumeroContrato__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        CashbackAccountStatusControlService.Input input = new CashbackAccountStatusControlService.Input();
        input.cpf = lFinancialAccount.CPFBanco__c;
        input.contractKey = lFinancialAccount.NumeroContrato__c;
        input.actionType = 'CashbackUnlockAccount';

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();

        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        List<CashbackAccountStatusControlService.Output> lLstOutputs = 
            CashbackAccountStatusControlController.atualizaStatusContaComprouVoltou(new List<CashbackAccountStatusControlService.Input> {input});
        Test.stopTest();

        Assert.areEqual('OK', lLstOutputs[0].statusAPI, 'Deve retornar sucesso quando a integração ocorrer corretamente');
    }

    @isTest
    private static void permanentBlockActionSuccess() {
        ContaFinanceira__c lFinancialAccount = [SELECT Id, CPFBanco__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        CashbackAccountStatusControlService.Input input = new CashbackAccountStatusControlService.Input();
        input.cpf = lFinancialAccount.CPFBanco__c;
        input.actionType = 'CashbackPermanentBlocking';

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        List<CashbackAccountStatusControlService.Output> lLstOutputs = 
            CashbackAccountStatusControlController.atualizaStatusContaComprouVoltou(new List<CashbackAccountStatusControlService.Input> {input});
        Test.stopTest();

        Assert.areEqual('OK', lLstOutputs[0].statusAPI, 'Deve retornar sucesso quando a integração ocorrer corretamente');
    }

    @isTest
    private static void atualizaStatusActionEmptyParamsTest() {
        Test.startTest();
        List<CashbackAccountStatusControlService.Output> lLstOutputs = 
            CashbackAccountStatusControlController.atualizaStatusContaComprouVoltou(new List<CashbackAccountStatusControlService.Input>());
        Test.stopTest();

        Assert.areEqual('NOK', lLstOutputs[0].statusAPI, 'Deve gerar uma falha quando não há parâmetros de entrada');
    }

    @isTest
    private static void atualizaStatusActionEmptyCpfTest() {
        CashbackAccountStatusControlService.Input input = new CashbackAccountStatusControlService.Input();
        input.actionType = 'CashbackUnlockAccount';
        input.cpf = '';

        Test.startTest();
        List<CashbackAccountStatusControlService.Output> lLstOutputs = 
            CashbackAccountStatusControlController.atualizaStatusContaComprouVoltou(new List<CashbackAccountStatusControlService.Input>{input});
        Test.stopTest();

        Assert.areEqual('NOK', lLstOutputs[0].statusAPI, 'Deve gerar uma falha quando o CPF não for informado');
    }

    @isTest
    private static void statusControleActionError() {
        ContaFinanceira__c lFinancialAccount = [SELECT Id, CPFBanco__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        CashbackAccountStatusControlService.Input input = new CashbackAccountStatusControlService.Input();
        input.cpf = lFinancialAccount.CPFBanco__c;
        input.actionType = 'CashbackPermanentBlocking';

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        List<CashbackAccountStatusControlService.Output> lLstOutputs = 
            CashbackAccountStatusControlController.atualizaStatusContaComprouVoltou(new List<CashbackAccountStatusControlService.Input> {input});
        Test.stopTest();

        Assert.areEqual('NOK', lLstOutputs[0].statusAPI, 'Deve retornar erro quando houver uma falha durante a integração');
    }

    @isTest
    private static void createCaseCancelAccountTestSuccess() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackCancelAccount',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Cancelamento de conta',
            'event' => 'Cancelamento de conta',
            'origin' => 'Fraudes',
            'reason' => 'Proteção de dados (LGPD)',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNotNull(lCreatedCase, 'O caso deve ser criado para cancalamento da conta financeira');
        Assert.isNull(ex, 'Não deve retornar nenhuma exceção durante a execução');
    }

    @isTest
    private static void createCaseCancelAccountTestError() {
        Exception ex;
        Case lCreatedCase;
        ContaFinanceira__c lFinancialAccount = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        Map<String, Object> lMapParams = new Map<String, Object> {
            'actionType' => 'CashbackCancelAccount',
            'channel' => 'Interno',
            'contractNumber' => '00977880022825672',
            'contractStatus' => 'Ativo',
            'customerCpf' => '49599020006',
            'customerId' => lFinancialAccount.Id,
            'description' => 'Teste Criação Caso Cancelamento de conta',
            'event' => 'Cancelamento de conta',
            'origin' => 'Fraudes',
            'reason' => 'Proteção de dados (LGPD)',
            'subject' => 'Comprou Voltou'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        try {
            lCreatedCase = CashbackAccountStatusControlController.createCase(lMapParams);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.StopTest();

        Assert.isNull(lCreatedCase, 'O Caso não deve ser criado quando houver falha durante a integração com a API');
        Assert.isNotNull(ex, 'Deve gerar uma exceção quando houver falha durante a integração com a API');
    }
}