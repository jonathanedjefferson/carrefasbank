/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceBoletoAcordoDivida                             100%      *
**************************************************************************/

@isTest
public class InterfaceBoletoAcordoDividaTest {

    @isTest
    public static void ObterBoletoAcordoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseObterBoleto= new HttpResponse();
        responseObterBoleto.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/boleto/enviar' => responseObterBoleto
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceBoletoAcordoDivida.RequestObterBoleto requestObterBoleto = new InterfaceBoletoAcordoDivida.RequestObterBoleto();      
        requestObterBoleto.idEmpresa = '1';
        requestObterBoleto.cpf = '79413706387';
        requestObterBoleto.identificadorAcordo = 'jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=';
        requestObterBoleto.canal = 'chat';
        
        List<InterfaceBoletoAcordoDivida.RequestObterBoleto> requestAcordoList = new List<InterfaceBoletoAcordoDivida.RequestObterBoleto>();
        requestAcordoList.add(requestObterBoleto);
        
        Test.StartTest();
        List<InterfaceBoletoAcordoDivida.ResponseObterBoleto> retorno = InterfaceBoletoAcordoDivida.ObterBoletoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusChamada);
    }
    
    
    @isTest
    public static void ObterBoletoAcordoErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseObterBoleto= new HttpResponse();
        responseObterBoleto.setStatusCode(404);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/boleto/enviar' => responseObterBoleto
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceBoletoAcordoDivida.RequestObterBoleto requestObterBoleto = new InterfaceBoletoAcordoDivida.RequestObterBoleto();      
        requestObterBoleto.idEmpresa = '1';
        requestObterBoleto.cpf = '79413706387';
        requestObterBoleto.identificadorAcordo = 'jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=';
        requestObterBoleto.canal = 'chat';
        
        List<InterfaceBoletoAcordoDivida.RequestObterBoleto> requestAcordoList = new List<InterfaceBoletoAcordoDivida.RequestObterBoleto>();
        requestAcordoList.add(requestObterBoleto);
        
        Test.StartTest();
        List<InterfaceBoletoAcordoDivida.ResponseObterBoleto> retorno = InterfaceBoletoAcordoDivida.ObterBoletoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('ERRO', retorno.get(0).statusChamada);
    }
}