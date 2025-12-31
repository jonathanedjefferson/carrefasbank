/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceListarTiposEnvioFatura                            94%    *
*    - InterfaceAlterarTipoEnvioFatura                            93%    *
*    - TipoEnvioFaturaDAO                                         100%   *
**************************************************************************/

@isTest
public class InterfaceListarTiposEnvioFaturaTest {

    @isTest
    public static void ListarTiposEnvioFaturaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"tiposEnvioFatura": [2,4,16]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-tipo-envio-fatura/api/v1/conta/buscatiposenviofatura/whatsapp' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarTiposEnvioFatura.RequestListarTiposEnvioFatura request = new InterfaceListarTiposEnvioFatura.RequestListarTiposEnvioFatura();   
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'whatsapp';

        List<InterfaceListarTiposEnvioFatura.RequestListarTiposEnvioFatura> requestList  = new List<InterfaceListarTiposEnvioFatura.RequestListarTiposEnvioFatura>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarTiposEnvioFatura.ResponseListarTiposEnvioFatura> retornoList = InterfaceListarTiposEnvioFatura.ListarTiposEnvioFatura(requestList);
        Test.StopTest();
        
        InterfaceListarTiposEnvioFatura.ResponseListarTiposEnvioFatura retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.assertNotEquals(null, retorno.tiposEnvioFatura);
    }
    
    @isTest
    public static void AlterarTipoEnvioFaturaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"valor":2,"descricao":"Email"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-tipo-envio-fatura/api/v1/conta/37000001661/tipoEnvioFatura/2' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAlterarTipoEnvioFatura.RequestAlterarTiposEnvioFatura request = new InterfaceAlterarTipoEnvioFatura.RequestAlterarTiposEnvioFatura();   
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'whatsapp';
        request.numeroConta = '37000001661';
        request.tipoEnvioFatura = '2';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceAlterarTipoEnvioFatura.RequestAlterarTiposEnvioFatura> requestList  = new List<InterfaceAlterarTipoEnvioFatura.RequestAlterarTiposEnvioFatura>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceAlterarTipoEnvioFatura.ResponseAlterarTiposEnvioFatura> retornoList = InterfaceAlterarTipoEnvioFatura.AlterarTipoEnvioFatura(requestList);
        Test.StopTest();
        
        InterfaceAlterarTipoEnvioFatura.ResponseAlterarTiposEnvioFatura retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
    }
   

}