/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ReemissaoCartao                            90%                    *
*    - CodigoRastreioHelper                       100%                   *
*    - GetInfoCodigoRastreio                      100%                   *
*    - BCSF_SegundaViaCartaoController            83%                    *
**************************************************************************/

@isTest
public class ReemissaoCartaoTest {
    @isTest
    public static void ReemitirCartao() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/894765/reemitir' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        ReemissaoCartao.ReemitirCartaoOutput retorno = BCSF_SegundaViaCartaoController.ReemitirCartao('1', 'cockpit', 'cockpit', 'Cobranca','55765609309', '37000000036', '894765', 'NORM');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Reemitir Cartão' LIMIT 1];

        System.AssertEquals(true, retorno.StatusAPI);
        System.AssertEquals('55765609309', log.CPF__c);
        System.AssertEquals('PATCH', log.Metodo__c);
    }

    @isTest
    public static void ReemitirCartaoComAlteracaoNomeReduzidoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(204);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/894765/reemitir' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        ReemissaoCartao.ReemitirCartaoOutput retorno = ReemissaoCartao.ReemitirCartaoComAlteracaoNomeReduzido('1', 'cockpit', 'cockpit', 'Cobranca','55765609309', '37000000036', '894765', 'NORM', 'GUSTAVO NUNES');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Reemitir Cartão Com Alteração de Nome Reduzido' LIMIT 1];

        System.AssertEquals(true, retorno.StatusAPI);
        System.AssertEquals('55765609309', log.CPF__c);
        System.AssertEquals('PATCH', log.Metodo__c);
    }

    @isTest
       public static void ListStatusReemissaoCartaoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('{"cartoesElegiveis":[{"numeroCartaoOfuscado": "4565XXXX86168738","numeroCartaoSerno": "1654","status": "NORM","ehPrimario": true,"nomeCartao": "CARTAO VIRTUAL","nomePortador": "JOSE JEZUINO JESUS"}],"status":[{"nome": "NORM","descricao": "Normal"}]}');
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/37000000036/cartoes/reemitir/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        ReemissaoCartao.OutputListCartoesParaReemissao output = BCSF_SegundaViaCartaoController.getListCartoes('cockpit','Cobranca','55765609309','37000000036','1');
        Test.StopTest();

        System.AssertEquals('NORM', output.status[0].nome);
    }

    @isTest
    public static void ListCartoesRastreioReemissaoTest(){
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
        
        Test.StartTest();
        List<CodigoRastreioHelper.Input> listInputAPI = new List<CodigoRastreioHelper.Input>();
        CodigoRastreioHelper.Input inputAPI = new CodigoRastreioHelper.Input();
        inputAPI.canal = 'chat';
        inputAPI.area = 'nao_aplica';
        inputAPI.cpf = '55765609309';
        inputAPI.numeroConta = '37000000036';
        inputAPI.idEmpresa = '1';
        listInputAPI.add(inputAPI);
        List<CodigoRastreioHelper.Output> outputAPI = CodigoRastreioHelper.GetCodigoRastreior(listInputAPI);


        GetInfoCodigoRastreio.Input inputInfo = new GetInfoCodigoRastreio.Input();
        List<GetInfoCodigoRastreio.Input> listNameInfo = new List<GetInfoCodigoRastreio.Input>();
        inputInfo.ListStringAllCartoes = outputAPI[0].ListStringAllCartoes;
        inputInfo.OpcaoSelecionada = 'Titular Final 7824';
        listNameInfo.add(inputInfo);
        List<GetInfoCodigoRastreio.Output> outputInfo = GetInfoCodigoRastreio.GetCodigoRastreior(listNameInfo);
        Test.StopTest();
            
        System.AssertEquals(outputAPI[0].ListCartoesOptions.size(),   1);   
        System.AssertEquals(outputAPI[0].TemCodigoRastreio,           'SIM');
        System.AssertEquals(outputAPI[0].RetornouCartoes,             'SIM');
        System.AssertEquals(outputAPI[0].StatusAPI,                   'OK');   
        System.AssertEquals(outputAPI[0].ListStringAllCartoes, 'BR123465SE Cartão Final 7824 - FULANA DE TALS (Titular)\nhttps://linkexterno/www.linkcorreios.com.br/BJ256641235BR<br>');
        
        System.AssertEquals(outputInfo[0].InfoCartaoSelecionado, 'BR123465SE Cartão Final 7824 - FULANA DE TALS (Titular)\nhttps://linkexterno/www.linkcorreios.com.br/BJ256641235BR');
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
        BCSF_SegundaViaCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '1', 'Whatsapp', true);
        BCSF_SegundaViaCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '2', 'Whatsapp', false);

        Test.StopTest();

        System.AssertEquals(2, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void CreateCaseRastreioTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
        BCSF_SegundaViaCartaoController.createCaseCodigoRastreio('pos_vendas', UserInfo.getUserId(),  cf.Id, acc.Id, '1', 'Whatsapp');
        BCSF_SegundaViaCartaoController.createCaseCodigoRastreio('sac',  UserInfo.getUserId(), cf.Id, acc.Id, '2', 'Whatsapp');
        BCSF_SegundaViaCartaoController.createCaseCodigoRastreio('pos_vendas',  UserInfo.getUserId(), cf.Id, acc.Id, '6', 'Chat');

        Test.StopTest();

        System.AssertEquals(3, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void UpdateAtivoTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        insert ass1;
        
        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'JULIANA SOUZA'; 
        ass2.NumeroCartao__c = '5438821360413546'; 
        ass2.CPF__c = '12345678945'; 
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        insert ass2;

        Test.StartTest();
        BCSF_SegundaViaCartaoController.updateAtivo(cf.Id, '5438.XXXX.XXXX.9799', 'BLCK');
        Test.StopTest();
    }
}