/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - AcordoDivida                                100%                  *
**************************************************************************/
@isTest
public class AcordoDividaTest {
    
    @isTest
    public static void ConsultarSituacaoAcordoComDividaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(200);
        responseConsultar.setBody('{"situacao": {"codigo": 2, "descricao": "Cliente possui dívida"},"infosCliente": {"possuiEmail": false}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputConsultarSituacaoAcordo output = AcordoDivida.ConsultarSituacaoAcordo('79413706387', '1', 'chat');
        Test.StopTest();

        System.AssertEquals('2', output.situacao.codigo);
        System.AssertEquals(false, output.infosCliente.possuiEmail);
    }

    @isTest
    public static void ConsultarSituacaoAcordoComDividaFaturaV1Test(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(200);
        responseConsultar.setBody('{"situacao": {"codigo": 2, "descricao": "Cliente possui dívida"},"infosCliente": {"possuiEmail": false}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputConsultarSituacaoAcordo output = BCSF_CLS_CalloutFaturasController.consultarSituacaoAcordo('79413706387', '1', 'chat');
        Test.StopTest();

        System.AssertEquals('2', output.situacao.codigo);
        System.AssertEquals(false, output.infosCliente.possuiEmail);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoComAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(200);
        responseConsultar.setBody('{"situacao": {"codigo": 3, "descricao": "Cliente possui acordo"},"referenciaEmpresa": "001","infosCliente": {"possuiEmail": true},"contratos": [{"numeroContrato": "66968138850","nomeProduto": "MC GOLD","acordos": [{"numeroAcordoAtual": "13931730", "dataNegociacao": "2023-02-07T00:00:00", "valorTotalDivida": 8803.98,"valorIOF": 0, "valorDesconto": 6808.08, "valorFinalAcordo": 1995.9,"numeroParcela": 1, "valorEntrada": 1995.9, "valorDemaisParcelas": 1995.9, "percentualDesconto": 22.67,"parcelas": [{ "dataVencimento": "2023-04-20T00:00:00", "numeroParcela": 0, "pagamentoEmProcessamento": 78, "statusEnum": 80, "valorParcela": 1995.9, "linhaDigitavel": "", "status": "Pendente"}], "acordoAnterior": { "numeroAcordo": "13000685", "dataNegociacao": "2022-07-27T18:22:47", "status": "C", "dataUltimoPagamento": "2022-09-07T00:00:00","dataQuebraAcordo": "2022-10-23T00:00:00", "dataVencimentoParcelaNaoPaga": "2022-10-07T00:00:00"},"identificadorAcordo": "jjsWl6poL1v5jflxQ137LugHxpmYycO5OO4vb3utJZFabjyTNPPreUlVJmuieGp9nxojLg4BZEyKEzK6PhbvHHByrhdRm4+k5xoLnKSyWwU="}], "status": "Ativo"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputConsultarSituacaoAcordo output = AcordoDivida.ConsultarSituacaoAcordo('79413706387', '1', 'chat');
        Test.StopTest();

        System.AssertEquals('3', output.situacao.codigo);
        System.AssertEquals(1, output.contratos[0].acordos[0].numeroParcela);
        System.AssertEquals('jjsWl6poL1v5jflxQ137LugHxpmYycO5OO4vb3utJZFabjyTNPPreUlVJmuieGp9nxojLg4BZEyKEzK6PhbvHHByrhdRm4+k5xoLnKSyWwU=', output.contratos[0].acordos[0].identificadorAcordo);
        System.AssertEquals(true, output.infosCliente.possuiEmail);
        System.AssertEquals(Double.valueOf('1995.9'), output.contratos[0].acordos[0].parcelas[0].valorParcela);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoUsuarioInexistenteTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(422);
        responseConsultar.setBody('{"codigo": 397, "mensagem": "Situação do Cliente Inválida"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputConsultarSituacaoAcordo output = AcordoDivida.ConsultarSituacaoAcordo('79413706387', '1', 'chat');
        Test.StopTest();

        System.AssertEquals('397', output.situacao.codigo);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoErroTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar = new HttpResponse();
        responseConsultar.setStatusCode(500);
        responseConsultar.setBody('');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputConsultarSituacaoAcordo output = AcordoDivida.ConsultarSituacaoAcordo('79413706387', '1', 'chat');
        Test.StopTest();

        System.AssertEquals(null, output);
    }

    @isTest
    public static void ObterBoletoAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseObterBoleto = new HttpResponse();
        responseObterBoleto.setStatusCode(200);
        responseObterBoleto.setBody('{"linhaDigitavel": "36890.00101  93508.969511  49002.000203  5  93450000199590", "valorDocumento": 1995.9, "boleto": "xxxxxxxxxxxxx"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/boleto' => responseObterBoleto
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputObterBoletoAcordo output = AcordoDivida.ObterBoletoAcordo('jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals('xxxxxxxxxxxxx', output.boleto);
    }
    
    @isTest
    public static void ObterBoletoAcordoErroTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseObterBoleto = new HttpResponse();
        responseObterBoleto.setStatusCode(404);
        responseObterBoleto.setBody('');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/boleto' => responseObterBoleto
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputObterBoletoAcordo output = AcordoDivida.ObterBoletoAcordo('jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals(null, output);
    }
    
    @isTest
    public static void ValidarClienteAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseValidarCliente = new HttpResponse();
        responseValidarCliente.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/cliente/validar' => responseValidarCliente
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputValidaClienteAcordo output = AcordoDivida.ValidarClienteAcordo('jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=', '(1991-10-30)', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals(true, output.situacao);
    }
    
    @isTest
    public static void ValidarClienteAcordoErroTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseValidarCliente = new HttpResponse();
        responseValidarCliente.setStatusCode(404);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/cliente/validar' => responseValidarCliente
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputValidaClienteAcordo output = AcordoDivida.ValidarClienteAcordo('jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=', '1991-09-30', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals(false, output.situacao);
    }

    @isTest
    public static void EnviarBoletoAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseEnviarBoleto = new HttpResponse();
        responseEnviarBoleto.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/boleto/enviar' => responseEnviarBoleto
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        Boolean output = AcordoDivida.EnviarBoletoAcordo('jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals(true, output);
    }
    
    @isTest
    public static void EnviarBoletoAcordoErroTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseEnviarBoleto = new HttpResponse();
        responseEnviarBoleto.setStatusCode(404);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/boleto/enviar' => responseEnviarBoleto
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        Boolean output = AcordoDivida.EnviarBoletoAcordo('jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes=', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals(false, output);
    }
    
    @isTest
    public static void SimularAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseSimularAcordo = new HttpResponse();
        responseSimularAcordo.setStatusCode(200);
        responseSimularAcordo.setBody('{"planoParcelamentoParceirosDto": [{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=","valorDesconto": 33.8,"percentualDesconto": 88,"valorParcela": 36.63,"quantidadeParcelas": 1},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwbYQqmQ7za+P0BplEVl3U8=","valorDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 6.09,"quantidadeParcelas": 9},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRx/JoeFDTpRUZUtYUXaElMdE36OGzz7wnw3ws2gVS1K3","valorDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 5.49,"quantidadeParcelas": 10},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRw/UkwYv/dxvKhQCgJ8p94QcVFcYTcNjpiErvTbsk2q5","valorDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 5.01,"quantidadeParcelas": 11},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid","valorDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 4.6,"quantidadeParcelas": 12},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3","valorDesconto": 61.97,"percentualDesconto": 78,"valorParcela": 5.12,"quantidadeParcelas": 13}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/acordo/simular' => responseSimularAcordo
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputSimularAcordo retorno = AcordoDivida.SimularAcordo('QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==', '2023-09-10', '30', '10', '1', '79413706387', 'chat');
        Test.StopTest();

        System.AssertEquals(Double.valueOf('36.63'), retorno.planoParcelamentoParceirosDto[0].valorParcela);
        System.AssertEquals(9, retorno.planoParcelamentoParceirosDto[1].quantidadeParcelas);
        System.AssertEquals(Double.valueOf('50.71'), retorno.planoParcelamentoParceirosDto[2].valorDesconto);
        System.AssertEquals(Decimal.valueOf(82), retorno.planoParcelamentoParceirosDto[3].percentualDesconto);
        System.AssertEquals('QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid', retorno.planoParcelamentoParceirosDto[4].identificador);
    }
    
    @isTest
    public static void ConfirmarAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseSimularAcordo = new HttpResponse();
        responseSimularAcordo.setStatusCode(200);
        responseSimularAcordo.setBody('{"codigoAcordo": "14032292","diaVencimentoDemaisParcelas": 30,"linhaDigitavel": "36890.00101  93509.148313  31002.000201  1  00000000110149","numeroContrato": "66989227674","parcelamentoEscolhido": {"valorDesconto": 2203.00,"percentualDesconto": 40.25,"valorParcela": 1101.49,"quantidadeParcelas": 2},"valorAcordo": 3686.81,"vencimentoPrimeiraParcela": "2023-06-30T00:00:00","identificador": "hq5jLIRDKbHufK6gNsVKBM3muK1/o0FWNtCZiYSefZrBRI6SmbaLwZqcQDno6dPGKO0t+i80IgLcGhwkjdyhtg=="}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/api/v1/parceiros/acordo/confirmar' => responseSimularAcordo
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        AcordoDivida.OutputConfirmarAcordo retorno = AcordoDivida.ConfirmarAcordo('QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==', 'WHATSAPP', '0', '1', '79413706387', 'chat');
        Test.StopTest();


        System.AssertEquals('36890.00101  93509.148313  31002.000201  1  00000000110149', retorno.linhaDigitavel);
        System.AssertEquals(null, retorno.copiaCola);
        System.AssertEquals('hq5jLIRDKbHufK6gNsVKBM3muK1/o0FWNtCZiYSefZrBRI6SmbaLwZqcQDno6dPGKO0t+i80IgLcGhwkjdyhtg==', retorno.identificador);
    }
    
}