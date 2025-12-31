/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ReimpressaoSenha                                 95%              *
*    - BCSF_ReimpressaoSenhaBO                          89%              *
*    - BCSF_ReimpressaoSenhaController                  100%             *
*    - BCSF_ReimpressaoSenhaDAO                         100%             *
*    - ReimpressaoSenhaHelper                           100%             *
*    - ReimpressaoListarCartoesHelper                   100%             *
**************************************************************************/
@isTest
public class ReimpressaoSenhaTest {
    @isTest
    public static void ReimprimirSenhaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/39000002301/cartoes/741500/reimprimir-senha' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        String retorno = BCSF_ReimpressaoSenhaController.ReimprimirSenha('39000002301', '741500', '1', '09825668830', 'cockpit', 'ouvidoria', 'cockpit');
        Test.StopTest();
        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Reimpressão de Senha'];

        System.AssertEquals(retorno, 'OK');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '09825668830');
    }

    @isTest
    public static void ListarCartoesTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('[{"numeroCartaoOfuscado":"5300.XXXX.XXXX.4692","numeroCartaoSerno":"851086","status":"NORM","ehPrimario":true,"nomeCartao":"ISADORA L GARCIA","nomePortador":"ISADORA LOPES GARCIA"}, {"numeroCartaoOfuscado":"1100.XXXX.XXXX.4615","numeroCartaoSerno":"771086","status":"NORM","ehPrimario":true,"nomeCartao":"ANDRE SANTOS","nomePortador":"ANDRE SANTOS VASCONCELOS"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000150419/cartoes/reimprimir-senha/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        
        Test.StartTest();
        List<ReimpressaoSenha.OutputListarCartoes> retorno = BCSF_ReimpressaoSenhaController.getListarCartoes('37000150419', '1', '36109070025', 'cockpit', 'ouvidoria');
        Test.StopTest();
        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Cartões - Reimpressão de Senha'];

        System.AssertEquals(retorno[0].numeroCartaoOfuscado, '5300.XXXX.XXXX.4692');
        System.AssertEquals(retorno[0].numeroCartaoSerno, '851086');
        System.AssertEquals(retorno[0].status, 'NORM');

        System.AssertEquals(retorno[1].numeroCartaoOfuscado, '1100.XXXX.XXXX.4615');
        System.AssertEquals(retorno[1].numeroCartaoSerno, '771086');
        System.AssertEquals(retorno[1].status, 'NORM');

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '36109070025');
    }

    @isTest
    public static void ListarCartoesErrorTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(422);
        responseCancelar.setBody('[{"numeroCartaoOfuscado":"5300.XXXX.XXXX.4692","numeroCartaoSerno":"851086","status":"NORM","ehPrimario":true,"nomeCartao":"ISADORA L GARCIA","nomePortador":"ISADORA LOPES GARCIA"}, {"numeroCartaoOfuscado":"1100.XXXX.XXXX.4615","numeroCartaoSerno":"771086","status":"NORM","ehPrimario":true,"nomeCartao":"ANDRE SANTOS","nomePortador":"ANDRE SANTOS VASCONCELOS"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000150419/cartoes/reimprimir-senha/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        
        Test.StartTest();
        List<ReimpressaoSenha.OutputListarCartoes> retorno = BCSF_ReimpressaoSenhaController.getListarCartoes('37000150419', '1', '36109070025', 'cockpit', 'ouvidoria');
        Test.StopTest();
        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Cartões - Reimpressão de Senha'];

        System.AssertEquals(retorno[0].StatusOK, 'ERROR');

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '36109070025');
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
        
        String contaFinanceiraId = cf.id;
        String accountId = acc.id;
        String unidadeNegocio = '1';
        String origem = 'Customer Support';
        String canal = 'E-mail';
        String evento = 'Atendimento';
        String assunto = 'Cancelamento de cartão de crédito';


        Test.StartTest();
        BCSF_ReimpressaoSenhaController.criarCaso(contaFinanceiraId, accountId, unidadeNegocio, origem, canal);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
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
        insert cf;

        Test.StartTest();
            BCSF_ReimpressaoSenhaBO.ContaFinanceiraTO rt =BCSF_ReimpressaoSenhaController.getContaFinanceira(cf.Id);
            String cpf = BCSF_CancelamentoContaBO.formatarCPF('11111111111');
        Test.StopTest();

        System.AssertEquals(cpf, '111.111.111-11');
        System.AssertEquals(rt.NumeroConta, '11111111111');
        System.AssertEquals(rt.Nome, 'Teste');
        System.AssertEquals(rt.CPF, '123.456.789-12');
        System.AssertEquals(rt.StatusConta, 'NORM');
    }

    @isTest
    public static void ReimpressaoSenhaHelperTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/39000002301/cartoes/741500/reimprimir-senha' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<ReimpressaoSenhaHelper.input> listInput = new List<ReimpressaoSenhaHelper.input>();
        ReimpressaoSenhaHelper.input input = new ReimpressaoSenhaHelper.input();
        input.numeroConta = '39000002301';
        input.idEmpresa = '1';
        input.cpf = '09825668830';
        input.canal = 'cockpit';
        input.area = 'ouvidoria';
        input.sistema = 'cockpit';
        input.CartaoSerno = ',741500,851086';
        input.CartaoOfuscado = ',5300.XXXX.XXXX.4692,1100.XXXX.XXXX.4615';
        input.CartaoEscolhido = 'ISADORA L GARCIA - 4692';
        listInput.add(input);

        Test.StartTest();
        List<String> retorno = ReimpressaoSenhaHelper.ReimprimirSenha(listInput);
        Test.StopTest();
        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Reimpressão de Senha'];

        System.AssertEquals(retorno[0], 'OK');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '09825668830');
    }

    @isTest
    public static void ReimpressaoListarCartoesHelperTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('[{"numeroCartaoOfuscado":"5300.XXXX.XXXX.4692","numeroCartaoSerno":"851086","status":"NORM","ehPrimario":true,"nomeCartao":"ISADORA L GARCIA","nomePortador":"ISADORA LOPES GARCIA"}, {"numeroCartaoOfuscado":"1100.XXXX.XXXX.4615","numeroCartaoSerno":"771086","status":"NORM","ehPrimario":true,"nomeCartao":"ANDRE SANTOS","nomePortador":"ANDRE SANTOS VASCONCELOS"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000150419/cartoes/reimprimir-senha/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        List<ReimpressaoListarCartoesHelper.Input> listInput = new List<ReimpressaoListarCartoesHelper.Input>();
        ReimpressaoListarCartoesHelper.Input input = new ReimpressaoListarCartoesHelper.Input();
        input.numeroConta = '37000150419';
        input.idEmpresa = '1';
        input.cpf = '36109070025';
        input.canal = 'cockpit';
        input.area = 'ouvidoria';
        listInput.add(input);
        
        Test.StartTest();
        List<ReimpressaoListarCartoesHelper.Output> retorno = ReimpressaoListarCartoesHelper.listarCartoes(listInput);
        Test.StopTest();
        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Cartões - Reimpressão de Senha'];

        System.AssertEquals(retorno[0].listaCartoes.size(), 2);
        System.AssertEquals(retorno[0].listCartaoSerno, ',851086,771086');
        System.AssertEquals(retorno[0].listCartaoOfuscado, ',5300.XXXX.XXXX.4692,1100.XXXX.XXXX.4615');
        System.AssertEquals(retorno[0].StatusOK, null);

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '36109070025');
    }
}