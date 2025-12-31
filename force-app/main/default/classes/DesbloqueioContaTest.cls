@isTest
private class DesbloqueioContaTest {

    @isTest
    public static void DesbloquearContaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(204);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/desbloquear' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        DesbloqueioConta.Output retorno = DesbloqueioContaController.DesbloquearConta('55765609309', '37000000036', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Desbloquear Conta' LIMIT 1];

        System.AssertNotEquals(null, retorno);
        System.AssertEquals('OK', retorno.statusAPI);
    }

    @isTest
    public static void DesbloquearContaErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(422);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/55765609309/desbloquear' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        DesbloqueioConta.Output retorno = DesbloqueioContaController.DesbloquearConta('55765609309', '37000000036', '1', 'cockpit', 'Cobranca', 'cockpit');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Desbloquear Conta' LIMIT 1];

        System.AssertNotEquals(null, retorno);
        System.AssertEquals('ERRO', retorno.statusAPI);
    }

}