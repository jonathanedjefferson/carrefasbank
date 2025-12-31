/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BoletoAvulsoParametrosHelper       100%                           *
**************************************************************************/
@isTest
public class BoletoAvulsoParametrosHelperTest {
    
    @isTest
    public static void obterParametrosIniciaisOkTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseParametrosIniciais = new HttpResponse();
        responseParametrosIniciais.setStatusCode(200);
        responseParametrosIniciais.setBody('{"valorMinimo": 10.00, "valorMaximo": 10485.1, "boletosValidos": [ { "id": 141833, "codigoBarras": "36893987700000000000001263000559495900100020", "linhaDigitavel": "36890.00122 63000.559493 59001.000200 3 98770000000000", "dataEmissao": "2024-10-17T09:27:24.053", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141834, "codigoBarras": "36897987700000000000001263000557274700100020", "linhaDigitavel": "36890.00122 63000.557275 47001.000201 7 98770000000000", "dataEmissao": "2024-10-17T09:38:18.133", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141835, "codigoBarras": "36893987700000000000001263000559619300100020", "linhaDigitavel": "36890.00122 63000.559611 93001.000202 3 98770000000000", "dataEmissao": "2024-10-17T10:08:53.57", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141838, "codigoBarras": "36891987700000000000001263000633289100100010", "linhaDigitavel": "36890.00122 63000.633283 91001.000107 1 98770000000000", "dataEmissao": "2024-10-17T14:49:24.797", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141839, "codigoBarras": "36899987700000000000001263000633412500100010", "linhaDigitavel": "36890.00122 63000.633411 25001.000104 9 98770000000000", "dataEmissao": "2024-10-17T15:03:47.5", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 40.00 }, { "id": 141840, "codigoBarras": "36891987700000000000001263000633535900100010", "linhaDigitavel": "36890.00122 63000.633536 59001.000101 1 98770000000000", "dataEmissao": "2024-10-17T15:10:57.91", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 45.00 } ]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/avulso/parametros-iniciais' => responseParametrosIniciais
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoParametrosHelper.InputParametrosIniciais> lstInput = new List<BoletoAvulsoParametrosHelper.InputParametrosIniciais>();
        BoletoAvulsoParametrosHelper.InputParametrosIniciais inputs = new BoletoAvulsoParametrosHelper.InputParametrosIniciais();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);

        Test.StartTest();
        List<BoletoAvulsoParametrosHelper.OutputParametrosIniciais> output = BoletoAvulsoParametrosHelper.obterParametrosIniciais(lstInput);
        Test.StopTest();

        Assert.areEqual('OK', output[0].statusAPI, 'O status da API deve ser OK');
        Assert.areEqual('10.00', output[0].valorMinimo, 'O valor minimo deve ser o mesmo do mock');
        Assert.areEqual('10485.10', output[0].valorMaximo, 'O valor maximo deve ser o mesmo do mock com 2 casas decimais');
        Assert.isFalse(output[0].saldoDevedorInsuficiente, 'O saldo devedor do caso de teste não é insuficiente');
        Assert.isTrue(output[0].possuiBoletoEmitido, 'O caso de teste possui boletos emitidos');
        Assert.areEqual('141840', output[0].idUltimoBoletoEitido, 'O id deve ser do boleto mais recente no mock');
        Assert.areEqual('36891987700000000000001263000633535900100010', output[0].codigoBarrasUltimoBoleto, 'O código de barras deve ser do boleto mais recente no mock');
        Assert.areEqual('22/10/2024', output[0].dataVencimentoUltimoBoleto, 'O código data deve ser do boleto mais recente no mock');
        Assert.areEqual('45.00', output[0].valorUltimoBoleto, 'O valor deve ser do boleto mais recente no mock');
    }   

    @isTest
    public static void obterParametrosIniciaisErrorTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseParametrosIniciais = new HttpResponse();
        responseParametrosIniciais.setStatusCode(400);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/avulso/parametros-iniciais' => responseParametrosIniciais
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoParametrosHelper.InputParametrosIniciais> lstInput = new List<BoletoAvulsoParametrosHelper.InputParametrosIniciais>();
        BoletoAvulsoParametrosHelper.InputParametrosIniciais inputs = new BoletoAvulsoParametrosHelper.InputParametrosIniciais();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);

        Test.StartTest();
        List<BoletoAvulsoParametrosHelper.OutputParametrosIniciais> output = BoletoAvulsoParametrosHelper.obterParametrosIniciais(lstInput);
        Test.StopTest();

        Assert.areEqual('ERROR', output[0].statusAPI, 'O status da API deve ser ERROR');
    }

    @isTest
    public static void obterParametrosIniciaisSaldoInsuficienteTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseParametrosIniciais = new HttpResponse();
        responseParametrosIniciais.setStatusCode(422);
        responseParametrosIniciais.setBody('{"mensagem":"Cliente não elegível para geração de boleto, valor da dívida menor que o valor mínimo. Conta: 10000055912."}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/avulso/parametros-iniciais' => responseParametrosIniciais
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BoletoAvulsoParametrosHelper.InputParametrosIniciais> lstInput = new List<BoletoAvulsoParametrosHelper.InputParametrosIniciais>();
        BoletoAvulsoParametrosHelper.InputParametrosIniciais inputs = new BoletoAvulsoParametrosHelper.InputParametrosIniciais();
        inputs.numeroConta = '10000045616';
        inputs.cpf = '25455513680';
        inputs.unidade = '2';
        inputs.canal = 'cockpit';
        inputs.sistema = 'cockpit';
        inputs.area = 'ouvidoria';
        inputs.loginOperador = '111';
        lstInput.add(inputs);

        Test.StartTest();
        List<BoletoAvulsoParametrosHelper.OutputParametrosIniciais> output = BoletoAvulsoParametrosHelper.obterParametrosIniciais(lstInput);
        Test.StopTest();

        Assert.areEqual('OK', output[0].statusAPI, 'O status da API deve ser OK');
        Assert.areEqual('OK', output[0].statusAPI, 'O status da API deve ser OK');
        Assert.isTrue(output[0].saldoDevedorInsuficiente, 'O saldo devedor do caso de teste é insuficiente');
    }   

}