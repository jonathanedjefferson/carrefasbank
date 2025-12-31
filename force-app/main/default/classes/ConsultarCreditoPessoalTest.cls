/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ConsultarCreditoPessoal                           96%             *
*    - ConsultarCreditoPessoalHelper                     100%            *
**************************************************************************/


@isTest
private class ConsultarCreditoPessoalTest {

    @isTest
    public static void consultarCreditoPessoalTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(200);
        responseConsultar.setBody('{"resultado": {"descricao": "Operação realizada com sucesso.","sucesso": true},"saldoDisponivel": 15000,"limiteTotal": 15000}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/credito-pessoal-multicanal/consultar' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        ConsultarCreditoPessoal.ConsultaAPI retorno = ConsultarCreditoPessoal.consultarCreditoPessoal('000000000', '49926079857', '1', 'chat');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Consultar crédito Pessoal' LIMIT 1];

        System.AssertEquals(true, retorno.resultado.sucesso);
        System.AssertEquals('49926079857', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }

    @isTest
    public static void consultarCreditoHelperTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(404);
        responseConsultar.setBody('{"resultado": {"descricao": "Não possui saldo pré aprovado.","sucesso": false},"saldoDisponivel": 300,"limiteTotal": 15000}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/credito-pessoal-multicanal/consultar' => responseConsultar
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<ConsultarCreditoPessoalHelper.InputConsultaCredito> listItem = new List<ConsultarCreditoPessoalHelper.InputConsultaCredito>();
        ConsultarCreditoPessoalHelper.InputConsultaCredito item = new ConsultarCreditoPessoalHelper.InputConsultaCredito();
        item.canal = 'chat';
        item.cpf = '49926079857';
        item.idEmpresa = '1';
        item.numeroConta = '0000000000';
        listItem.add(item);

        Test.StartTest();
        List<ConsultarCreditoPessoalHelper.outputConsultaCredito> retorno = ConsultarCreditoPessoalHelper.consultarCreditoPessoal(listItem);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Consultar crédito Pessoal' LIMIT 1];

        System.AssertEquals(false, retorno[0].sucesso);
        System.AssertEquals('NAO ELEGIVEL', retorno[0].descricao);
        System.AssertEquals('49926079857', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }
}