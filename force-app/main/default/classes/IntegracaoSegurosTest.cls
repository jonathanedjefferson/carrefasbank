@isTest
public class IntegracaoSegurosTest {
    @isTest
    public static void getSegurosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseGetSeguros = new HttpResponse();
        responseGetSeguros.setStatusCode(200);
        responseGetSeguros.setBody('{"status":1,"nome":"teste","cartao":"5553","produtos":[{"codigoProduto":"2182","nomeProduto":"Proteção Financeira",'
                                    +'"tipo":"protecaoFinanceira","nomeProdutoPadronizado":"protecao-financeira","termoAdesao":"classe de teste","anosVigencia":10,'
                                    +'"descricao":"teste","seguradora":"CARDIF","ordenacao":1,"imagem":"","descricaoOfertada":"teste","descricaoOfertadaDestaque":'
                                    +'"teste","quantidadePermitida":1,"configuracao":{"tipoVisualizacao":"unico","extencao":false,"confirmaEndereco":false,'
                                    +'"textoPlanoDivisaoCategoria":"","consultaCardEspecial":"nenhum","confirmaDependentes":false,"exibeDrawer":false},"apresentacao":'
                                    +'{"titulo":"teste","descricao":"teste","descricaoValor":"teste","descricaoValorExemplo":"","descricaoSelecaoPlano":""},'
                                    +'"coberturasPlano":[{"idPlano":"2288","nomePlano":"Plano 1","especial":false,"tipoCalculoValor":"I","tipoCobranca":"V",'
                                    +'"valorParcela":"R$ 12,90","ordenacao":1,"estaAtivo":true,"cobertura":[{"titulo":"Desemprego Involuntário (DI)","descricao":'
                                    +'"teste","observacao":"teste","exibeConsulta":true,"exibeAdesao":true,"ordenacao":1,"tipo":"","icone":"Diploma"}]}]}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                'seguros/api/v1/segurossalesforce/disponiveis-por-conta' => responseGetSeguros
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<String> products = new List<String>();
        Test.StartTest();
        IntegracaoSeguros.OutputElegibilidadeProdutos retorno = bcsf_cmp_SegurosController.getSeguros('1', 'cockpit', '55765609309', '55765609309', products);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Elegibilidade de Seguros' LIMIT 1];

        System.AssertEquals('5553', retorno.cartao);
        System.AssertEquals('55765609309', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }

    @isTest
    public static void adesaoSegurosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseAdesaoSeguros = new HttpResponse();
        responseAdesaoSeguros.setStatusCode(200);
        responseAdesaoSeguros.setBody('{"idAdesao":100000,"mensagem":"Ades�o Realizada com Sucesso..."}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                'seguros/api/v1/segurossalesforce/realizar-adesao' => responseAdesaoSeguros
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        String body = '{"teste":"teste"}';

        Test.StartTest();
        IntegracaoSeguros.OutputAdesaoSeguro retorno = bcsf_cmp_SegurosController.adesaoSeguros('1', 'cockpit', '55765609309', body);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Adesão de Seguros' LIMIT 1];

        System.AssertEquals(100000, retorno.idAdesao);
        System.AssertEquals('55765609309', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
    }

    @isTest
    public static void CreateCaseTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
            bcsf_cmp_SegurosController.criarCaso(cf.Id, acc.Id, '1', 'Ouvidoria',  'Whatsapp');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void CriarCasoCancelamentoTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String seguro = '{"nome": "Seguro Parcele Fácil", "contrato": "5454", "motivo": "Outro"}';

        Test.StartTest();
            bcsf_cmp_SegurosController.criarCasoCancelamento(cf.Id, acc.Id, '1', 'Ouvidoria',  'Whatsapp', 'testando','teste', seguro);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void CriarCasosContestarTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String seguro = '[{"nome": "Seguro Parcele Fácil", "contrato": "5454", "motivo": "Outro"}]';

        Test.StartTest();
            bcsf_cmp_SegurosController.criarCasosContestar(cf.Id, acc.Id, '1', 'Ouvidoria',  'Whatsapp', seguro);
        Test.StopTest();

        System.AssertEquals(2, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void getAccountTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        Test.StartTest();
            bcsf_cmp_SegurosController.getAccount(acc.Id);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Account]);
    }

