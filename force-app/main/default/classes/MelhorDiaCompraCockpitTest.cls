/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - MelhorDiaCompraCockpitController                 100%             *
*    - MelhorDiaCompraCockpit                           100%             *
**************************************************************************/
@isTest
public without sharing class MelhorDiaCompraCockpitTest {
    @isTest
    public static void melhorDiaCompraTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"melhorDiaCompra": 27}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'integracao-salesforce-faturas/api/v1.0/contas/11111111111/faturas/melhor-dia-compra' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'BLCK';
        insert cf;

        Test.StartTest();
        String retorno = MelhorDiaCompraCockpitController.getMelhorDiaCompra(cf.NumeroConta__c, acc.CPF__c,  cf.UnidadeNegocio__c, 'cockpit');
        Test.StopTest();

        System.AssertEquals(retorno, '27');
    }
    
    @isTest
    public static void getDataUltimaFaturaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"dataVencimento": "2024-01-08T00:00:00"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/11111111111/faturas/fechadas/ultima/resumo' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        String RecTypeId= [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND (Name = 'Conta pessoal' OR Name='Person Account')].Id;
        Account acc = new Account();
        acc.RecordTypeID = RecTypeId;
        acc.LastName = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'BLCK';
        cf.bairro__c = 'Jaraguá';
        cf.CEP__c = '02034-243';
        cf.Cidade__c = 'São Paulo';
        cf.Estado__c = 'SP';
        cf.Numero__c = '123';
        insert cf;

        Test.StartTest();
        MelhorDiaCompraCockpit.ResponseAPI retorno = MelhorDiaCompraCockpitController.getDataULtimaFatura(cf.NumeroConta__c , cf.UnidadeNegocio__c, acc.CPF__c, 'cockpit');
        Test.StopTest();
        
        
        System.assertNotEquals(retorno, null);
    }

    @isTest
    public static void getInfoContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'BLCK';
        insert cf;

        Test.StartTest();
        ContaFinanceira__c retorno = MelhorDiaCompraCockpitController.getInfoContaFinanceira(cf.Id);
        Test.StopTest();

        System.AssertEquals(retorno.NumeroConta__c, '11111111111');
        System.AssertEquals(retorno.NomeCliente__r.CPF__c, '123.456.789-12');
        System.AssertEquals(retorno.UnidadeNegocio__c, '1');
    }
}