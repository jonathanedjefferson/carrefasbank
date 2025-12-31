/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BoletoAvulsoHelper                   100%                         *
**************************************************************************/
@isTest
public class BoletoAvulsoHelperTest {
    @isTest
    public static void gerarBoletoAvulsoOkTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseGerarBoletoAvulso = new HttpResponse();
        responseGerarBoletoAvulso.setStatusCode(200);
        responseGerarBoletoAvulso.setBody('{ "codigoBarras": "36891987700000000000001263000633289100100010", "linhaDigitavel": "36890.00122 63000.633283 91001.000107 1 98770000000000", "linhaDigitavelCarrefour": "40000.000000.002210.240001.000004.561656", "dataVencimentoBoleto": "2024-10-22", "indicadorBoletoRegistrado": true, "boletoHtml" : "GNvbGxhcHNlO3dpZHRoOiAxMDAlO30NCgkgIC5ib3JkYXNEYXNURHN7Ym9yZGVyLWxlZnQ6IDFweCBzb2xpZCBibGFjaztib3JkZXItcmlnaHQ6IDFweCBzb2xpZCBibGFjazt9DQo", "boletoPdf": "JVBERi0xLjQKJdPr6eEKMSAwIG9iago8PC9DcmVhdG9yIChDaHJvbWl1bSkKL1Byb2R1Y2VyIChTa2lhL1BERiBtMTIwKQovQ3JlYXRpb25EYXRl" }');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/avulso' => responseGerarBoletoAvulso
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoHelper.InputGerarBoleto> lstInput = new List<BoletoAvulsoHelper.InputGerarBoleto>();
        BoletoAvulsoHelper.InputGerarBoleto inputs = new BoletoAvulsoHelper.InputGerarBoleto();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.email = '';
        inputs.valorBoleto = '50';
        inputs.tipoBoleto = 2;
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);


        Test.StartTest();
        List<BoletoAvulsoHelper.OutputGerarBoleto> output = BoletoAvulsoHelper.gerarBoletoAvulso(lstInput);
        Test.StopTest();

        Assert.areEqual('OK', output[0].statusAPI, 'O status da API deve ser OK');
        Assert.areEqual('36891987700000000000001263000633289100100010', output[0].codigoBarras, 'O código de barras deve ser o mesmo configurado no retorno do mock');
        Assert.areEqual('22/10/2024', output[0].dataVencimentoBoleto, 'a data deve ser retornada formatada');
    }

     @isTest
    public static void gerarBoletoAvulsoErrorTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseGerarBoletoAvulso = new HttpResponse();
        responseGerarBoletoAvulso.setStatusCode(400);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/avulso' => responseGerarBoletoAvulso
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoHelper.InputGerarBoleto> lstInput = new List<BoletoAvulsoHelper.InputGerarBoleto>();
        BoletoAvulsoHelper.InputGerarBoleto inputs = new BoletoAvulsoHelper.InputGerarBoleto();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.email = '';
        inputs.valorBoleto = '50';
        inputs.tipoBoleto = 2;
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);


        Test.StartTest();
        List<BoletoAvulsoHelper.OutputGerarBoleto> output = BoletoAvulsoHelper.gerarBoletoAvulso(lstInput);
        Test.StopTest();

        Assert.areEqual('ERROR', output[0].statusAPI, 'O status da API deve ser ERROR');
    }
}