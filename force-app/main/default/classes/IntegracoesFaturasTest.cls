/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - IntegracoesFaturas                                96%             *
**************************************************************************/
@isTest
public class IntegracoesFaturasTest {
    @isTest
    public static void UltimosVencimentosFechadosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseVencimentos = new HttpResponse();
        responseVencimentos.setStatusCode(200);
        responseVencimentos.setBody('[{"idFatura":13163763,"data":"2029-01-11T00:00:00"},{"idFatura":13115463,"data":"2029-02-11T00:00:00"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000198050/faturas/fechadas/ultimos-vencimentos' => responseVencimentos
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        List<BCSF_SegundaViaFaturaBO.OutputUltimosVencimentosFechados> retorno = BCSF_SegundaViaFaturaController.getListaFaturas('10000198050', '2', '31649927932', 'chat');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Últimos Vencimentos Fechados'];

        System.AssertEquals(retorno[0].idFatura, 13163763);
        System.AssertEquals(retorno[1].idFatura, 13115463);

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '31649927932');
    }
    
    @isTest
    public static void DadosPagamentoFaturaFechadaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseDadosPagamento = new HttpResponse();
        responseDadosPagamento.setStatusCode(200);
        responseDadosPagamento.setBody('{"codigoBarras":"36890.00101 93002.898414 93001.000103 1 00000000000000 ","linhaDigitavel":"30000.002694.001101.290001.000019.805050"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000198050/faturas/fechadas/01-2029/dados-pagamento' => responseDadosPagamento
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracoesFaturas.OutputDadosPagamentoFaturaFechada retorno = IntegracoesFaturas.DadosPagamentoFaturaFechada('10000198050', '2', '31649927932', '01-2029', 'chat');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Dados de Pagamento de Fatura Fechada'];

        System.AssertEquals(retorno.codigoBarras, '36890.00101 93002.898414 93001.000103 1 00000000000000 ');
        System.AssertEquals(retorno.linhaDigitavel, '30000.002694.001101.290001.000019.805050');

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '31649927932');
    }

    @isTest
    public static void EnvioFaturaPorEmailTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseEnvioFatura = new HttpResponse();
        responseEnvioFatura.setStatusCode(200);
        responseEnvioFatura.setBody('[{"idFatura":13163763,"data":"2029-01-11T00:00:00"},{"idFatura":13115463,"data":"2029-02-11T00:00:00"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000198050/faturas/01-2029/envioemail?Email=teste_ext@carrefour.com' => responseEnvioFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        Boolean retorno = IntegracoesFaturas.EnvioFaturaPorEmail('10000198050', '2', '31649927932', '01-2029', 'teste_ext@carrefour.com', '13163763', 'chat');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Envio de Fatura por E-mail'];

        System.AssertEquals(retorno, true);

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '31649927932');
    }

    @isTest
    public static void EnvioMultiplasFaturasPorEmailTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseEnvioFatura = new HttpResponse();
        responseEnvioFatura.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/envio-faturas/37000027922/enviar-lista-faturas' => responseEnvioFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        Test.StartTest();
        Map<String, String> MapIdStringFaturas = new Map<String, String>();
        MapIdStringFaturas.put('123456', '2025-01-01T00:00:00'); 
        MapIdStringFaturas.put('123465', '2025-01-01T00:00:00'); 

        Boolean retorno = IntegracoesFaturas.EnvioMultiplasFaturasPorEmail('1', 'ouvidoria', 'cockpit', 'ouvidoria', '26813963791', '37000027922', 'teste@carrefour.com', MapIdStringFaturas);
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Envio de Multiplas Faturas Por Email'];

        System.AssertEquals(retorno, true);

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '26813963791');
    }

    @isTest
    public static void GetLinkFaturaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseEnvioFatura = new HttpResponse();
        responseEnvioFatura.setStatusCode(200);
        responseEnvioFatura.setBody('{"link": "https://www.url-link.com/link-arquivo"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/servicecloud-link-fatura/linkarquivo' => responseEnvioFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();

        IntegracoesFaturas.OutputGetLinkFatura retorno = IntegracoesFaturas.GetLinkFatura('10000019496', '1', '49926079857', '07-2028', 'whatsapp');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Get Link Fatura'];
        System.AssertEquals(retorno.StatusAPI, 'OK');
        System.AssertEquals(retorno.link, 'https://www.url-link.com/link-arquivo');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '49926079857');
    }

    @isTest
    public static void GetDataVencimentoFaturaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseGetDataVencimentoFatura = new HttpResponse();
        responseGetDataVencimentoFatura.setStatusCode(200);
        responseGetDataVencimentoFatura.setBody('{"listaDiasVencimento":[],"alteracaoPermitida":false,"dataUltimaAlteracao":"2024-04-09T09:36:35","dataVencimento":"2027-04-21T00:00:00-03:00","dataFechamento":"2027-04-08T00:00:00-03:00"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000035179/faturas/lista-data-vencimento' => responseGetDataVencimentoFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();

        IntegracoesFaturas.OutputGetDataVencimentoFatura retorno = IntegracoesFaturas.GetDataVencimentoFatura('23117497498', '10000035179', 'chat', '1');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Obter Data de Vencimento de Fatura'];
        System.AssertEquals(retorno.StatusAPI, 'OK');
        System.AssertEquals(retorno.dataUltimaAlteracao, '2024-04-09T09:36:35');
        System.AssertEquals(retorno.dataVencimento,'2027-04-21T00:00:00-03:00');
        System.AssertEquals(retorno.dataFechamento,'2027-04-08T00:00:00-03:00');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '23117497498');
    }

    @isTest
    public static void AlterarVencimentoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseAlterarVencimento = new HttpResponse();
        responseAlterarVencimento.setStatusCode(200);
        responseAlterarVencimento.setBody('{"dataVencimento":"2027-03-21T00:00:00-03:00","dataFechamento":"2027-03-08T00:00:00-03:00"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000035179/faturas/alterar-data-vencimento' => responseAlterarVencimento
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();

        IntegracoesFaturas.OutputAlterarVencimento retorno = IntegracoesFaturas.AlterarVencimento('23117497498', '10000035179', 'cockpit', 'ouvidoria', 'ouvidoria', '1', '25');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alteração de Vencimento'];
        System.AssertEquals(retorno.StatusAPI, 'OK');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '23117497498');
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
        BCSF_SegundaViaFaturaController.createCase(cf.Id, acc.Id, '1', 'Ouvidoria', 'Whatsapp', 'OUTROS', 'Teste');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void faturasResumidasSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockFaturasResumidas');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        StatusPagamentoFaturaHelper.InputStatusPagamentoFatura aa = new StatusPagamentoFaturaHelper.InputStatusPagamentoFatura();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';

        List<StatusPagamentoFaturaHelper.InputStatusPagamentoFatura> listName = new List<StatusPagamentoFaturaHelper.InputStatusPagamentoFatura>();
        listName.add(aa);

        List<IntegracoesFaturas.OutputFaturaResumida> retorno = StatusPagamentoFaturaHelper.statusPagamentoFatura(listName);
        Test.StopTest();

        System.assertEquals('OK', retorno[0].statusReponse);
        System.assertEquals(1, retorno.size());
        System.assertEquals(true, retorno[0].ultimaFechada);
    }

    @isTest
    public static void faturasResumidasSucesso2Test() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockFaturasResumidasAlternativo');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        StatusPagamentoFaturaHelper.InputStatusPagamentoFatura aa = new StatusPagamentoFaturaHelper.InputStatusPagamentoFatura();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';

        List<StatusPagamentoFaturaHelper.InputStatusPagamentoFatura> listName = new List<StatusPagamentoFaturaHelper.InputStatusPagamentoFatura>();
        listName.add(aa);

        List<IntegracoesFaturas.OutputFaturaResumida> retorno = StatusPagamentoFaturaHelper.statusPagamentoFatura(listName);
        Test.StopTest();

        System.assertEquals('OK', retorno[0].statusReponse);
        System.assertEquals(1, retorno.size());
        System.assertEquals(false, retorno[0].ultimaFechada);
    }

    @isTest
    public static void faturasResumidasErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockFaturasResumidas');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        StatusPagamentoFaturaHelper.InputStatusPagamentoFatura aa = new StatusPagamentoFaturaHelper.InputStatusPagamentoFatura();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';

        List<StatusPagamentoFaturaHelper.InputStatusPagamentoFatura> listName = new List<StatusPagamentoFaturaHelper.InputStatusPagamentoFatura>();
        listName.add(aa);

        List<IntegracoesFaturas.OutputFaturaResumida> retorno = StatusPagamentoFaturaHelper.statusPagamentoFatura(listName);
        Test.StopTest();

        System.assertEquals('ERROR', retorno[0].statusReponse);
    }

}