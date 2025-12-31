@isTest
public with sharing class ContestacaoCompraControllerTest {

    @isTest
    public static void getContaFinanceiraTest(){
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
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Test.startTest();
        ContaFinanceiraBO.ContaFinanceira result = ContestacaoCompraController.getContaFinanceira(cf.Id);
        Test.stopTest();

        System.assertEquals(result.Nome, 'Teste');
        System.assertEquals(result.CPF, '123.456.789-12');
        System.assertEquals(result.StatusConta, 'NORM');
        System.assertEquals(result.NumeroConta, '11111111111');
        System.assertEquals(result.TipoConta, '2');
        System.assertEquals(result.UnidadeNegocio, '1');
        System.assertEquals(result.AccountId, acc.Id);
    }

    @isTest
    public static void CreateCaseContestacaoIntercambioTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String transacoesContestadasJson = '[{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030", "dataTransacao":"11/09/2024 09:44:40","codigoTransacao":"010831","valor":"90","codigoEntrada":"050","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"10/09/2024 09:49:44","codigoTransacao":"071165","valor":"100","codigoEntrada":"070","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"09/09/2024 17:19:48","codigoTransacao":"055630","valor":"350","codigoEntrada":"010","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"}]';

        Test.StartTest();
        Case caso = ContestacaoCompraController.createCase('Não reconhece compra', 'Whatsapp', 'Ouvidoria', 
        String.valueOf(cf.Id), String.valueOf(acc.Id), '1', 'Re-discorda parecer', 'Sim', 'Descrição do atendente', transacoesContestadasJson);

        Case casoCriado;
        if(caso != null){
            casoCriado = CasoDAO.getInstance().getCase(caso.Id);
        }
        Test.StopTest();

        System.AssertNotEquals(caso, null);
        System.AssertEquals(casoCriado.Assunto__c, 'Intercâmbio fraude');
        System.AssertEquals(casoCriado.Evento__c, 'Não reconhece compra');
    }

    @isTest
    public static void CreateCaseContestacaoPrevencaoFraudeTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String transacoesContestadasJson = '[{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"11/09/2024 09:44:40","codigoTransacao":"010831","valor":"90","codigoEntrada":"050","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"10/09/2024 09:49:44","codigoTransacao":"071165","valor":"100","codigoEntrada":"070","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"09/09/2024 17:19:48","codigoTransacao":"055630","valor":"350","codigoEntrada":"010","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"}]';

        Test.StartTest();
        Case caso = ContestacaoCompraController.createCase('Não reconhece compra', 'Whatsapp', 'Ouvidoria', 
        String.valueOf(cf.Id), String.valueOf(acc.Id), '1', 'Invasão APP', 'Sim', null, transacoesContestadasJson);

        Case casoCriado;
        if(caso != null){
            casoCriado = CasoDAO.getInstance().getCase(caso.Id);
        }
        Test.StopTest();

        System.AssertNotEquals(caso, null);
        System.AssertEquals(casoCriado.Assunto__c, 'Intercâmbio fraude');
        System.AssertEquals(casoCriado.Evento__c, 'Não reconhece compra');
    }

    @isTest
    public static void CreateCaseContestacaoRPATest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String transacoesContestadasJson = '[{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"11/09/2024 09:44:40","codigoTransacao":"010831","valor":"90","codigoEntrada":"050","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"10/09/2024 09:49:44","codigoTransacao":"071165","valor":"100","codigoEntrada":"070","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"09/09/2024 17:19:48","codigoTransacao":"055630","valor":"350","codigoEntrada":"010","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"}]';

        Test.StartTest();
        ContestacaoCompraController.createCase('Contestação', 'Whatsapp', 'Ouvidoria', 
        String.valueOf(cf.Id), String.valueOf(acc.Id), '1', null, 'Sim', null, transacoesContestadasJson);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void getListCartoesTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaNumeroConta');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        List<IdentificaCockpit.Cartao> output = 
            ContestacaoCompraController.getListCartoes('10000078864', '2', '98390073277', 'cockpit');
        Test.StopTest();

        System.assertEquals(3, output.size());
    }

    @isTest
    public static void getListTransacoesTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockAutorizacoesOnUsOffUs');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        AutorizacoesOnUsOffUs.OutputAutorizacoes output = 
            ContestacaoCompraController.getListTransacoes('98390073277', '10000078864', '2', 
                'cockpit', '1060173', '', '', '10', '1');
            
        Test.StopTest();

        System.assertEquals(16, output.totalItens);
        System.assertEquals('Retail Seller LTD', output.data[5].estabelecimento);
        System.assertEquals(90, output.data[5].valor);
    }

    @isTest
    public static void bloqueioCartaoSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        String output = 
            ContestacaoCompraController.bloquearCartao('2', 'cockpit', 'cockpit', 'cobranca', '98390073277', '10000078864', '1060173', 'UIND');
        Test.StopTest();

        System.assertEquals('OK', output);
    }

    @isTest
    public static void bloqueioCartaoErroPerfilizacaoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(403);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        String output = ContestacaoCompraController.bloquearCartao('2', 'cockpit', 'cockpit', 'cobranca', '98390073277', '10000078864', '1060173', 'UIND');
        Test.StopTest();

        System.assertEquals('ERRO_PERFILIZACAO', output);
    }

    @isTest
    public static void bloqueioCartaoErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        String output = ContestacaoCompraController.bloquearCartao('2', 'cockpit', 'cockpit', 'cobranca', '98390073277', '10000078864', '1060173', 'UIND');
        Test.StopTest();

        System.assertEquals('ERRO', output);
    }

    @isTest
    public static void marcarTransacaoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockMarcacaoPaytrue');
        objMultiHttpCalloutMock.addResponse(200, 'MockMarcacaoPaytrue');
        objMultiHttpCalloutMock.addResponse(200, 'MockMarcacaoPaytrue');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        String transacoesContestadasJson = '[{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"11/09/2024 09:44:40","dataTransacaoISO":"202409110949404","codigoTransacao":"010831","valor":"90","codigoEntrada":"050","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"10/09/2024 09:49:44","dataTransacaoISO":"20240910094944","codigoTransacao":"071165","valor":"100","codigoEntrada":"070","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"},'
            + '{"numeroConta":"10000078864","numeroCartaoOfuscado":"5438XXXXXXXX0420","idCartaoSerno":"102030","dataTransacao":"09/09/2024 17:19:48","dataTransacaoISO":"20240909171948","codigoTransacao":"055630","valor":"350","codigoEntrada":"010","cartaoBloqueado":true,"cartaoRoubado":"Não","clienteCartao":"Sim"}]';

        Test.StartTest();
            List<ContestacaoCompras.OutputMarcarTransacao> retorno = ContestacaoCompraController.marcarTransacoes('Whatsapp', '1', '98390073277', 'Invasão APP', transacoesContestadasJson);
        Test.StopTest();

        for(ContestacaoCompras.OutputMarcarTransacao retornoTransacao : retorno){
            System.assertEquals('OK', retornoTransacao.retornoAPI);
        }

        //System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

}