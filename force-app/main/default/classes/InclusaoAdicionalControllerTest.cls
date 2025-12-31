@isTest
public class InclusaoAdicionalControllerTest {
    
    @isTest
    public static void solicitarCartaoAdicional() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
		
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-cartao-adicional/api/v1/cartao/contas/20000002616/cartaoadicional' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegrationAdicional.OutputSolicitarCartaoAdicional retorno = InclusaoAdicionalController.solicitarCartaoAdicional('55765609309', '20000002616', 'cockpit', 'Cobranca', 'cockpit', '1', '29856410045', 'CARLA D SANTOS', 'F', '2000-02-06');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Solicitar Cartão Adicional' LIMIT 1];

        System.AssertNotEquals(null, log);
        System.AssertEquals('OK', retorno.statusAPI);
    }

    @isTest
    public static void solicitarCartaoAdicionalErroLimite() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(422);
        responseHttp.setBody('Este cliente já possui 4 adicionais cadastrados.');
		
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-cartao-adicional/api/v1/cartao/contas/20000002616/cartaoadicional' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegrationAdicional.OutputSolicitarCartaoAdicional retorno = InclusaoAdicionalController.solicitarCartaoAdicional('55765609309', '20000002616', 'cockpit', 'Cobranca', 'cockpit', '1', '29856410045', 'CARLA D SANTOS', 'F', '2000-02-06');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Solicitar Cartão Adicional' LIMIT 1];

        System.AssertNotEquals(null, log);
        System.AssertEquals('ERROR_422', retorno.statusAPI);
        System.AssertEquals('Este cliente já possui 4 adicionais cadastrados.', retorno.mensagem);
    }

    @isTest
    public static void solicitarCartaoAdicionalErroStatusConta() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(422);
        responseHttp.setBody('Conta sem status de permissao para fazer inclusão de adicional');
		
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-cartao-adicional/api/v1/cartao/contas/20000002616/cartaoadicional' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegrationAdicional.OutputSolicitarCartaoAdicional retorno = InclusaoAdicionalController.solicitarCartaoAdicional('55765609309', '20000002616', 'cockpit', 'Cobranca', 'cockpit', '1', '29856410045', 'CARLA D SANTOS', 'F', '2000-02-06');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Solicitar Cartão Adicional' LIMIT 1];

        System.AssertNotEquals(null, log);
        System.AssertEquals('ERROR_422', retorno.statusAPI);
        System.AssertEquals('Conta sem status de permissao para fazer inclusão de adicional', retorno.mensagem);
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
        cf.CEP__c = '38500044';
        insert cf;

        Test.startTest();
        ContaFinanceiraBO.ContaFinanceira result = InclusaoAdicionalController.getContaFinanceira(cf.Id);
        Test.stopTest();

        System.assertEquals(result.Nome, 'Teste');
        System.assertEquals(result.CPF, '123.456.789-12');
        System.assertEquals(result.StatusConta, 'NORM');
        System.assertEquals(result.NumeroConta, '11111111111');
        System.assertEquals(result.TipoConta, '2');
        System.assertEquals(result.UnidadeNegocio, '1');
        System.assertEquals(result.AccountId, acc.Id);
        System.assertEquals(result.CEP, '38500-044');
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
        InclusaoAdicionalController.createCaseSolicitarAdicional('Whatsapp', 'Ouvidoria', String.valueOf(cf.Id), String.valueOf(acc.Id), '1');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }
}