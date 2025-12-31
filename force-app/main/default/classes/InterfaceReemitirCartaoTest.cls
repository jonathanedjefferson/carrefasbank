/**************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:              *
*    - InterfaceListarCartoesReemissao                          100%      *
*    - InterfaceReemitirCartao                                  100%      *
*    - ObterEnderecoCliente                                      98%      *
*    - RetornaValoresCartaoReemissao                            100%      *
*    - GetCartaoPrimarioReemissaoCartaoHelper                    95%      *
**************************************************************************/

@isTest
public class InterfaceReemitirCartaoTest {

    @isTest
    public static void ListarCartoesTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"cartoesElegiveis": [{"numeroCartaoOfuscado": "5300.XXXX.XXXX.8726","numeroCartaoSerno": "894905","status": "NORM","ehPrimario": true,"nomeCartao": "RAYSSA C DIAS","nomePortador": "RAYSSA COSTA DIAS","numeroCartaoCompleto": "5300342772798726"},{"numeroCartaoOfuscado": "5300.XXXX.XXXX.0261","numeroCartaoSerno": "905491","status": "NORM","ehPrimario": false,"nomeCartao": "JOAO CARLOS","nomePortador": "JOAO CARLOS","numeroCartaoCompleto": "5300342504720261"},{"numeroCartaoOfuscado": "5300.XXXX.XXXX.8666","numeroCartaoSerno": "905492","status": "LOST","ehPrimario": false,"nomeCartao": "PEDRO HENRIQUE","nomePortador": "PEDRO HENRIQUE","numeroCartaoCompleto": "5300342453448666"},{"numeroCartaoOfuscado": "5300.XXXX.XXXX.1220","numeroCartaoSerno": "905508","status": "NORM","ehPrimario": false,"nomeCartao": "MATHEUS GOMES","nomePortador": "MATHEUS GOMES","numeroCartaoCompleto": "5300342150361220"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001661/cartoes/reemitir/listar-cartoes' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarCartoesReemissao.RequestListarCartoesReemissao request = new InterfaceListarCartoesReemissao.RequestListarCartoesReemissao();   
        request.numeroConta = '37000001661';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';
        request.area = 'nao_aplica';

        List<InterfaceListarCartoesReemissao.RequestListarCartoesReemissao> requestList  = new List<InterfaceListarCartoesReemissao.RequestListarCartoesReemissao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarCartoesReemissao.ResponseListarCartoesReemissao> retornoList = InterfaceListarCartoesReemissao.listarCartoesReemissao(requestList);
        Test.StopTest();
        
        InterfaceListarCartoesReemissao.ResponseListarCartoesReemissao retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals('894905;905491;905492;905508;', retorno.listaSernoIds);
        System.AssertEquals('NORM;NORM;LOST;NORM;', retorno.listaStatusCartoes);
        System.AssertEquals('RAYSSA C DIAS (5300.XXXX.XXXX.8726);JOAO CARLOS (5300.XXXX.XXXX.0261);PEDRO HENRIQUE (5300.XXXX.XXXX.8666);MATHEUS GOMES (5300.XXXX.XXXX.1220);', retorno.listaOpcoesCartoesBkp);
        System.AssertEquals('RAYSSA C DIAS (5300.XXXX.XXXX.8726)', retorno.listaOpcoesCartoes[0]);
    }
    
    @isTest
    public static void ListarCartoesListaVaziaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"cartoesElegiveis": []}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001900/cartoes/reemitir/listar-cartoes' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarCartoesReemissao.RequestListarCartoesReemissao request = new InterfaceListarCartoesReemissao.RequestListarCartoesReemissao();   
        request.numeroConta = '37000001900';
        request.idEmpresa = '1';
        request.cpf = '95642922557';
        request.canal = 'chat';
        request.area = 'nao_aplica';

        List<InterfaceListarCartoesReemissao.RequestListarCartoesReemissao> requestList  = new List<InterfaceListarCartoesReemissao.RequestListarCartoesReemissao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarCartoesReemissao.ResponseListarCartoesReemissao> retornoList = InterfaceListarCartoesReemissao.listarCartoesReemissao(requestList);
        Test.StopTest();
        
