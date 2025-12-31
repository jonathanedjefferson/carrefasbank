@isTest
public class AntecipacaoParcelasTest {

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
    public static void listarParcelamentosOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(200, 'MockListarParcelamentos');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoListarParcelamentos retorno = AntecipacaoParcelasController.listarParcelamentos('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', true, 'teste', '2025-02-20', '2025-02-20');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void listarParcelamentosErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoListarParcelamentos retorno = AntecipacaoParcelasController.listarParcelamentos('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', true, 'teste', '2025-02-20', '2025-02-20');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void obterParcelamentoOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(200, 'MockObterParcelamento');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoObterParcelamento retorno = AntecipacaoParcelasController.obterParcelamento('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '123');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void obterParcelamentoErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoObterParcelamento retorno = AntecipacaoParcelasController.obterParcelamento('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '123');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void simularAntecipacaoOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(200, 'MockSimularAntecipacaoSucesso');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla retorno = AntecipacaoParcelasController.simularAntecipacoes('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '[ { "idParcelamento": 301797, "parcelas": [ 9 ] } ]');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void simularAntecipacaoErroTratadoTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(422, 'MockSimularAntecipacaoFalha422');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla retorno = AntecipacaoParcelasController.simularAntecipacoes('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '[ { "idParcelamento": 301797, "parcelas": [ 9 ] } ]');
        Test.StopTest();

        Assert.areEqual('ERRO_TRATADO', retorno.statusAPI);
    }

    @isTest
    public static void simularAntecipacaoErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla retorno = AntecipacaoParcelasController.simularAntecipacoes('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '[ { "idParcelamento": 301797, "parcelas": [ 9 ] } ]');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void anteciparParcelasOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(200, 'MockAnteciparParcelas');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoAntecipacao retorno = AntecipacaoParcelasController.anteciparParcelas('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '[ { "idParcelamento": 301797, "parcelas": [ 9 ] } ]', 'Boleto', false);
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void anteciparParcelasErroTratadoTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(422, 'MockAnteciparParcelasFalha422');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoAntecipacao retorno = AntecipacaoParcelasController.anteciparParcelas('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '[ { "idParcelamento": 301797, "parcelas": [ 9 ] } ]', 'Boleto', false);
        Test.StopTest();

        Assert.areEqual('ERRO_TRATADO', retorno.statusAPI);
    }

    @isTest
    public static void anteciparParcelasErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoAntecipacao retorno = AntecipacaoParcelasController.anteciparParcelas('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '[ { "idParcelamento": 301797, "parcelas": [ 9 ] } ]', 'Boleto', false);
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void obterDadosPagamentoAvulsoOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(200, 'MockRetornoPagamentoAvulsoAntecipacao');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoPagamentoAvulso retorno = AntecipacaoParcelasController.obterDadosPagamentoAvulso('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Boleto', 10, false);
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void obterDadosPagamentoAvulsoErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoPagamentoAvulso retorno = AntecipacaoParcelasController.obterDadosPagamentoAvulso('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Boleto', 10, false);
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void enviarEmailAlternativoOkTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoEnvioEmail retorno = AntecipacaoParcelasController.enviarEmailAlternativo('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '3fa85f64-5717-4562-b3fc-2c963f66afa6', 'teste@gmail.com', 'Boleto');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void enviarEmailAlternativoErrorTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenAntecipacaoParcelas');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AntecipacaoParcelasTO.RetornoEnvioEmail retorno = AntecipacaoParcelasController.enviarEmailAlternativo('Cockpit', '81488436274', '2', '10000001213', 'teste', 'teste', '3fa85f64-5717-4562-b3fc-2c963f66afa6', 'teste@gmail.com', 'Boleto');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }
    
    @isTest
    public static void obterContaFinanceiraTest(){
        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];

        Test.StartTest();
        ContaFinanceiraBO.ContaFinanceira retorno = AntecipacaoParcelasController.obterContaFinanceira(cf.Id);
        Test.StopTest();

        Assert.isNotNull(retorno);
    }

    @isTest
    public static void criarCasoTest(){
        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];
        Account act = [SELECT Id FROM Account LIMIT 1];

        Test.StartTest();
        Case retorno = AntecipacaoParcelasController.criarCaso(act.Id, 'Closed', 'Pagamento', 'Antecipação de parcelas', 'Ouvidoria', cf.Id, '2', 'Execução', 'Whatsapp', 'Medium');
        Test.StopTest();

        Assert.isNotNull(retorno);
    }

}