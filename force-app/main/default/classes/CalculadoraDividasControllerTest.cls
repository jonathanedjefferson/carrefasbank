@isTest
public with sharing class CalculadoraDividasControllerTest {

    @TestSetup
    static void makeData(){
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CFI_ContaFinanceira').getRecordTypeId();
        String recordTypeIdContaPessoal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BCSF_RT_PAC_ClientePessoalCarrefour').getRecordTypeId();

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
    }

    @isTest
    public static void ObterParametrosBuscaOkTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockCalculadora_ObterParametrosBusca');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CalculadoraDividas.OutputObterParametros output = CalculadoraDividasController.ObterParametrosBusca('cockpit', '1', '98390073277', '10000078864');
        Test.StopTest();

        Assert.areEqual('OK', output.codigoErro, 'A api deve retornar ok');
    }

    @isTest
    public static void ObterParametrosBuscaErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CalculadoraDividas.OutputObterParametros output = CalculadoraDividasController.ObterParametrosBusca('cockpit', '1', '98390073277', '10000078864');
        Test.StopTest();

        Assert.areEqual('ERROR', output.codigoErro, 'A api deve retornar sucesso');
    }

    @isTest
    public static void calcularJurosEncargosOkTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockCalculadora_CalcularJurosEncargos');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CalculadoraDividas.OutputCalculadoraDividas output = CalculadoraDividasController.CalcularJurosEncargos('cockpit', '1', '98390073277', '10000078864', '2026-05-26', '14000');
        Test.StopTest();

        Assert.areEqual('OK', output.codigoErro, 'A api deve retornar sucesso');

        
    }

    @isTest
    public static void calcularJurosEncargosErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CalculadoraDividas.OutputCalculadoraDividas output = CalculadoraDividasController.CalcularJurosEncargos('cockpit', '1', '98390073277', '10000078864', '2026-05-26', '14000');
        Test.StopTest();

        Assert.areEqual('ERROR', output.codigoErro, 'A api deve retornar erro');

        
    }

    @isTest
    public static void calcularSaldoDevedorOkTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockCalculadora_SaldoDevedor');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CalculadoraDividas.OutputCalculadoraDividas output = CalculadoraDividasController.CalcularSaldoDevedor('cockpit', '1', '98390073277', '10000078864', '2026-05-26');
        Test.StopTest();

        Assert.areEqual('OK', output.codigoErro, 'A api deve retornar erro');
        
    }

    @isTest
    public static void calcularSaldoDevedorErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CalculadoraDividas.OutputCalculadoraDividas output = CalculadoraDividasController.CalcularSaldoDevedor('cockpit', '1', '98390073277', '10000078864', '2026-05-26');
        Test.StopTest();

        Assert.areEqual('ERROR', output.codigoErro, 'A api deve retornar erro');
        
    }

    @isTest
    public static void obterContaFinanceiraTest(){
        
        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];

        Test.StartTest();
        ContaFinanceiraBO.ContaFinanceira retorno = CalculadoraDividasController.getContaFinanceira(cf.Id);
        Test.StopTest();

        Assert.isNotNull(retorno, 'a conta financeira deve ser retornada');
    }

     @isTest
    static void testCreateCaseJurosTotalQuitacao() {

        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        String evento = 'Juros e encargos do saldo total para quitação';
        String canal = 'Voz';
        String origem = 'Cobrança';
        String contaFinanceiraId = cf.Id;
        String accountId = acc.Id;
        String unidadeNegocio = '1';

        Test.startTest();
        Case resultCase = CalculadoraDividasController.createCase(
            evento,
            canal,
            origem,
            contaFinanceiraId,
            accountId,
            unidadeNegocio
        );
        Test.stopTest();

        Assert.isNotNull(resultCase, 'o caso deve ser retornado');
    }

    @isTest
    static void testCreateCaseJurosProximaFatura() {

        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        String evento = 'Juros e encargos da próxima fatura';
        String canal = 'Voz';
        String origem = 'Cobrança';
        String contaFinanceiraId = cf.Id;
        String accountId = acc.Id;
        String unidadeNegocio = '1';

        Test.startTest();
        Case resultCase = CalculadoraDividasController.createCase(
            evento,
            canal,
            origem,
            contaFinanceiraId,
            accountId,  
            unidadeNegocio
        );
        Test.stopTest();

        Assert.isNotNull(resultCase, 'o caso deve ser retornado');
    }
}