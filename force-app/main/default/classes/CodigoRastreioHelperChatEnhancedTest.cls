@isTest
private class CodigoRastreioHelperChatEnhancedTest {
    @isTest
    public static void listCartoesRastreioReemissaoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);       
        responseCancelar.setBody('{"postagemResponse":[{"numeroCartao": "5489.XXXX.XXXX.7824","codigoRastreio" : "BR123465SE","urlRastreio": "http://www.linkcorreios.com.br/BJ256641235BR","nomeTitular": "Final 7824 - FULANA DE TALS (Titular)"}]}');      
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/reemitir/codigoRastreio/listar' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        List<CodigoRastreioHelperChatEnhanced.Input> listInputAPI = new List<CodigoRastreioHelperChatEnhanced.Input>();
        CodigoRastreioHelperChatEnhanced.Input inputAPI = new CodigoRastreioHelperChatEnhanced.Input();
        inputAPI.canal = 'chat';
        inputAPI.area = 'nao_aplica';
        inputAPI.cpf = '55765609309';
        inputAPI.numeroConta = '37000000036';
        inputAPI.idEmpresa = '1';
        listInputAPI.add(inputAPI);

        Test.StartTest();
        List<CodigoRastreioHelperChatEnhanced.Output> outputAPI = CodigoRastreioHelperChatEnhanced.getCodigoRastreio(listInputAPI);


        GetInfoCodigoRastreio.Input inputInfo = new GetInfoCodigoRastreio.Input();
        List<GetInfoCodigoRastreio.Input> listNameInfo = new List<GetInfoCodigoRastreio.Input>();
        inputInfo.ListStringAllCartoes = outputAPI[0].ListStringAllCartoes;
        inputInfo.OpcaoSelecionada = 'Titular Final 7824';
        listNameInfo.add(inputInfo);
        List<GetInfoCodigoRastreio.Output> outputInfo = GetInfoCodigoRastreio.GetCodigoRastreior(listNameInfo);
        Test.StopTest();
            
        Assert.areEqual(outputAPI[0].ListCartoesOptions.size(), 1);
        Assert.areEqual(outputAPI[0].TemCodigoRastreio, 'SIM');
        Assert.areEqual(outputAPI[0].RetornouCartoes, 'SIM');
        Assert.areEqual(outputAPI[0].StatusAPI, 'OK');   
        Assert.areEqual(outputAPI[0].ListStringAllCartoes, 'BR123465SE Cartão Final 7824 - FULANA DE TALS (Titular)\nhttps://www.linkcorreios.com.br/BJ256641235BR<br>');
        Assert.areEqual(outputInfo[0].InfoCartaoSelecionado, 'BR123465SE Cartão Final 7824 - FULANA DE TALS (Titular)\nhttps://www.linkcorreios.com.br/BJ256641235BR');
    }
}