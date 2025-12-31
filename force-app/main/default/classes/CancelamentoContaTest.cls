/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - BCSF_CancelamentoContaController                 100              *
*    - BCSF_CancelamentoContaBO                         100              *
*    - CarrefourAPICalloutDAO                           100%             *
*    - CancelamentoConta                                98%              *
**************************************************************************/
@isTest
public class CancelamentoContaTest {
    @isTest
    public static void CancelarContaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/servicecloud-atendimento/api/contas/70000038250/bloquear' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        BCSF_CancelamentoContaController.cancelamentoConta('70000038250', 'BLCK', '1', '39779764518', 'cockpit', 'cockpit', 'Ouvidoria');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Cancelamento de Conta' LIMIT 1];
        System.AssertEquals('39779764518', log.CPF__c);
        System.AssertEquals('PATCH', log.Metodo__c);
    }
    
    @isTest
    public static void ListStatusCancelamentoContaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('{"status":[{"nome":"BLCK","descricao":"Bloqueio provisorio"},{"nome":"CLSB","descricao":"Cancelado pelo Banco"},{"nome":"CLSC","descricao":"Cancelado pelo Cliente"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/servicecloud-atendimento/api/contas/bloquear/listar-status' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        CancelamentoConta.OutputStatusCancelamento output = BCSF_CancelamentoContaController.getStatusCancelamentoConta('cockpit', 'Ouvidoria');
        Test.StopTest();

        System.AssertEquals('BLCK', output.status[0].nome);
        System.AssertEquals('CLSB', output.status[1].nome);
        System.AssertEquals('CLSC', output.status[2].nome);
    }

    @isTest
    public static void getContaFinanceira(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;

        Test.StartTest();
        BCSF_CancelamentoContaBO.AvaliacaoAnualTO rt = BCSF_CancelamentoContaController.getContaFinanceira(cf.Id);
        String cpf = BCSF_CancelamentoContaBO.formatarCPF('11111111111');
        Test.StopTest();

        System.AssertEquals(cpf, '111.111.111-11');
        System.AssertEquals(rt.NumeroConta, '11111111111');
        System.AssertEquals(rt.Nome, 'Teste');
        System.AssertEquals(rt.CPF, '123.456.789-12');
        System.AssertEquals(rt.StatusConta, 'NORM');
    }

    @isTest
    public static void criarCasoTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String statusCancelamento = 'BLCK';
        String requisito = 'Aumento de limite';
        String contaFinanceiraId = cf.id;
        String accountId = acc.id;
        String unidadeNegocio = '1';
        String origem = 'Customer Support';
        String canal = 'E-mail';
        String evento = 'Produtos e Serviços';
        String assunto = 'Cancelamento de cartão de crédito';


        Test.StartTest();
        BCSF_CancelamentoContaController.criarCaso(statusCancelamento, requisito, contaFinanceiraId, accountId, unidadeNegocio, origem, canal, evento, assunto);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void atualizarContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.StatusConta__c = 'NORM';
        insert cf;

        Test.StartTest();
        BCSF_CancelamentoContaController.atualizarContaFinanceira(cf.Id, 'BLCK');
        Test.StopTest();
    }
}