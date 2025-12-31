/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - AlterarModoEnvioFatura                           94%              *
*    - BCSF_ModoEnvioFaturaBO                           90%              *
*    - BCSF_ModoEnvioFaturaController                   100%             *
*    - BCSF_ModoEnvioFaturaDAO                          100%             *
**************************************************************************/
@isTest
public class AlterarModoEnvioFaturaTest {
    @isTest
    public static void GetTiposEnvioFaturaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseTiposEnvio = new HttpResponse();
        responseTiposEnvio.setStatusCode(200);
        responseTiposEnvio.setBody('{"tiposEnvioFatura":[2,4,16]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1/conta/buscatiposenviofatura/chat' => responseTiposEnvio
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        AlterarModoEnvioFatura.OutputTiposEnvioFatura retorno = BCSF_ModoEnvioFaturaController.GetTiposEnvioFatura('chat', '11111111111', '1');
        Test.stopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Get Tipos de Envio Fatura' LIMIT 1];

        System.AssertEquals('OK', retorno.StatusAPI);
        System.AssertEquals(3, retorno.tiposEnvioFatura.size());
        System.AssertEquals(2, retorno.tiposEnvioFatura[0]);
        System.AssertEquals('11111111111', log.CPF__c);
        System.AssertEquals('GET', log.Metodo__c);
    }

    @isTest
    public static void UpdateTipoEnvioFaturaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseFatura = new HttpResponse();
        responseFatura.setStatusCode(200);
        responseFatura.setBody('{"valor":4,"descricao":"APP e Site"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1/conta/37000000598/tipoEnvioFatura/4' => responseFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        AlterarModoEnvioFatura.OutputUpdateModoEnvioFatura retorno = BCSF_ModoEnvioFaturaController.UpdateTipoEnvioFatura('1', 'cockpit', 'cockpit', 'desenvolvimento', '84531861540', '37000000598', '4', true);
        Test.stopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alterar Modo de Envio de Fatura' LIMIT 1];

        System.AssertEquals('OK', retorno.StatusAPI);
        System.AssertEquals(4, retorno.valor);
        System.AssertEquals('APP e Site', retorno.descricao);
        System.AssertEquals('84531861540', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }

    @isTest
    public static void UpdateEmailEnvioFaturaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseFatura = new HttpResponse();
        responseFatura.setStatusCode(200);
        responseFatura.setBody('{"email":"teste@gmail.com"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-alteracao-cadastral/api/v1/conta/37000000598/atualizar-email' => responseFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        AlterarModoEnvioFatura.OutputUpdateEmailEnvioFatura retorno = BCSF_ModoEnvioFaturaController.UpdateEmailEnvioFatura('1', 'cockpit', 'cockpit', 'desenvolvimento', '84531861540', '37000000598', 'teste@gmail.com');
        Test.stopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Update Email Para Envio de Fatura' LIMIT 1];

        System.AssertEquals('OK', retorno.StatusAPI);
        System.AssertEquals('teste@gmail.com', retorno.email);
        System.AssertEquals('84531861540', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }
    @isTest
    public static void getContaFinanceira(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Test.StartTest();
        BCSF_ModoEnvioFaturaBO.ContaFinanceiraTO rt = BCSF_ModoEnvioFaturaController.getContaFinanceira(cf.Id);
        String cpf = BCSF_ModoEnvioFaturaBO.formatarCPF('11111111111');
        Test.StopTest();

        System.AssertEquals(cpf, '11111111111'); 
        System.AssertEquals(rt.NumeroConta, '11111111111'); 
        System.AssertEquals(rt.CPF, '12345678912');  
        System.AssertEquals(rt.StatusConta, 'NORM');    
        System.assertEquals(rt.email, 'teste@exemplo.com');
    }
    @isTest
    public static void atualizaEmail(){
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.Id = cf.Id;
        cf.email__c = 'teste@exemplo.com';
        insert cf;

        Test.StartTest();
        BCSF_ModoEnvioFaturaController.atualizaEmail(cf.Id, 'newteste@exemplo.com');
        Test.StopTest();

    }
    @isTest
    public static void criarCaso(){
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
        String evento = 'Alteração  modo de envio da fatura';
        String tipoEnvio = 'Correio';

        Test.StartTest();
                BCSF_ModoEnvioFaturaController.criarCaso(contaFinanceiraId, accountId, unidadeNegocio, origem, canal,evento, tipoEnvio);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }
}