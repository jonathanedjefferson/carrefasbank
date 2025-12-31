@isTest
public with sharing class CartaoPrimarioControllerTest {

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
        ContaFinanceiraBO.ContaFinanceira result = CartaoPrimarioController.getContaFinanceira(cf.Id);
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
    public static void CreateCaseCartaoPrimarioTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Test.StartTest();
        Case caso = CartaoPrimarioController.createCase('Whatsapp', 'Ouvidoria', String.valueOf(cf.Id), String.valueOf(acc.Id), '1');

        Case casoCriado;
        if(caso != null){
            casoCriado = CasoDAO.getInstance().getCase(caso.Id);
        }
        Test.StopTest();

        System.AssertNotEquals(caso, null);
        System.AssertEquals(casoCriado.Assunto__c, 'Cartão');
        System.AssertEquals(casoCriado.Evento__c, 'Cartão Primário');
    }

    @isTest
    public static void getAssetCartaoPrimarioTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockObterDataEmisao');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '10000005305';
        insert cf;

        // Antigo
        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '00455134065'; 
        ass1.TipoTitularidade__c = 'TITULAR';
        ass1.TipoCartao__c = 'C';
        ass1.CartaoPrimario__c  = true;
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.Status = 'NORM';
        ass1.CartaoSernoId__c = '1096889';
        insert ass1;
        
        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass2.NumeroCartao__c = '5438821360413546'; 
        ass2.CPF__c = '00455134065'; 
        ass2.TipoTitularidade__c = 'TITULAR';
        ass2.TipoCartao__c = 'C';
        ass2.CartaoPrimario__c  = false;
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        ass2.Status = 'NORM';
        ass2.CartaoSernoId__c = '1091629';
        insert ass2;

        Test.StartTest();
        AssetBO.AssetTO cartao = CartaoPrimarioController.getCartaoPrimario(String.valueOf(cf.Id), '10000005305', '00455134065', '2', 'prevencao_fraude', 'cockpit', 'cockpit');
        Test.StopTest();

        System.AssertNotEquals(cartao, null);
        System.AssertEquals(cartao.Status, 'NORM');
        System.AssertEquals(cartao.IsCartaoPrimario, false);
        System.AssertEquals('1091629', cartao.NumeroSernoId);
    }

    @isTest
    public static void definirCartaoPrimarioTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '10000078864';
        insert cf;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.TipoTitularidade__c = 'TITULAR';
        ass1.CartaoSernoId__c = '0125';
        ass1.TipoCartao__c = 'C';
        ass1.CartaoPrimario__c  = true;
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.Status = '72';
        ass1.DataAtivacaoCartao__c = Date.newInstance(2025, 2, 10);
        insert ass1;
        
        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass2.NumeroCartao__c = '5438821360413546'; 
        ass2.CPF__c = '12345678912'; 
        ass2.TipoTitularidade__c = 'TITULAR';
        ass2.CartaoSernoId__c = '9842';
        ass2.TipoCartao__c = 'C';
        ass2.CartaoPrimario__c  = false;
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        ass2.Status = 'NORM';
        ass2.DataAtivacaoCartao__c = Date.newInstance(2025, 2, 11);
        insert ass2;

        Test.StartTest();
        Boolean output = 
            CartaoPrimarioController.definirCartaoPrimario(String.valueOf(cf.Id), '10000078864', '9842', '12345678912', '1', 'Cobrança', 'Cobrança', 'cockpit');
        Asset assetPrimario = [SELECT CartaoPrimario__c FROM Asset WHERE CartaoSernoId__c = '9842'];
        Test.StopTest();

        System.assertEquals(true, output);
        System.assertEquals(true, assetPrimario.CartaoPrimario__c);
    }

    @isTest
    public static void definirCartaoPrimarioErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(422);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Boolean output = 
            CartaoPrimarioController.definirCartaoPrimario('', '10000078864', '1234', '98390073277', '1', 'Cobrança', 'Cobrança', 'cockpit');
        Test.StopTest();

        System.assertEquals(false, output);
    }

}