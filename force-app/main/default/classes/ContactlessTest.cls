@isTest
private class ContactlessTest {

    @isTest
    public static void ContactlessBuscarStatus() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('{"success": true}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/v1/acps/BuscarStatus' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        Contactless.Output retorno = ContactlessController.ContactlessBuscarStatus('55765609309', '37000000036', '0897', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contactless Buscar Status' LIMIT 1];

        System.AssertNotEquals(null, retorno);
        System.AssertEquals(true, retorno.outputAPI.success);
    }

    public static void ContactlessBuscarStatusErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(400);
        responseHttp.setBody('{"mensagem": "Cpf precisa ter 11 dígitos, Cpf precisa conter apenas números"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/v1/acps/BuscarStatus' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        Contactless.Output retorno = ContactlessController.ContactlessBuscarStatus('55765609309', '37000000036', '0897', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contactless Buscar Status' LIMIT 1];

        System.AssertNotEquals(null, retorno);
        System.AssertEquals(null, retorno.outputAPI.success);
        System.AssertEquals('Cpf precisa ter 11 dígitos, Cpf precisa conter apenas números', retorno.outputAPI.mensagem);
    }

    @isTest
    public static void ContactlessAlterarStatus() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('{"success": true}');
		
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/v1/acps/AlterarStatus' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        Contactless.Output retorno = ContactlessController.ContactlessAlterarStatus('55765609309', '37000000036', '956199', '7878', '9898', 'true', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contactless Alterar Status' LIMIT 1];

        System.AssertNotEquals(null, retorno);
        System.AssertEquals(true, retorno.outputAPI.success);
    }

    @isTest
    public static void ContactlessAlterarStatusErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(400);
        responseHttp.setBody('{"mensagem": "Não autorizado."}');
		
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/v1/acps/AlterarStatus' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        Contactless.Output retorno = ContactlessController.ContactlessAlterarStatus('55765609309', '37000000036', '0789', '7878', '9898', 'true', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contactless Alterar Status' LIMIT 1];

        System.AssertNotEquals(null, retorno);
        System.AssertEquals(null, retorno.outputAPI.success);
        System.AssertEquals('Não autorizado.', retorno.outputAPI.mensagem);
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
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Test.startTest();
        ContaFinanceiraBO.ContaFinanceira result = ContactlessController.getContaFinanceira(cf.Id);
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
    public static void getCartaoesContactlessEnabled(){
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

        Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.CartaoPrimario__c = true;
        ass1.Product2Id = produto.Id;
        ass1.Contactless__c = true;
        ass1.Status = 'NORM';
        ass1.CartaoSernoId__c = '956199';
        insert ass1;

        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'FELICIA B ANDRADE'; 
        ass2.NumeroCartao__c = '5438821131329788'; 
        ass2.CPF__c = '12345678924'; 
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        ass2.CartaoPrimario__c = false;
        ass2.Product2Id = produto.Id;
        ass2.Contactless__c = true;
        ass2.Status = 'LOST';
        ass2.CartaoSernoId__c = '956197';
        insert ass2;

        Test.startTest();
        List<AssetBO.AssetTO> result = ContactlessController.getCartaoesContactlessEnabled(cf.Id);
        Test.stopTest();

        System.AssertEquals(1, result.size());
        System.assertEquals(result[0].NumeroSernoId, '956199');
        System.assertEquals(result[0].NumeroCartao, '5438821131329799');
        System.assertEquals(result[0].NomeReduzido, 'BENJAMIN B ANDRADE');
    }

    @isTest
    public static void getAllAssets(){
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

        Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.CartaoPrimario__c = true;
        ass1.Product2Id = produto.Id;
        ass1.Contactless__c = true;
        ass1.Status = 'NORM';
        ass1.CartaoSernoId__c = '956199';
        insert ass1;

        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'FELICIA B ANDRADE'; 
        ass2.NumeroCartao__c = '5438821131329788'; 
        ass2.CPF__c = '12345678924'; 
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        ass2.CartaoPrimario__c = false;
        ass2.Product2Id = produto.Id;
        ass2.Contactless__c = true;
        ass2.Status = 'LOST';
        ass2.CartaoSernoId__c = '956197';
        insert ass2;

        Test.startTest();
        List<AssetBO.AssetTO> result = AssetBO.getAllAssets(cf.Id, 5);
        Test.stopTest();

        System.AssertEquals(2, result.size());
    }

    @isTest
    public static void CreateCaseTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
        ContactlessController.createCaseAlterarStatusContactless('Whatsapp', 'Ouvidoria', String.valueOf(cf.Id), String.valueOf(acc.Id), '1', 'Reclamação sobre contactless');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

}