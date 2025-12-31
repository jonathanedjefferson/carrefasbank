@isTest
private class DesbloqueioSenhaCartaoTest {

    @isTest
    public static void ListarCartaoDesbloqueioSenhaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('[{"numeroCartaoSerno": "940751","numeroCartaoOfuscado": "5438.XXXX.XXXX.0272","status": "NORM","ehPrimario": true,"wrongPinRetries": 3}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha/listar-cartoes' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        List<DesbloqueioSenhaCartao.CartoesDesbloqueioSenha> retorno = DesbloqueioSenhaCartaoController.GetListaCartaoDesbloqueioSenha('55765609309', '37000000036', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Cartão Desbloqueio de Senha' LIMIT 1];

        System.AssertNotEquals(0, retorno.size());
        System.AssertEquals('940751', retorno[0].numeroCartaoSerno);
        System.AssertEquals(3, retorno[0].wrongPinRetries);
    }

    @isTest
    public static void DesbloquearSenhaCartaoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('[{"idSerno": "923015","sucesso": false},{"idSerno": "924694","sucesso": true},{"idSerno": "924695","sucesso": false}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
    
        List<String> listaCartoesSerno = new List<String>{'923015', '924694', '924695'};

        Test.StartTest();
        List<DesbloqueioSenhaCartao.SenhaCartaoDesbloqueada> retorno = DesbloqueioSenhaCartaoController.DesbloquearSenhaCartao('55765609309', '37000000036', '1', 'cockpit', 'Cobranca', 'cockpit', listaCartoesSerno);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Desbloquear Senha Cartão' LIMIT 1];

        System.AssertNotEquals(0, retorno.size());
        System.AssertEquals(true, retorno[1].sucesso);
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
        ContaFinanceiraBO.ContaFinanceira result = DesbloqueioSenhaCartaoController.getContaFinanceira(cf.Id);
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
    public static void CreateCaseTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
        DesbloqueioSenhaCartaoController.createCaseDesbloqueioSenhaCartao('Whatsapp', 'Ouvidoria', String.valueOf(cf.Id), String.valueOf(acc.Id), '1');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

}