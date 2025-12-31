/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - DadosPagamentoHelper                                 100%         *
*    - EnvioFaturaHelper                                    100%         *
*    - GetLinkFaturaHelper                                  100%         *
*    - FaturasFechadasHelper                                98%          *
*    - FaturasFechadasWhatsappHelper                        98%          *
*    - RetornaValoresFaturasFechadasHelper                  97%          *
**************************************************************************/
@isTest
public class IntegracoesFaturasHelperTest {
    @isTest
    public static void UltimosVencimentosFechadosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseVencimentos = new HttpResponse();
        responseVencimentos.setStatusCode(200);
        responseVencimentos.setBody('[{"idFatura":13163763,"data":"2029-01-11T00:00:00"},{"idFatura":13115463,"data":"2029-02-11T00:00:00"},{"idFatura":13115163,"data":"2029-03-11T00:00:00"},{"idFatura":13115443,"data":"2029-04-11T00:00:00"},{"idFatura":13515463,"data":"2029-05-11T00:00:00"},{"idFatura":131615463,"data":"2029-06-11T00:00:00"},{"idFatura":73115463,"data":"2029-07-11T00:00:00"},{"idFatura":13185463,"data":"2029-08-11T00:00:00"},{"idFatura":13915463,"data":"2029-09-11T00:00:00"},{"idFatura":13101463,"data":"2029-10-11T00:00:00"},{"idFatura":13111163,"data":"2029-11-11T00:00:00"},{"idFatura":13115123,"data":"2029-12-11T00:00:00"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000198050/faturas/fechadas/ultimos-vencimentos' => responseVencimentos
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        FaturasFechadasHelper.InputVencimentosFechados aa = new FaturasFechadasHelper.InputVencimentosFechados();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';
        List<FaturasFechadasHelper.InputVencimentosFechados> listName = new List<FaturasFechadasHelper.InputVencimentosFechados>();
        listName.add(aa);

        List<FaturasFechadasHelper.OutputUltimosVencimentosFechados> retorno = FaturasFechadasHelper.UltimosVencimentosFechados(listName);
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Últimos Vencimentos Fechados'];

        List<String> listIdFatura = retorno[0].StringListIdFatura.split(',');
        List<String> listData = retorno[0].StringListData.split(',');
        List<String> listdataFormatado = retorno[0].StringListDataFormatado.split(',');

        System.debug('---> '+ retorno);
        System.AssertEquals(listIdFatura[1], '13163763');
        System.AssertEquals(listIdFatura[2], '13115463');
        System.AssertEquals(listData[1], '01-2029');
        System.AssertEquals(listData[2], '02-2029');
        System.AssertEquals(listdataFormatado[1], 'Janeiro/2029');
        System.AssertEquals(listdataFormatado[2], 'Fevereiro/2029');

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '31649927932');
    }

    @isTest
    public static void UltimosVencimentosFechadosWhatsappTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseVencimentos = new HttpResponse();
        responseVencimentos.setStatusCode(200);
        responseVencimentos.setBody('[{"idFatura":13163763,"data":"2029-01-11T00:00:00"},{"idFatura":13115463,"data":"2029-02-11T00:00:00"},{"idFatura":13115163,"data":"2029-03-11T00:00:00"},{"idFatura":13115443,"data":"2029-04-11T00:00:00"},{"idFatura":13515463,"data":"2029-05-11T00:00:00"},{"idFatura":131615463,"data":"2029-06-11T00:00:00"},{"idFatura":73115463,"data":"2029-07-11T00:00:00"},{"idFatura":13185463,"data":"2029-08-11T00:00:00"},{"idFatura":13915463,"data":"2029-09-11T00:00:00"},{"idFatura":13101463,"data":"2029-10-11T00:00:00"},{"idFatura":13111163,"data":"2029-11-11T00:00:00"},{"idFatura":13115123,"data":"2029-12-11T00:00:00"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000198050/faturas/fechadas/ultimos-vencimentos' => responseVencimentos
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        FaturasFechadasWhatsappHelper.InputVencimentosFechados aa = new FaturasFechadasWhatsappHelper.InputVencimentosFechados();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';
        List<FaturasFechadasWhatsappHelper.InputVencimentosFechados> listName = new List<FaturasFechadasWhatsappHelper.InputVencimentosFechados>();
        listName.add(aa);

        List<FaturasFechadasWhatsappHelper.OutputUltimosVencimentosFechados> retorno = FaturasFechadasWhatsappHelper.UltimosVencimentosFechados(listName);
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Últimos Vencimentos Fechados'];

        List<String> listIdFatura = retorno[0].StringListIdFatura.split(',');
        List<String> listData = retorno[0].StringListData.split(',');
        List<String> listdataFormatado = retorno[0].StringListDataFormatado.split(',');

        System.debug('---> '+ retorno);
        System.AssertEquals(listIdFatura[1], '13163763');
        System.AssertEquals(listIdFatura[2], '13115463');
        System.AssertEquals(listData[1], '01-2029');
        System.AssertEquals(listData[2], '02-2029');
        System.AssertEquals(listdataFormatado[1], 'Janeiro/2029');
        System.AssertEquals(listdataFormatado[2], 'Fevereiro/2029');

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
        DadosPagamentoHelper.InputDadosPagamentoFaturaFechada aa = new DadosPagamentoHelper.InputDadosPagamentoFaturaFechada();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.mesAnoVencimento = '01-2029';
        aa.canal = 'chat';

        List<DadosPagamentoHelper.InputDadosPagamentoFaturaFechada> listName = new List<DadosPagamentoHelper.InputDadosPagamentoFaturaFechada>();
        listName.add(aa);

        List<IntegracoesFaturas.OutputDadosPagamentoFaturaFechada> retorno = DadosPagamentoHelper.DadosPagamentoFaturaFechada(listName);
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Dados de Pagamento de Fatura Fechada'];

        System.AssertEquals(retorno[0].codigoBarras, '36890.00101 93002.898414 93001.000103 1 00000000000000 ');
        System.AssertEquals(retorno[0].linhaDigitavel, '30000.002694.001101.290001.000019.805050');

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
        EnvioFaturaHelper.InputEnvioFaturaPorEmail aa = new EnvioFaturaHelper.InputEnvioFaturaPorEmail();
        aa.numeroConta = '10000198050';
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.mesRefFatura = '01-2029';
        aa.emailParaEnvio = 'teste_ext@carrefour.com';
        aa.idFatura = 13163763;
        aa.canal = 'chat';

        List<EnvioFaturaHelper.InputEnvioFaturaPorEmail> listName = new List<EnvioFaturaHelper.InputEnvioFaturaPorEmail>();
        listName.add(aa);

        List<Boolean> retorno = EnvioFaturaHelper.EnvioFaturaPorEmail(listName);
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Envio de Fatura por E-mail'];

        System.AssertEquals(retorno[0], true);

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '31649927932');
    }

    @isTest
    public static void RetornaValoresFaturasFechadasTest(){
        RetornaValoresFaturasFechadasHelper.InputValores input = new RetornaValoresFaturasFechadasHelper.InputValores();
        List<RetornaValoresFaturasFechadasHelper.InputValores> listInput = new List<RetornaValoresFaturasFechadasHelper.InputValores>();
        input.StringListIdFatura = '12345678,13163763';
        input.StringListData = '01-2029,02-2029';
        input.StringListDataFormatado = 'Janeiro/2029,Fevereiro/2029,Outros';
        input.dataFormatadaEscolhida = 'Fevereiro/2029';
        input.codigoBarras = '1';
        
        listInput.add(input);
        
        RetornaValoresFaturasFechadasHelper.InputValores input2 = new RetornaValoresFaturasFechadasHelper.InputValores();
        List<RetornaValoresFaturasFechadasHelper.InputValores> listInput2 = new List<RetornaValoresFaturasFechadasHelper.InputValores>();
        input2.StringListIdFatura = '12345678,13163763';
        input2.StringListData = '01-2029,02-2029';
        input2.StringListDataFormatado = 'Janeiro/2029,Fevereiro/2029,Outros';
        input2.dataFormatadaEscolhida = 'Fevereiro/2029';
        input2.codigoBarras = '2';

        listInput2.add(input2);

        Test.StartTest();
        List<RetornaValoresFaturasFechadasHelper.OutputValores> retorno = RetornaValoresFaturasFechadasHelper.RetornaValores(listInput);
        List<RetornaValoresFaturasFechadasHelper.OutputValores> retorno2 = RetornaValoresFaturasFechadasHelper.RetornaValores(listInput2);
        Test.StopTest();
        
        System.AssertEquals(retorno2[0].idFatura, 13163763);
        System.AssertEquals(retorno2[0].data, '02-2029');
        System.AssertEquals(retorno2[0].dataFormatado, 'Fevereiro/2029');
        System.AssertEquals(retorno2[0].posicaoEscolhida, 1);

        System.AssertEquals(retorno[0].idFatura, 13163763);
        System.AssertEquals(retorno[0].data, '02-2029');
        System.AssertEquals(retorno[0].dataFormatado, 'Fevereiro/2029');
        System.AssertEquals(retorno[0].posicaoEscolhida, 0);
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
        List<GetLinkFaturaHelper.Input> listName = new List<GetLinkFaturaHelper.Input>();
        GetLinkFaturaHelper.Input input = new GetLinkFaturaHelper.Input();
        input.numeroConta = '10000019496';
        input.idEmpresa = '1';
        input.cpf = '49926079857';
        input.mesRefFatura = '07-2028';
        input.canal = 'whatsapp'; 
        listName.add(input);

        List<IntegracoesFaturas.OutputGetLinkFatura> retorno = GetLinkFaturaHelper.GetLinkFatura(listName);
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Get Link Fatura'];
        System.AssertEquals(retorno[0].StatusAPI, 'OK');
        System.AssertEquals(retorno[0].link, 'https://www.url-link.com/link-arquivo');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '49926079857');
    }
}