@isTest
public class InterfaceObterResumoFaturaFechadaTest {
    
    @isTest
    public static void InterfaceObterResumoFaturaFechadaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"dataVencimento": "2028-12-20T00:00:00","valorFatura": {"valor": 1271.84,"moeda": "R$"},"pagamentoMinimo": {"valor": 63.59,"moeda": "R$"},"creditos": {"valor": 0,"moeda": "R$"},"linhaDigitavel": "30000.127184.002012.280003.700010.453150","codigoBarras": "36890.00101 93006.030063 46001.000200 6 23970000127184"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/37000104531/faturas/fechadas/ultima/resumo' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceObterResumoFaturaFechada.RequestObterResumo request = new InterfaceObterResumoFaturaFechada.RequestObterResumo();   
        request.numeroConta = '37000104531';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';

        List<InterfaceObterResumoFaturaFechada.RequestObterResumo> requestList  = new List<InterfaceObterResumoFaturaFechada.RequestObterResumo>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceObterResumoFaturaFechada.ResponseObterResumo> retornoList = InterfaceObterResumoFaturaFechada.ObterResumoFaturaFechada(requestList);
        Test.StopTest();
        
        InterfaceObterResumoFaturaFechada.ResponseObterResumo retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals('20/12', retorno.dataVencimento);
        System.AssertEquals('R$ 1.271,84', retorno.valorFatura);
        System.AssertEquals('36890.00101 93006.030063 46001.000200 6 23970000127184', retorno.codigoBarras);
        System.AssertEquals('Pagar fatura com vencimento em 20/12', retorno.opcoesMenu.get(0));
    }

    @isTest
    public static void InterfaceObterResumoFaturaFechadaTestErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"dataVencimento": "0001-01-01T00:00:00","valorFatura": null,"pagamentoMinimo": null,"creditos": null,"linhaDigitavel": null,"codigoBarras": null}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/37000104531/faturas/fechadas/ultima/resumo' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceObterResumoFaturaFechada.RequestObterResumo request = new InterfaceObterResumoFaturaFechada.RequestObterResumo();   
        request.numeroConta = '37000104531';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';

        List<InterfaceObterResumoFaturaFechada.RequestObterResumo> requestList  = new List<InterfaceObterResumoFaturaFechada.RequestObterResumo>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceObterResumoFaturaFechada.ResponseObterResumo> retornoList = InterfaceObterResumoFaturaFechada.ObterResumoFaturaFechada(requestList);
        Test.StopTest();
        
        InterfaceObterResumoFaturaFechada.ResponseObterResumo retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(null, retorno.codigoBarras);
    }
}