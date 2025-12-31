/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - IdentificacaoPositiva                            94%              *
**************************************************************************/
@isTest
public class IdentificacaoPositivaTest {
    @isTest
    public static void PerguntasTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responsePerguntas = new HttpResponse();
        responsePerguntas.setBody('{"sessao":"4fb698ba-ddfc-4841-a0ce-0a6b4a122ef5","perguntas":[{"id":1,"descricao":"Nome da Mãe","alternativas":[{"descricao":"MARIANA FERNANDES"},{"descricao":"ELISA MIRANDA PESTANA"},{"descricao":"LUCELAINE BEATRIZ SOLTO"},{"descricao":"NORMA RODRIGUES"}]},{"id":10,"descricao":"Cep Residencial Titular","alternativas":[{"descricao":"01133-010"},{"descricao":"12879-328"},{"descricao":"69855-587"},{"descricao":"25830-698"}]},{"id":17,"descricao":"Pagamento da Última Fatura foi total ou parcial?","alternativas":[{"descricao":"TOTAL"},{"descricao":"PARCIAL"}]}]}');
        responsePerguntas.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/idp/v2/csf-servicos' => responseServerToServer, 
            '/api/v1/identificacao-positiva/perguntas' => responsePerguntas
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        IdentificacaoPositiva.OutputPerguntas rt = IdentificacaoPositiva.Perguntas('sistema', 'cockpit', '39779764518', '1', '5242345234');
        Test.StopTest();

        System.AssertEquals(rt.sessao, '4fb698ba-ddfc-4841-a0ce-0a6b4a122ef5');
        System.AssertEquals(rt.perguntas.size(), 3);

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identificação Positiva - Perguntas' LIMIT 1];
        System.AssertEquals('39779764518', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }

    @isTest
    public static void ValidarPerguntasTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responsePerguntas = new HttpResponse();
        responsePerguntas.setBody('{"aprovado":false}');
        responsePerguntas.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/v2/csf-servicos' => responseServerToServer, 
                '/api/v1/identificacao-positiva/perguntas' => responsePerguntas
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        Map<String, String> mapPerguntasRespostas = new Map<String, String>();
        mapPerguntasRespostas.put('0','A');
        mapPerguntasRespostas.put('1','B');

        Test.StartTest();
        IdentificacaoPositiva.OutputValidarPerguntas rt = IdentificacaoPositiva.ValidarPerguntas('4fb698ba-ddfc-4841-a0ce-0a6b4a122ef5', mapPerguntasRespostas, '1', '39779764518', 'cockpit');
        Test.StopTest();

        System.AssertEquals(rt.aprovado, false);

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identificação Positiva - Validar Perguntas' LIMIT 1];
        System.AssertEquals('39779764518', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }
   
    @isTest
    public static void atualizarContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '436.765.400-18';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.DataUltimaIdentificacaoPositiva__c = system.now().addDays(-10);
        cf.IdentificaoPositiva__c = false;
        insert cf;

        Test.StartTest();
        BCSF_IdentificacaoPositivaController.atualizarContaFinanceira(cf.Id);
        Test.StopTest();
    }

    @isTest
    public static void getContasAtivasTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        acc.BillingPostalCode = '00000100';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.Telefone__c = '5511940402020';
        cf.Cep__c = '00000100';
        insert cf;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.Situacao__c = 'A'; 
        insert ass1;
        
        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'JULIANA SOUZA'; 
        ass2.NumeroCartao__c = '5438821360413546'; 
        ass2.CPF__c = '12345678945'; 
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        ass2.Situacao__c = 'A'; 
        insert ass2;

        Test.StartTest();
            List<Asset> listCartoes = BCSF_IdentificacaoPositivaController.getContasAtivas(cf.Id);
        Test.StopTest();

        System.AssertEquals(2, listCartoes.size());
    }

    @isTest
    public static void getContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        acc.BillingPostalCode = '00000100';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.Telefone__c = '5511940402020';
        cf.Cep__c = '00000100';
        cf.DataUltimaIdentificacaoPositiva__c = system.now().addDays(-10);
        cf.IdentificaoPositiva__c = true;
        insert cf;

     
        Test.StartTest();
            BCSF_IdentificacaoPositivaController.ContaFinanceiraTitular contaObj= BCSF_IdentificacaoPositivaController.getContaFinanceira(cf.Id);
        Test.StopTest();

        System.AssertEquals('11111111111', contaObj.NumeroConta);
    }

    @isTest
    public static void getPerguntasControllerTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responsePerguntas = new HttpResponse();
        responsePerguntas.setBody('{"sessao":"4fb698ba-ddfc-4841-a0ce-0a6b4a122ef5","perguntas":[{"id":1,"descricao":"Nome da Mãe","alternativas":[{"descricao":"MARIANA FERNANDES"},{"descricao":"ELISA MIRANDA PESTANA"},{"descricao":"LUCELAINE BEATRIZ SOLTO"},{"descricao":"NORMA RODRIGUES"}]},{"id":10,"descricao":"Cep Residencial Titular","alternativas":[{"descricao":"01133-010"},{"descricao":"12879-328"},{"descricao":"69855-587"},{"descricao":"25830-698"}]},{"id":17,"descricao":"Pagamento da Última Fatura foi total ou parcial?","alternativas":[{"descricao":"TOTAL"},{"descricao":"PARCIAL"}]}]}');
        responsePerguntas.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/idp/v2/csf-servicos' => responseServerToServer, 
            '/api/v1/identificacao-positiva/perguntas' => responsePerguntas
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        IdentificacaoPositiva.OutputPerguntas rt = BCSF_IdentificacaoPositivaController.getPerguntas('sistema', 'cockpit', '39779764518', '1', '5242345234');
        Test.StopTest();

        System.AssertEquals(rt.sessao, '4fb698ba-ddfc-4841-a0ce-0a6b4a122ef5');
        System.AssertEquals(rt.perguntas.size(), 3);

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identificação Positiva - Perguntas' LIMIT 1];
        System.AssertEquals('39779764518', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }

    
    @isTest
    public static void ValidarPerguntasControllerTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responsePerguntas = new HttpResponse();
        responsePerguntas.setBody('{"aprovado":false}');
        responsePerguntas.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/v2/csf-servicos' => responseServerToServer, 
                '/api/v1/identificacao-positiva/perguntas' => responsePerguntas
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
      
        List<BCSF_IdentificacaoPositivaController.Repostas> lisRepostas = new List<BCSF_IdentificacaoPositivaController.Repostas>();

        BCSF_IdentificacaoPositivaController.Repostas resposta1 = new BCSF_IdentificacaoPositivaController.Repostas();
        resposta1.key = '0';
        resposta1.value = 'A';
        lisRepostas.add(resposta1);

        BCSF_IdentificacaoPositivaController.Repostas resposta2 = new BCSF_IdentificacaoPositivaController.Repostas();
        resposta2.key = '1';
        resposta2.value = 'B';
        lisRepostas.add(resposta2);

        String JSONString = JSON.serialize(lisRepostas);
      
        Test.StartTest();
        IdentificacaoPositiva.OutputValidarPerguntas rt = BCSF_IdentificacaoPositivaController.ValidarPerguntas('4fb698ba-ddfc-4841-a0ce-0a6b4a122ef5', JSONString, '1', '39779764518', 'cockpit');
        Test.StopTest();

        System.AssertEquals(rt.aprovado, false);

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identificação Positiva - Validar Perguntas' LIMIT 1];
        System.AssertEquals('39779764518', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }
}