    @isTest
    public static void searchArticlesTest(){
        Knowledge__kav artigo = new Knowledge__kav(
            Title = 'Artigo Teste 1',
            Summary = 'Resumo do Artigo Teste 1',
            UrlName = 'Artigo',
            Perguntas__c = 'Pergunta 1',
            Resposta__c = 'Resposta 1'
        );
        insert artigo; 

        Knowledge__kav artigo2 = [SELECT id, KnowledgeArticleId FROM Knowledge__kav limit 1];
        KbManagement.PublishingService.publishArticle(artigo2.KnowledgeArticleId, true);

        Test.StartTest();
            Knowledge__kav retorno = bcsf_cmp_SegurosController.searchArticles('Artigo Teste 1');
        Test.StopTest();

        System.AssertEquals('Artigo Teste 1', retorno.Title);
    }

    @isTest
    public static void motivosCancelamentoSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockMotivosCancelamentoSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoSeguros.OutputMotivosCancelamento retorno = bcsf_cmp_SegurosController.getMotivosCancelamento('1', '00000000000', 'chat');
        Test.StopTest();

        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(12, retorno.motivos.size());
    }

    @isTest
    public static void motivosCancelamentoErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(404, 'MockMotivosCancelamentoSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoSeguros.OutputMotivosCancelamento retorno = bcsf_cmp_SegurosController.getMotivosCancelamento('1', '00000000000', 'chat');
        Test.StopTest();

        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @isTest
    public static void consultarSegurosSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        ConsultarSegurosHelper.InputSeguros aa = new ConsultarSegurosHelper.InputSeguros();
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';

        List<ConsultarSegurosHelper.InputSeguros> listName = new List<ConsultarSegurosHelper.InputSeguros>();
        listName.add(aa);

        Test.StartTest();
        List<ConsultarSegurosHelper.OutputConsultarSeguros> retorno = ConsultarSegurosHelper.ConsultarSeguros(listName);
        Test.StopTest();
        System.assertEquals('OK', retorno[0].statusResponse);
        System.assertNotEquals('', retorno[0].adesoes);
    }

    @isTest
    public static void consultarSegurosControllerSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoSeguros.OutputConsultarSeguros retorno = bcsf_cmp_SegurosController.getSegurosContratados('1', '00000000000', 'chat');
        Test.StopTest();

        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(4, retorno.adesoes.size());
    }

    @isTest
    public static void consultarSegurosErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockConsultarSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        ConsultarSegurosHelper.InputSeguros aa = new ConsultarSegurosHelper.InputSeguros();
        aa.idEmpresa = '2';
        aa.cpf = '31649927932';
        aa.canal = 'chat';

        List<ConsultarSegurosHelper.InputSeguros> listName = new List<ConsultarSegurosHelper.InputSeguros>();
        listName.add(aa);

        Test.StartTest();
        List<ConsultarSegurosHelper.OutputConsultarSeguros> retorno = ConsultarSegurosHelper.ConsultarSeguros(listName);
        Test.StopTest();
        System.assertEquals('ERROR', retorno[0].statusResponse);
    }

    @isTest
    public static void cancelarSegurosSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        CancelarSegurosHelper.InputCancelamentoSeguros contrato = new CancelarSegurosHelper.InputCancelamentoSeguros();
        contrato.idAdesao = '04bc2b58';
        contrato.nomeAdesao = 'idAdesaoPdr';
        contrato.codMotivoCancelamento = '8';
        contrato.codigoCanalCancelamento = '3333333301';
        contrato.nomeCanalCancelamento = 'ATENDIMENTO TAMBORÉ';
        contrato.codigoUsuarioCancelamento = 'x';
        contrato.nomeUsuarioCancelamento = 'x';
        contrato.comentarioCancelamento = 'exemplo de comentário';
        contrato.cpf = '50741129906';
        contrato.unidadeNegocio = '1';
		contrato.canal = 'chat';

        List<CancelarSegurosHelper.InputCancelamentoSeguros> listName = new List<CancelarSegurosHelper.InputCancelamentoSeguros>();
        listName.add(contrato);

        Test.StartTest();
        List<CancelarSegurosHelper.OutputCancelarSeguros> retorno = CancelarSegurosHelper.CancelamentoSeguros(listName);
        Test.StopTest();
        System.assertEquals('OK', retorno[0].statusResponse);
    }

    @isTest
    public static void cancelarSegurosControllerSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        String seguro = '{"idAdesao":"teste", "nomeAdesao": "idAdesaoPdr", "dataCancelamento":"teste","codMotivoCancelamento":"0000",'
                        +'"codigoCanalCancelamento":"0000","nomeCanalCancelamento":"teste","codigoUsuarioCancelamento":'
                        +'"teste","nomeUsuarioCancelamento":"teste","comentarioCancelamento":"teste","cpf":"0000",'
                        +'"unidadeNegocio":"1","canal":"cockpit"}';

        Test.StartTest();
        IntegracaoSeguros.OutputCancelarSeguros retorno = bcsf_cmp_SegurosController.cancelarSeguro(seguro);
        Test.StopTest();

        System.assertEquals('OK', retorno.statusResponse);
    }

    @isTest
    public static void cancelarSegurosErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockConsultarSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        CancelarSegurosHelper.InputCancelamentoSeguros contrato = new CancelarSegurosHelper.InputCancelamentoSeguros();
        contrato.idAdesao = '04bc2b58';
        contrato.nomeAdesao = 'idAdesaoPdr';
        contrato.codMotivoCancelamento = '8';
        contrato.codigoCanalCancelamento = '3333333301';
        contrato.nomeCanalCancelamento = 'ATENDIMENTO TAMBORÉ';
        contrato.codigoUsuarioCancelamento = 'x';
        contrato.nomeUsuarioCancelamento = 'x';
        contrato.comentarioCancelamento = 'exemplo de comentário';
        contrato.cpf = '50741129906';
        contrato.unidadeNegocio = '1';
		contrato.canal = 'chat';

        List<CancelarSegurosHelper.InputCancelamentoSeguros> listName = new List<CancelarSegurosHelper.InputCancelamentoSeguros>();
        listName.add(contrato);

        Test.StartTest();
        List<CancelarSegurosHelper.OutputCancelarSeguros> retorno = CancelarSegurosHelper.CancelamentoSeguros(listName);
        Test.StopTest();
        System.assertEquals('ERROR', retorno[0].statusResponse);
    }

    @isTest
    public static void historicoCobrancaSucessoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockHistoricoCobrancaSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoSeguros.OutputHistoricoSeguro retorno = bcsf_cmp_SegurosController.historicoCobranca('idAdesao', '1', '1', '00000000000', 'chat');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(2, retorno.parcelas.size());
    }

    @isTest
    public static void historicoCobrancaErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockHistoricoCobrancaSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoSeguros.OutputHistoricoSeguro retorno = bcsf_cmp_SegurosController.historicoCobranca('idAdesao', '1', '1', '00000000000', 'chat');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(2, retorno.parcelas.size());
    }

    @IsTest
    static void getSegurosPorNomeTest() {
        List<GetSeguroPorNomeHelper.InputBuscarSeguro> inputs = new List<GetSeguroPorNomeHelper.InputBuscarSeguro>();
        
        String jsonListSeguros1 =   '[{"nomeProduto":"Seguro1","nomePlano":"SeguroFamiliaA"},' +
                                    '{"nomeProduto":"Seguro2","nomePlano":"FamiliaB"}]';
        String jsonListSeguros2 =   '[{"nomeProduto":"Seguro3","nomePlano":"FamiliaC"},' +
                                    '{"nomeProduto":"Seguro4","nomePlano":"FamiliaD"}]';

        GetSeguroPorNomeHelper.InputBuscarSeguro input1 = new GetSeguroPorNomeHelper.InputBuscarSeguro();
        input1.nome = 'Seguro1';
        input1.lista = jsonListSeguros1;
        inputs.add(input1);

        GetSeguroPorNomeHelper.InputBuscarSeguro input2 = new GetSeguroPorNomeHelper.InputBuscarSeguro();
        input2.nome = 'Seguro5';
        input2.lista = jsonListSeguros2;
        inputs.add(input2);

        Test.startTest();
        List<GetSeguroPorNomeHelper.OutputGetSeguroPorNome> result = GetSeguroPorNomeHelper.getSegurosPorNome(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Seguro1', result[0].nomeProduto);
    }
}