        InterfaceListarCartoesReemissao.ResponseListarCartoesReemissao retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(null, retorno.listaSernoIds);
        System.AssertEquals(null, retorno.listaStatusCartoes);
        System.AssertEquals(null, retorno.listaOpcoesCartoes);
        System.AssertEquals(null, retorno.listaOpcoesCartoesBkp);
    }

    @isTest
    public static void ListarCartoesErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(500);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001900/cartoes/reemitir/listar-cartoes' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceListarCartoesReemissao.RequestListarCartoesReemissao request = new InterfaceListarCartoesReemissao.RequestListarCartoesReemissao();   
        request.numeroConta = '37000001900';
        request.idEmpresa = '1';
        request.cpf = '95642922557';
        request.canal = 'chat';
        request.area = 'nao_aplica';

        List<InterfaceListarCartoesReemissao.RequestListarCartoesReemissao> requestList  = new List<InterfaceListarCartoesReemissao.RequestListarCartoesReemissao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceListarCartoesReemissao.ResponseListarCartoesReemissao> retornoList = InterfaceListarCartoesReemissao.listarCartoesReemissao(requestList);
        Test.StopTest();
        
        InterfaceListarCartoesReemissao.ResponseListarCartoesReemissao retorno = retornoList[0];
        System.AssertEquals('ERRO', retorno.statusRetorno);
    }

    @isTest
    public static void ListarCartaoPrimarioTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"cartoesElegiveis": [{"numeroCartaoOfuscado": "5300.XXXX.XXXX.8726","numeroCartaoSerno": "894905","status": "NORM","ehPrimario": true,"nomeCartao": "RAYSSA C DIAS","nomePortador": "RAYSSA COSTA DIAS","numeroCartaoCompleto": "5300342772798726"},{"numeroCartaoOfuscado": "5300.XXXX.XXXX.0261","numeroCartaoSerno": "905491","status": "NORM","ehPrimario": false,"nomeCartao": "JOAO CARLOS","nomePortador": "JOAO CARLOS","numeroCartaoCompleto": "5300342504720261"},{"numeroCartaoOfuscado": "5300.XXXX.XXXX.8666","numeroCartaoSerno": "905492","status": "LOST","ehPrimario": false,"nomeCartao": "PEDRO HENRIQUE","nomePortador": "PEDRO HENRIQUE","numeroCartaoCompleto": "5300342453448666"},{"numeroCartaoOfuscado": "5300.XXXX.XXXX.1220","numeroCartaoSerno": "905508","status": "NORM","ehPrimario": false,"nomeCartao": "MATHEUS GOMES","nomePortador": "MATHEUS GOMES","numeroCartaoCompleto": "5300342150361220"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001661/cartoes/reemitir/listar-cartoes' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        GetCartaoPrimarioReemissaoCartaoHelper.RequestCartaoReemissao request = new GetCartaoPrimarioReemissaoCartaoHelper.RequestCartaoReemissao();   
        request.area = 'nao_aplica';
        request.canal = 'chat';
        request.cpf = '95642922556';
        request.idEmpresa = '1';
        request.numeroConta = '37000001661';

        List<GetCartaoPrimarioReemissaoCartaoHelper.RequestCartaoReemissao> requestList  = new List<GetCartaoPrimarioReemissaoCartaoHelper.RequestCartaoReemissao>();
        requestList.add(request);
        
        Test.StartTest();
        List<GetCartaoPrimarioReemissaoCartaoHelper.ResponseCartaoReemissao> retornoList = GetCartaoPrimarioReemissaoCartaoHelper.GetCartaoReemissao(requestList);
        Test.StopTest();
        
        GetCartaoPrimarioReemissaoCartaoHelper.ResponseCartaoReemissao retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals('894905', retorno.SernoId);
        System.AssertEquals('RAYSSA C DIAS', retorno.NomeCartao);
        System.AssertEquals('RAYSSA COSTA DIAS', retorno.NomePortador);
        System.AssertEquals('8726', retorno.Ultimos4Digitos);
    }

    // Retorna Valores Cartão Reemissão

    @isTest
    public static void retornaCartaoNaoBloqueadoTest() {

        RetornaValoresCartaoReemissao.InputValores request = new RetornaValoresCartaoReemissao.InputValores();   
        request.cartaoOpcaoSelecionada = 'RAYSSA C DIAS (5300.XXXX.XXXX.8726)';
        request.listaOpcoesCartoes = 'RAYSSA C DIAS (5300.XXXX.XXXX.8726);JOAO CARLOS (5300.XXXX.XXXX.0261);PEDRO HENRIQUE (5300.XXXX.XXXX.8666);MATHEUS GOMES (5300.XXXX.XXXX.1220);';
        request.listaSernoIds = '894905;905491;905492;905508;';
        request.listaStatusCartoes = 'NORM;NORM;LOST;NORM;';

        List<RetornaValoresCartaoReemissao.InputValores> requestList  = new List<RetornaValoresCartaoReemissao.InputValores>();
        requestList.add(request);
        
        Test.StartTest();
        List<RetornaValoresCartaoReemissao.OutputValores> retornoList = RetornaValoresCartaoReemissao.RetornaValoresCartaoReemissao(requestList);
        Test.StopTest();
        
        RetornaValoresCartaoReemissao.OutputValores retorno = retornoList[0];
        System.AssertEquals('N_BLOQ', retorno.cartaoBloqueado);
        System.AssertEquals('894905', retorno.sernoCartao);
        System.AssertEquals('NORM', retorno.statusCartaoSelecionado);
    }

    @isTest
    public static void retornaCartaoBloqueadoLostTest() {

        RetornaValoresCartaoReemissao.InputValores request = new RetornaValoresCartaoReemissao.InputValores();   
        request.cartaoOpcaoSelecionada = 'PEDRO HENRIQUE (5300.XXXX.XXXX.8666)';
        request.listaOpcoesCartoes = 'RAYSSA C DIAS (5300.XXXX.XXXX.8726);JOAO CARLOS (5300.XXXX.XXXX.0261);PEDRO HENRIQUE (5300.XXXX.XXXX.8666);MATHEUS GOMES (5300.XXXX.XXXX.1220);';
        request.listaSernoIds = '894905;905491;905492;905508;';
        request.listaStatusCartoes = 'NORM;NORM;LOST;NORM;';

        List<RetornaValoresCartaoReemissao.InputValores> requestList  = new List<RetornaValoresCartaoReemissao.InputValores>();
        requestList.add(request);
        
        Test.StartTest();
        List<RetornaValoresCartaoReemissao.OutputValores> retornoList = RetornaValoresCartaoReemissao.RetornaValoresCartaoReemissao(requestList);
        Test.StopTest();
        
        RetornaValoresCartaoReemissao.OutputValores retorno = retornoList[0];
        System.AssertEquals('BLOQ', retorno.cartaoBloqueado);
        System.AssertEquals('905492', retorno.sernoCartao);
        System.AssertEquals('LOST', retorno.statusCartaoSelecionado);
    }

    @isTest
    public static void retornaCartaoBloqueadoBlckTest() {

        RetornaValoresCartaoReemissao.InputValores request = new RetornaValoresCartaoReemissao.InputValores();   
        request.cartaoOpcaoSelecionada = 'PEDRO HENRIQUE (5300.XXXX.XXXX.8666)';
        request.listaOpcoesCartoes = 'RAYSSA C DIAS (5300.XXXX.XXXX.8726);JOAO CARLOS (5300.XXXX.XXXX.0261);PEDRO HENRIQUE (5300.XXXX.XXXX.8666);MATHEUS GOMES (5300.XXXX.XXXX.1220);';
        request.listaSernoIds = '894905;905491;905492;905508;';
        request.listaStatusCartoes = 'NORM;NORM;BLCK;NORM;';

        List<RetornaValoresCartaoReemissao.InputValores> requestList  = new List<RetornaValoresCartaoReemissao.InputValores>();
        requestList.add(request);
        
        Test.StartTest();
        List<RetornaValoresCartaoReemissao.OutputValores> retornoList = RetornaValoresCartaoReemissao.RetornaValoresCartaoReemissao(requestList);
        Test.StopTest();
        
        RetornaValoresCartaoReemissao.OutputValores retorno = retornoList[0];
        System.AssertEquals('N_BLOQ', retorno.cartaoBloqueado);
        System.AssertEquals('905492', retorno.sernoCartao);
        System.AssertEquals('BLCK', retorno.statusCartaoSelecionado);
    }

    @isTest
    public static void OpcaoInvalidaTest() {

        RetornaValoresCartaoReemissao.InputValores request = new RetornaValoresCartaoReemissao.InputValores();   
        request.cartaoOpcaoSelecionada = 'HENRIQUE (5300.XXXX.XXXX.8666)';
        request.listaOpcoesCartoes = 'RAYSSA C DIAS (5300.XXXX.XXXX.8726);JOAO CARLOS (5300.XXXX.XXXX.0261);PEDRO HENRIQUE (5300.XXXX.XXXX.8666);MATHEUS GOMES (5300.XXXX.XXXX.1220);';
        request.listaSernoIds = '894905;905491;905492;905508;';
        request.listaStatusCartoes = 'NORM;NORM;BLCK;NORM;';

        List<RetornaValoresCartaoReemissao.InputValores> requestList  = new List<RetornaValoresCartaoReemissao.InputValores>();
        requestList.add(request);
        
        Test.StartTest();
        List<RetornaValoresCartaoReemissao.OutputValores> retornoList = RetornaValoresCartaoReemissao.RetornaValoresCartaoReemissao(requestList);
        Test.StopTest();
        
        RetornaValoresCartaoReemissao.OutputValores retorno = retornoList[0];
        System.AssertEquals(null, retorno.cartaoBloqueado);
        System.AssertEquals(null, retorno.sernoCartao);
        System.AssertEquals(null, retorno.statusCartaoSelecionado);
    }

    // Reemitir Cartão

    @isTest
    public static void reemitirCartaoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001661/cartoes/894905/reemitir' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceReemitirCartao.RequestReemitirCartao request = new InterfaceReemitirCartao.RequestReemitirCartao();   
        request.numeroConta = '37000001661';
        request.numeroCartaoSerno = '894905';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';
        request.motivoBloqueio = 'LOST';
        request.statusCartao = 'LOST';

        List<InterfaceReemitirCartao.RequestReemitirCartao> requestList  = new List<InterfaceReemitirCartao.RequestReemitirCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceReemitirCartao.ResponseReemitirCartao> retornoList = InterfaceReemitirCartao.reemitirCartao(requestList);
        Test.StopTest();
        
        InterfaceReemitirCartao.ResponseReemitirCartao retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
    }

    @isTest
    public static void reemitirCartaoOutrosMotivosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001661/cartoes/894905/reemitir' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceReemitirCartao.RequestReemitirCartao request = new InterfaceReemitirCartao.RequestReemitirCartao();   
        request.numeroConta = '37000001661';
        request.numeroCartaoSerno = '894905';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';
        request.motivoBloqueio = 'DAMC';
        request.statusCartao = 'DAMC';

        List<InterfaceReemitirCartao.RequestReemitirCartao> requestList  = new List<InterfaceReemitirCartao.RequestReemitirCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceReemitirCartao.ResponseReemitirCartao> retornoList = InterfaceReemitirCartao.reemitirCartao(requestList);
        Test.StopTest();
        
        InterfaceReemitirCartao.ResponseReemitirCartao retorno = retornoList[0];
        System.AssertEquals('OK', retorno.statusRetorno);
    }

    @isTest
    public static void reemitirCartaoErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(422);
        response.setBody('{"mensagem": "Não foi possivel realizar a reemissão do cartão"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001661/cartoes/894906/reemitir' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceReemitirCartao.RequestReemitirCartao request = new InterfaceReemitirCartao.RequestReemitirCartao();   
        request.numeroConta = '37000001661';
        request.numeroCartaoSerno = '894906';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';
        request.motivoBloqueio = '';
        request.statusCartao = '';

        List<InterfaceReemitirCartao.RequestReemitirCartao> requestList  = new List<InterfaceReemitirCartao.RequestReemitirCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceReemitirCartao.ResponseReemitirCartao> retornoList = InterfaceReemitirCartao.reemitirCartao(requestList);
        Test.StopTest();
        
        InterfaceReemitirCartao.ResponseReemitirCartao retorno = retornoList[0];
        System.AssertEquals('ERRO', retorno.statusRetorno);
    }

        // Reemitir Cartão Alteração Nome Reduzido

        @isTest
        public static void reemitirCartaoComAlteracaoNomeReduzidoTest() {
            HttpResponse responseServerToServer = new HttpResponse();
            responseServerToServer.setStatusCode(200);
            responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
            
            HttpResponse response = new HttpResponse();
            response.setStatusCode(204);
    
            Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                    '/idp/server-to-server' => responseServerToServer, 
                    '/api/contas/37000001661/cartoes/894905/reemitir' => response 
            };
    
            Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
    
            InterfaceReemitirCartao.RequestReemitirCartao request = new InterfaceReemitirCartao.RequestReemitirCartao();   
            request.numeroConta = '37000001661';
            request.numeroCartaoSerno = '894905';
            request.idEmpresa = '1';
            request.cpf = '95642922556';
            request.canal = 'chat';
            request.area = 'nao_aplica';
            request.sistema = 'chat';
            request.motivoBloqueio = 'CLSC';
            request.statusCartao = 'CLSC';
            request.nomeReduzido = '';
    
            List<InterfaceReemitirCartao.RequestReemitirCartao> requestList  = new List<InterfaceReemitirCartao.RequestReemitirCartao>();
            requestList.add(request);
            
            Test.StartTest();
            List<InterfaceReemitirCartao.ResponseReemitirCartao> retornoList = InterfaceReemitirCartao.ReemitirCartaoComAlteracaoNomeReduzido(requestList);
            Test.StopTest();
            
            InterfaceReemitirCartao.ResponseReemitirCartao retorno = retornoList[0];
            System.AssertEquals('OK', retorno.statusRetorno);
        }

        @isTest
    public static void reemitirCartaoComAlteracaoNomeReduzidoErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(422);
        response.setBody('{"mensagem": "Não foi possivel solicitar segunda via com nome reduzido."}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/37000001661/cartoes/894906/reemitir' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceReemitirCartao.RequestReemitirCartao request = new InterfaceReemitirCartao.RequestReemitirCartao();   
        request.numeroConta = '37000001661';
        request.numeroCartaoSerno = '894906';
        request.idEmpresa = '1';
        request.cpf = '95642922556';
        request.canal = 'chat';
        request.area = 'nao_aplica';
        request.sistema = 'chat';
        request.motivoBloqueio = '';
        request.statusCartao = '';
        request.nomeReduzido = '';

        List<InterfaceReemitirCartao.RequestReemitirCartao> requestList  = new List<InterfaceReemitirCartao.RequestReemitirCartao>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceReemitirCartao.ResponseReemitirCartao> retornoList = InterfaceReemitirCartao.ReemitirCartaoComAlteracaoNomeReduzido(requestList);
        Test.StopTest();
        
        InterfaceReemitirCartao.ResponseReemitirCartao retorno = retornoList[0];
        System.AssertEquals('ERRO', retorno.statusRetorno);
    }

    @isTest
    public static void ObterEnderecoClienteTest() {
        ObterEnderecoCliente.InputValores request = new ObterEnderecoCliente.InputValores();   
        request.numeroConta = '190000012024';

        List<ObterEnderecoCliente.InputValores> requestList  = new List<ObterEnderecoCliente.InputValores>();
        requestList.add(request);
        
        Test.StartTest();

        ContaFinanceira__c conta = new ContaFinanceira__c();
        conta.NumeroConta__c = '190000012024';
        conta.Rua__c = 'Av. Dr. Chucri Zaidan';
        conta.Numero__c = '296';
        conta.Complemento__c = '19 Andar';
        conta.Bairro__c = 'Vila Cordeiro';
        conta.Cidade__c = 'São Paulo';
        conta.Estado__c = 'SP';
        conta.CEP__c = '04583-110';
        insert conta;

        List<ObterEnderecoCliente.OutputValores> retornoList = ObterEnderecoCliente.ObterEnderecoCliente(requestList);
        Test.StopTest();
        
        ObterEnderecoCliente.OutputValores retorno = retornoList[0];
        System.AssertEquals('A•• D•• C••••• Z••••• 2•• 1• A•••• - V••• C••••••o •••••-110 - São Paulo - SP', retorno.endereco);
    }


}