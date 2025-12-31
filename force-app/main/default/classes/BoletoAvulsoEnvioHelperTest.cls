/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BoletoAvulsoEnvioHelper              100%                         *
**************************************************************************/
@isTest
public class BoletoAvulsoEnvioHelperTest {
    @isTest
    public static void enviarBoletoOkTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseEnvioBoletoAvulso = new HttpResponse();
        responseEnvioBoletoAvulso.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/enviar-email' => responseEnvioBoletoAvulso
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoEnvioHelper.InputEnvioBoleto> lstInput = new List<BoletoAvulsoEnvioHelper.InputEnvioBoleto>();
        BoletoAvulsoEnvioHelper.InputEnvioBoleto inputs = new BoletoAvulsoEnvioHelper.InputEnvioBoleto();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.email = 'teste@carrefour.com';
        inputs.idBoleto = '141840';
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);


        Test.StartTest();
        List<BoletoAvulsoEnvioHelper.OutputEnvioBoleto> output = BoletoAvulsoEnvioHelper.enviarBoleto(lstInput);
        Test.StopTest();

        Assert.areEqual('OK', output[0].statusAPI, 'O status da API deve ser OK');
    }

    @isTest
    public static void enviarBoletoErrorTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseEnvioBoletoAvulso = new HttpResponse();
        responseEnvioBoletoAvulso.setStatusCode(400);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/enviar-email' => responseEnvioBoletoAvulso
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoEnvioHelper.InputEnvioBoleto> lstInput = new List<BoletoAvulsoEnvioHelper.InputEnvioBoleto>();
        BoletoAvulsoEnvioHelper.InputEnvioBoleto inputs = new BoletoAvulsoEnvioHelper.InputEnvioBoleto();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.email = 'teste@carrefour.com';
        inputs.idBoleto = '141840';
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);


        Test.StartTest();
        List<BoletoAvulsoEnvioHelper.OutputEnvioBoleto> output = BoletoAvulsoEnvioHelper.enviarBoleto(lstInput);
        Test.StopTest();

        Assert.areEqual('ERROR', output[0].statusAPI, 'O status da API deve ser ERROR');
    }
}