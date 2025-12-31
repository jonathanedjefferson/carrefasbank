@isTest
public class CashbackTest {
     
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
            NumeroContrato__c = '00977880022825672',
            StatusContrato__c = 'Ativo'
        );
        insert contaFinceira;
    }
    
    @isTest
    public static void consultarSaldosNativosOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200, 'MockSaldosNativosCashback');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.Balance retorno = CashbackController.consultarSaldosNativos('32967501263', 'Cockpit', '1');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void consultarSaldosNativosErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.Balance retorno = CashbackController.consultarSaldosNativos('32967501263', 'Cockpit', '1');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void consultarExtratoOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200, 'MockExtratoCashback');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.Statement retorno = CashbackController.consultarExtrato('32967501263', 'Cockpit', '1', new Map<String, String>());
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void consultarExtratoErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.Statement retorno = CashbackController.consultarExtrato('32967501263', 'Cockpit', '1', new Map<String, String>());
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void consultarDetalhesTransacaoOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200, 'MockDetalhesTransacao');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.TransactionDetails retorno = CashbackController.consultarDetalhesTransacao('32967501263', 'Cockpit', '1', '11e7d848-bd5c-4056-a843-18fa8345f416');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void consultarDetalhesTransacaoErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.TransactionDetails retorno = CashbackController.consultarDetalhesTransacao('32967501263', 'Cockpit', '1', '11e7d848-bd5c-4056-a843-18fa8345f416');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }
    
    @isTest
    public static void consultarTransacoesFuturasOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200, 'MockTransacoesFuturas');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.FutureTransaction retorno = CashbackController.consultarTransacoesFuturas('32967501263', 'Cockpit', '1');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void consultarTransacoesFuturasErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Cashback.FutureTransaction retorno = CashbackController.consultarTransacoesFuturas('32967501263', 'Cockpit', '1');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void updateCustomerBalanceOkTest(){
        ContaFinanceira__c lFinancialAccount = [SELECT Id, CPFBanco__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        Map<String, Object> lMapParams = new Map<String, Object>{
            'cpf' => lFinancialAccount.CPFBanco__c,
            'rewardPoints' => 81.42,
            'expireDate' => '2025-02-28T23:59:59-03:00'
        };

        Test.StartTest();
        CashbackController.updateCustomerBalance(lMapParams);
        Test.StopTest();

        lFinancialAccount = [SELECT Saldo__c, ValidoAte__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Assert.isNotNull(lFinancialAccount.Saldo__c, 'O Saldo deve ser atualizado');
        Assert.isNotNull(lFinancialAccount.ValidoAte__c, 'A Data de Validade deve ser atualizada');
    }

    @isTest
    public static void updateCustomerBalanceEmptyTest(){
        Map<String, Object> lMapParams = new Map<String, Object>{
            'cpf' => null,
            'rewardPoints' => null,
            'expireDate' => null
        };

        Test.StartTest();
        CashbackController.updateCustomerBalance(lMapParams);
        Test.StopTest();

        ContaFinanceira__c lFinancialAccount = [SELECT Saldo__c, ValidoAte__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Assert.isNull(lFinancialAccount.Saldo__c, 'O Saldo não deve ser atualizado quando há erros');
        Assert.isNull(lFinancialAccount.ValidoAte__c, 'A Data de Validade não deve ser atualizada quando há erros');
    }

    @isTest
    public static void updateCustomerBalanceErrorTest(){
        ContaFinanceira__c lFinancialAccount = [SELECT Id, CPFBanco__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        Map<String, Object> lMapParams = new Map<String, Object>{
            'cpf' => lFinancialAccount.CPFBanco__c,
            'rewardPoints' => null,
            'expireDate' => null
        };

        Test.StartTest();
        CashbackController.updateCustomerBalance(lMapParams);
        Test.StopTest();

        lFinancialAccount = [SELECT Saldo__c, ValidoAte__c FROM ContaFinanceira__c 
            WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Assert.isNull(lFinancialAccount.Saldo__c, 'O Saldo não deve ser atualizado quando há erros');
        Assert.isNull(lFinancialAccount.ValidoAte__c, 'A Data de Validade não deve ser atualizada quando há erros');
    }

    @isTest
    public static void getCustomerInfoSuccess() {
        ContaFinanceira__c lCustomer = [SELECT Id, CPFBanco__c 
            FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Test.StartTest();
        ContaFinanceira__c lCustomerInfo = CashbackController.getCashbackCustomerInfo(lCustomer.CPFBanco__c);
        Test.StopTest();

        Assert.isNotNull(lCustomerInfo, 'Deve retornar os dados do cliente a partir da consulta do CPF');
    }

    @isTest
    public static void getCustomerInfoFail() {
        Test.StartTest();
        ContaFinanceira__c lCustomerInfo = CashbackController.getCashbackCustomerInfo(null);
        Test.StopTest();

        Assert.isNull(lCustomerInfo, 'Não deve retornar os dados do cliente quando não é informado o CPF');
    }

    @isTest
    public static void createCaseRefundSuccess() {
        ContaFinanceira__c lCustomer = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Map<String, Object> lMapParams = new Map<String, Object>{
            'subjectType' => 'refund',
            'customerId' => lCustomer.Id,
            'subject' => 'Comprou Voltou',
            'event' => 'Valor Cashback Errado',
            'origin' => 'Pós Vendas',
            'channel' => 'Chat',
            'amountValue' => '156.98'
        };

        Test.StartTest();
        Case lCreatedCase = CashbackController.createCase(lMapParams);
        Test.StopTest();

        Group tiSustentacaoQueue = [SELECT Id FROM Group WHERE type = 'Queue' AND DeveloperName = 'BKOAjusteCashbackCPV' LIMIT 1];

        Assert.isNotNull(lCreatedCase, 'O Caso deve ser criado com os parâmetros aplicados');
        Assert.areEqual(tiSustentacaoQueue.Id, lCreatedCase.OwnerId, 'O Caso deve ser atribuído a fila Ajuste de Cashback Comprou Voltou');
    }

    @isTest
    public static void createCaseReversalSuccess() {
        ContaFinanceira__c lCustomer = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Map<String, Object> lMapParams = new Map<String, Object>{
            'subjectType' => 'reversal',
            'customerId' => lCustomer.Id,
            'cpf' => '49599020006',
            'subject' => 'Comprou Voltou',
            'event' => 'Resgate não reconhecido',
            'origin' => 'Pós Vendas',
            'channel' => 'Voz',
            'amountValue' => '13.45',
            'contractStatus' => 'Ativo'
        };

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCashback');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Case lCreatedCase = CashbackController.createCase(lMapParams);
        Test.StopTest();

        Group prevencaoFraudeQueue = [SELECT Id FROM Group WHERE type = 'Queue' AND DeveloperName = 'FRDContestacaoResgateCPV' LIMIT 1];
        lCustomer = [SELECT Id, StatusContrato__c FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];

        Assert.isNotNull(lCreatedCase, 'O Caso deve ser criado com os parâmetros aplicados');
        Assert.areEqual(prevencaoFraudeQueue.Id, lCreatedCase.OwnerId, 'O Caso deve ser atribuído a fila Análise de Contestação de Resgate CPV');
        Assert.areEqual('BloqueioTemporario', lCustomer.StatusContrato__c, 'A conta financeira deve ser bloqueada temporariamente na abertura desse caso');
    }

    @isTest
    public static void createCaseFail() {
        ContaFinanceira__c lCustomer = [SELECT Id FROM ContaFinanceira__c WHERE NumeroContrato__c = '00977880022825672' LIMIT 1];
        
        Map<String, Object> lMapParams = new Map<String, Object>{
            'subjectType' => 'refund',
            'customerId' => lCustomer.Id,
            'subject' => 'Comprou Voltou',
            'event' => 'Valor Cashback Errado',
            'origin' => 'Pós Vendas',
            'channel' => 'Facebook',
            'amountValue' => '17.85'
        };

        Test.StartTest();
        Case lCreatedCase = CashbackController.createCase(lMapParams);
        Test.StopTest();

        Assert.isNull(lCreatedCase, 'O não deve ser criado quando há erros durante o processo');
    }
}