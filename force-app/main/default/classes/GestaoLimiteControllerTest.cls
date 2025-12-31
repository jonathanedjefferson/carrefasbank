/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GestaoLimiteControllerTest {

    @isTest
    public static void gestaoLimiteConsulta(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockGestaoLimiteConsulta');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        GestaoLimite.ResponseConsultarLimite retorno = GestaoLimiteController.consultarLimite('Cockpit', '22208979079', '2', '10000046903', '1', '30');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual(30, retorno.itensPorPagina);
        Assert.areEqual(1, retorno.paginaAtual);
        Assert.areEqual(1, retorno.totalPaginas);
        Assert.areEqual(1, retorno.totalRegistros);
        Assert.areEqual(2, retorno.retornoSolicitacaoAumentoLimiteCockpit[0]?.status);
    }

    @isTest
    public static void gestaoLimiteAumento(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockGestaoLimiteAlterar');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        GestaoLimite.ResponseAlterarLimite retorno = GestaoLimiteController.aumentarLimite('Cockpit', '22208979079', '2', '10000046903', '10000', '12000');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual('2', retorno.status);
        Assert.areEqual('20241000000104', retorno.protocolo);
    }

    @isTest
    public static void GestaoLimiteReducao(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockGestaoLimiteAlterar');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        GestaoLimite.ResponseAlterarLimite retorno = GestaoLimiteController.reduzirLimite('Cockpit', '22208979079', '2', '10000046903', '10000', '8000');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual('2', retorno.status);
        Assert.areEqual('20241000000104', retorno.protocolo);
    }

    @isTest
    public static void getContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Test.startTest();
        ContaFinanceiraBO.ContaFinanceira result = GestaoLimiteController.obterContaFinanceira(cf.Id);
        Test.stopTest();

        System.assertEquals(result.Nome, 'Teste');
        System.assertEquals(result.CPF, '123.456.789-12');
        System.assertEquals(result.StatusConta, 'NORM');
        System.assertEquals(result.NumeroConta, '11111111111');
        System.assertEquals(result.TipoConta, '1');
        System.assertEquals(result.AccountId, acc.Id);
    }

    @isTest
    public static void criarCasoAumentoLimiteTest(){

        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;


        Test.startTest();
        Case retorno = GestaoLimiteController.criarCaso('Voz', 'Pós Vendas', cf.Id, acc.Id, '1', 'Aumento de limite');
        Test.stopTest();

        Assert.isNotNull(retorno, 'o caso deve ser retornado');
        Assert.areEqual(retorno.Evento__c, 'Aumento de limite');
    }

    @isTest
    public static void criarCasoReducaoLimiteTest(){

        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;


        Test.startTest();
        Case retorno = GestaoLimiteController.criarCaso('Voz', 'Pós Vendas', cf.Id, acc.Id, '1', 'Redução de limite');
        Test.stopTest();

        Assert.isNotNull(retorno, 'o caso deve ser retornado');
        Assert.areEqual(retorno.Evento__c, 'Redução de limite');
    }

    @isTest
    public static void criarCasoConsultaTest(){

        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;


        Test.startTest();
        Case retorno = GestaoLimiteController.criarCaso('Voz', 'Pós Vendas', cf.Id, acc.Id, '1', 'Consulta de histórico');
        Test.stopTest();

        Assert.isNotNull(retorno, 'o caso deve ser retornado');
        Assert.areEqual(retorno.Evento__c, 'Consulta de histórico');
    }
}