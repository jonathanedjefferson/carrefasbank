/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceBloqueioConta                             100%           *
**************************************************************************/

@isTest
public class InterfaceBloqueioContaTest {
    @isTest
    public static void BloquearConta() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/bloquear' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceBloqueioConta.RequestBloquear requestBloquear = new InterfaceBloqueioConta.RequestBloquear();      
        requestBloquear.idEmpresa = '1';
        requestBloquear.sistema = 'cockpit';
        requestBloquear.canal = 'cockpit';
        requestBloquear.area = 'Ouvidoria';
        requestBloquear.cpf = '49926079857';
        requestBloquear.numeroConta = '10000019496';
        requestBloquear.novoStatus = 'CLSC';
        
        List<InterfaceBloqueioConta.RequestBloquear> requestBloquearList = new List<InterfaceBloqueioConta.RequestBloquear>();
        requestBloquearList.add(requestBloquear);
        
        Test.StartTest();
        List<InterfaceBloqueioConta.ResponseBloquear> retorno = InterfaceBloqueioConta.BloquearConta(requestBloquearList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).bloqueadoSucesso);
    }
    
    @isTest
    public static void BloquearContaErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(500);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/711243/bloquear' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceBloqueioConta.RequestBloquear requestBloquear = new InterfaceBloqueioConta.RequestBloquear();      
        requestBloquear.idEmpresa = '1';
        requestBloquear.sistema = 'cockpit';
        requestBloquear.canal = 'cockpit';
        requestBloquear.area = 'Ouvidoria';
        requestBloquear.cpf = '49926079850';
        requestBloquear.numeroConta = '10000019496';
        requestBloquear.novoStatus = 'CLSC';
        
        List<InterfaceBloqueioConta.RequestBloquear> requestBloquearList = new List<InterfaceBloqueioConta.RequestBloquear>();
        requestBloquearList.add(requestBloquear);
        
        Test.StartTest();
        List<InterfaceBloqueioConta.ResponseBloquear> retorno = InterfaceBloqueioConta.BloquearConta(requestBloquearList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('ERRO', retorno.get(0).bloqueadoSucesso);
    }
    
}