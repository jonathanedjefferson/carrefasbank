/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - DesbloqueioCartao                             99%                 *
**************************************************************************/

@isTest
public class DesbloqueioCartaoTest {
    @isTest
    public static void DesbloquearCartaoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/711243/desbloquear' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        Boolean retorno = DesbloqueioCartao.DesbloquearCartao('1', 'cockpit', 'cockpit', 'Ouvidoria', '49926079857', '10000019496', '711243');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Desbloquear Cartão' LIMIT 1];

        System.AssertEquals(true, retorno);
        System.AssertEquals('49926079857', log.CPF__c);
        System.AssertEquals('PATCH', log.Metodo__c);
    }


    @isTest
    public static void ListCartoesParaDesbloqueioTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('[{"numeroCartaoOfuscado": "5438.XXXX.XXXX.9799","numeroCartaoSerno": "711243","status": "BLCK","ehPrimario": true,"nomeCartao": "BENJAMIN B ANDRADE","nomePortador": "BENJAMIN BARBOSA ANDRADE"},{"numeroCartaoOfuscado": "5438.XXXX.XXXX.3546","numeroCartaoSerno": "722796","status": "NORM","ehPrimario": false,"nomeCartao": "JULIANA SOUZA","nomePortador": "JULIANA SOUZA"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/desbloquear/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        List<DesbloqueioCartao.OutputListCartoesParaDesbloqueio> output = DesbloqueioCartao.ListCartoesParaDesbloqueio('cockpit', 'Ouvidoria', '49926079857', '10000019496');
        Test.StopTest();

        System.AssertEquals('BLCK', output[0].status);
        System.AssertEquals('NORM', output[1].status);
    }
}