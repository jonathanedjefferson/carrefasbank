/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceValidarClienteAcordo                             100%    *
**************************************************************************/

@isTest
public class InterfaceValidarClienteAcordoTest {
    @isTest
    public static void ValidarClienteAcordoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseValidar = new HttpResponse();
        responseValidar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/cliente/validar' => responseValidar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceValidarClienteAcordo.RequestValidarCliente requestValidarCliente = new InterfaceValidarClienteAcordo.RequestValidarCliente();      
        requestValidarCliente.idEmpresa = '1';
        requestValidarCliente.cpf = '79413706387';
        requestValidarCliente.dataNascimento = '01/10/1990';
        requestValidarCliente.identificador = 'jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=';
        requestValidarCliente.canal = 'chat';
        
        List<InterfaceValidarClienteAcordo.RequestValidarCliente> requestValidarClienteList = new List<InterfaceValidarClienteAcordo.RequestValidarCliente>();
        requestValidarClienteList.add(requestValidarCliente);
        
        Test.StartTest();
        List<InterfaceValidarClienteAcordo.ResponseValidarCliente> retorno = InterfaceValidarClienteAcordo.ValidarClienteAcordo(requestValidarClienteList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).Status);
    }   
    
    @isTest
    public static void ValidarClienteAcordoInvalidoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseValidar = new HttpResponse();
        responseValidar.setStatusCode(422);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/cliente/validar' => responseValidar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceValidarClienteAcordo.RequestValidarCliente requestValidarCliente = new InterfaceValidarClienteAcordo.RequestValidarCliente();      
        requestValidarCliente.idEmpresa = '1';
        requestValidarCliente.cpf = '79413706387';
        requestValidarCliente.dataNascimento = '01/10/1990';
        requestValidarCliente.identificador = 'jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=';
        requestValidarCliente.canal = 'chat';
        
        List<InterfaceValidarClienteAcordo.RequestValidarCliente> requestValidarClienteList = new List<InterfaceValidarClienteAcordo.RequestValidarCliente>();
        requestValidarClienteList.add(requestValidarCliente);
        
        Test.StartTest();
        List<InterfaceValidarClienteAcordo.ResponseValidarCliente> retorno = InterfaceValidarClienteAcordo.ValidarClienteAcordo(requestValidarClienteList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('Data Incorreta', retorno.get(0).Status);
    }  
    
    @isTest
    public static void ValidarClienteAcordoDataInvalidaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseValidar = new HttpResponse();
        responseValidar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/cliente/validar' => responseValidar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceValidarClienteAcordo.RequestValidarCliente requestValidarCliente = new InterfaceValidarClienteAcordo.RequestValidarCliente();      
        requestValidarCliente.idEmpresa = '1';
        requestValidarCliente.cpf = '79413706387';
        requestValidarCliente.dataNascimento = '01101990';
        requestValidarCliente.identificador = 'jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=';
        requestValidarCliente.canal = 'chat';
        
        List<InterfaceValidarClienteAcordo.RequestValidarCliente> requestValidarClienteList = new List<InterfaceValidarClienteAcordo.RequestValidarCliente>();
        requestValidarClienteList.add(requestValidarCliente);
        
        Test.StartTest();
        List<InterfaceValidarClienteAcordo.ResponseValidarCliente> retorno = InterfaceValidarClienteAcordo.ValidarClienteAcordo(requestValidarClienteList);
        Test.StopTest();
        
        System.AssertEquals(0, retorno.size());
    }  
    
}