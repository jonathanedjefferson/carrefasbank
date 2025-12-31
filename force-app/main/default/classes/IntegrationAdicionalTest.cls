/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - IntegrationAdicional                       100%                   *
**************************************************************************/
@isTest
public class IntegrationAdicionalTest {
    @isTest
    public static void SolicitarCartaoAdicionalSucesso() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1/cartao/contas/37000076341/cartaoadicional' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        String cpfCliente = '77487424723';
        String numeroConta = '37000076341';
        String canal = 'cockpit';
        String area = 'pos_vendas';
        String sistema = 'cockpit';
        String unidadeNegocio = '1';
        String cpfAdicional = '14194755766';
        String nomeAdicional = 'Teste 123';
        String sexoAdicional = 'F';
        String dataNascimentoAdicional = '1960-02-07';

        IntegrationAdicional.OutputSolicitarCartaoAdicional retorno = IntegrationAdicional.SolicitarCartaoAdicional(cpfCliente, numeroConta, canal, area, sistema, unidadeNegocio, cpfAdicional, nomeAdicional, sexoAdicional, dataNascimentoAdicional);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Solicitar Cartão Adicional' LIMIT 1];

        System.AssertEquals(retorno.StatusAPI, 'OK');
        System.AssertEquals(log.CPF__c, '77487424723');
        System.AssertEquals(log.Metodo__c, 'POST');
    }

    @isTest
    public static void SolicitarCartaoAdicionalErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(422);
        responseAPI.setBody('Cartao sem status de permissao para fazer inclusão de adicional');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1/cartao/contas/37000076341/cartaoadicional' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        String cpfCliente = '77487424723';
        String numeroConta = '37000076341';
        String canal = 'cockpit';
        String area = 'pos_vendas';
        String sistema = 'cockpit';
        String unidadeNegocio = '1';
        String cpfAdicional = '14194755766';
        String nomeAdicional = 'Teste 123';
        String sexoAdicional = 'F';
        String dataNascimentoAdicional = '1960-02-07';

        IntegrationAdicional.OutputSolicitarCartaoAdicional retorno = IntegrationAdicional.SolicitarCartaoAdicional(cpfCliente, numeroConta, canal, area, sistema, unidadeNegocio, cpfAdicional, nomeAdicional, sexoAdicional, dataNascimentoAdicional);
        
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Solicitar Cartão Adicional' LIMIT 1];

        System.AssertEquals(retorno.StatusAPI, 'ERROR_422');
        System.AssertEquals(retorno.Mensagem, 'Cartao sem status de permissao para fazer inclusão de adicional');
        System.AssertEquals(log.CPF__c, '77487424723');
        System.AssertEquals(log.Metodo__c, 'POST');
    }
}