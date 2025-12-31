/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceListarCartaoDesbloqueioSenha                     100%    *
*    - InterfaceDesbloquearSenhaCartao                           100%    *
*    - RetornaValoresDesbloqueioSenhaCartao                      100%    *
**************************************************************************/

@isTest
public class InterfaceDesbloquearSenhaCartaoTest {

    @isTest
    public static void ListarCartoesDesbloqueioSenhaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('[{"numeroCartaoSerno": "940751","numeroCartaoOfuscado": "5438.XXXX.XXXX.0272","status": "NORM","ehPrimario": true,"wrongPinRetries": 3}, {"numeroCartaoSerno": "940753","numeroCartaoOfuscado": "5438.XXXX.XXXX.6670","status": "NORM","ehPrimario": true,"wrongPinRetries": 3}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha/listar-cartoes' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha request = new InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha();   
        request.cpf = '95642922556';
        request.numeroConta = '37000000036';
        request.idEmpresa = '1';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha> requestList  = new List<InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarCartaoDesbloqueioSenha.ResponseListarCartaoDesbloqueioSenha> retornoList = InterfaceListarCartaoDesbloqueioSenha.ListarCartaoDesbloqueioSenha(requestList);
        Test.StopTest();
        
        InterfaceListarCartaoDesbloqueioSenha.ResponseListarCartaoDesbloqueioSenha retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals('940751;940753;', retorno.sernoCartoesDesbloqueioSenha);
        System.AssertEquals('0272;6670;', retorno.listaCartoes);
        System.AssertEquals('0272', retorno.cartoesDesbloqueioSenha[0]);
    }
    
    @isTest
    public static void ListarCartoesDesbloqueioListaVaziaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('[]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha/listar-cartoes' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha request = new InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha();   
        request.cpf = '95642922556';
        request.numeroConta = '37000000036';
        request.idEmpresa = '1';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha> requestList  = new List<InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarCartaoDesbloqueioSenha.ResponseListarCartaoDesbloqueioSenha> retornoList = InterfaceListarCartaoDesbloqueioSenha.ListarCartaoDesbloqueioSenha(requestList);
        Test.StopTest();
        
        InterfaceListarCartaoDesbloqueioSenha.ResponseListarCartaoDesbloqueioSenha retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(null, retorno.sernoCartoesDesbloqueioSenha);
        System.AssertEquals(null, retorno.listaCartoes);
        System.AssertEquals(0, retorno.cartoesDesbloqueioSenha.size());
    }

    @isTest
    public static void ListarCartoesDesbloqueioSenhaErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(500);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha/listar-cartoes' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha request = new InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha();   
        request.cpf = '95642922556';
        request.numeroConta = '37000000036';
        request.idEmpresa = '1';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha> requestList  = new List<InterfaceListarCartaoDesbloqueioSenha.RequestListarCartaoDesbloqueioSenha>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarCartaoDesbloqueioSenha.ResponseListarCartaoDesbloqueioSenha> retornoList = InterfaceListarCartaoDesbloqueioSenha.ListarCartaoDesbloqueioSenha(requestList);
        Test.StopTest();
        
        InterfaceListarCartaoDesbloqueioSenha.ResponseListarCartaoDesbloqueioSenha retorno = retornoList[0];
        System.AssertEquals('ERRO', retorno.statusRetorno);
    }

    // Retorna Valores Cartão Desbloqueio

    @isTest
    public static void RetornaDadosCartaoSelecionadoTest() {

        RetornaValoresDesbloqueioSenhaCartao.InputValores request = new RetornaValoresDesbloqueioSenhaCartao.InputValores();   
        request.cartaoOpcaoSelecionada = '0261';
        request.listaCartoes = '8726;0261;1220;';
        request.listaSernoIds = '894905;905491;905492;';

        List<RetornaValoresDesbloqueioSenhaCartao.InputValores> requestList  = new List<RetornaValoresDesbloqueioSenhaCartao.InputValores>();
        requestList.add(request);
        
        Test.StartTest();
        List<RetornaValoresDesbloqueioSenhaCartao.OutputValores> retornoList = RetornaValoresDesbloqueioSenhaCartao.RetornaValoresDesbloqueioSenhaCartao(requestList);
        Test.StopTest();
        
        RetornaValoresDesbloqueioSenhaCartao.OutputValores retorno = retornoList[0];
        System.AssertEquals('905491', retorno.sernoCartao);
    }

    // Desbloquear Senha Cartão

    @isTest
    public static void DesbloquearSenhaCartaoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('[{"idSerno": "924694","sucesso": true}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao request = new InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao();   
        request.cpf = '95642922556';
        request.numeroConta = '37000000036';
        request.idSernoCartao = '924694';
        request.idEmpresa = '1';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao> requestList  = new List<InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceDesbloquearSenhaCartao.ResponseDesbloquearSenhaCartao> retornoList = InterfaceDesbloquearSenhaCartao.DesbloquearSenhaCartao(requestList);
        Test.StopTest();
        
        InterfaceDesbloquearSenhaCartao.ResponseDesbloquearSenhaCartao retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
    }

    @isTest
    public static void DesbloquearSenhaCartaoErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(200);
        responseHttp.setBody('[{"idSerno": "923015","sucesso": false}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao request = new InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao();   
        request.cpf = '95642922556';
        request.numeroConta = '37000000036';
        request.idSernoCartao = '923015';
        request.idEmpresa = '1';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao> requestList  = new List<InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceDesbloquearSenhaCartao.ResponseDesbloquearSenhaCartao> retornoList = InterfaceDesbloquearSenhaCartao.DesbloquearSenhaCartao(requestList);
        Test.StopTest();
        
        InterfaceDesbloquearSenhaCartao.ResponseDesbloquearSenhaCartao retorno = retornoList[0];
        System.AssertEquals('ERRO', retorno.statusRetorno);
    }

    @isTest
    public static void DesbloquearSenhaCartaoErroApiTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseHttp = new HttpResponse();
        responseHttp.setStatusCode(500);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/desbloquear-senha' => responseHttp
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao request = new InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao();   
        request.cpf = '95642922556';
        request.numeroConta = '37000000036';
        request.idSernoCartao = '923015';
        request.idEmpresa = '1';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';

        List<InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao> requestList  = new List<InterfaceDesbloquearSenhaCartao.RequestDesbloquearSenhaCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceDesbloquearSenhaCartao.ResponseDesbloquearSenhaCartao> retornoList = InterfaceDesbloquearSenhaCartao.DesbloquearSenhaCartao(requestList);
        Test.StopTest();
        
        InterfaceDesbloquearSenhaCartao.ResponseDesbloquearSenhaCartao retorno = retornoList[0];
        System.AssertEquals('ERRO', retorno.statusRetorno);
    }

}