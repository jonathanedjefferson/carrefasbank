/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - BCSF_BloqueioCartaoController              100%                   *
*    - BloqueioCartao                             99%                    *
*    - BloqueioCartaoDAO                          100%                   *
**************************************************************************/

@isTest
public class BloqueioCartaoTest {
    @isTest
    public static void BloquearCartao() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/711243/bloquear' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        Boolean retorno = BCSF_BloqueioCartaoController.bloquearCartao('1', 'cockpit', 'cockpit', 'Ouvidoria', '49926079857', '10000019496', '711243', 'BLCK');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Bloquear Cartão' LIMIT 1];

        System.AssertEquals(true, retorno);
        System.AssertEquals('49926079857', log.CPF__c);
        System.AssertEquals('PATCH', log.Metodo__c);
    }

    @isTest
    public static void ListStatusBloqueioCartaoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('{"status": [{"nome": "INTC","descricao": "Intercambio"},{"nome": "LOST","descricao": "Perda"},{"nome": "STLC","descricao": "Roubo"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/contas/cartoes/bloquear/listar-status' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        BloqueioCartao.OutputStatusBloqueio output = BCSF_BloqueioCartaoController.listStatusBloqueioCartao('cockpit',  'Ouvidoria');
        Test.StopTest();

        System.AssertEquals('INTC', output.status[0].nome);
        System.AssertEquals('LOST', output.status[1].nome);
        System.AssertEquals('STLC', output.status[2].nome);
    }

    @isTest
    public static void ListCartoesParaBloqueioTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('[{"numeroCartaoOfuscado": "5438.XXXX.XXXX.9799","numeroCartaoSerno": "711243","status": "BLCK","ehPrimario": true,"nomeCartao": "BENJAMIN B ANDRADE","nomePortador": "BENJAMIN BARBOSA ANDRADE"},{"numeroCartaoOfuscado": "5438.XXXX.XXXX.3546","numeroCartaoSerno": "722796","status": "NORM","ehPrimario": false,"nomeCartao": "JULIANA SOUZA","nomePortador": "JULIANA SOUZA"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/bloquear/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        List<BloqueioCartao.OutputListCartoesParaBloqueio> output = BCSF_BloqueioCartaoController.getListCartoes('cockpit', 'Ouvidoria', '49926079857', '10000019496');
        Test.StopTest();

        System.AssertEquals('BLCK', output[0].status);
        System.AssertEquals('NORM', output[1].status);
    }

    @isTest
    public static void GetCartaoTitularTest(){
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
        ass1.TipoTitularidade__c = 'TITULAR';
        ass1.CartaoPrimario__c  = true;
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        insert ass1;
        
        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'JULIANA SOUZA'; 
        ass2.NumeroCartao__c = '5438821360413546'; 
        ass2.CPF__c = '12345678945'; 
        ass2.TipoTitularidade__c = 'DEPENDENTE';
        ass2.CartaoPrimario__c  = false;
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        insert ass2;

        Test.StartTest();
        AssetBO.AssetTO assetTitular = BCSF_BloqueioCartaoController.getCartaoTitular(cf.Id);
        Test.StopTest();

        System.AssertEquals('BENJAMIN B ANDRADE', assetTitular.NomeReduzido);
        System.AssertEquals('5438821131329799', assetTitular.NumeroCartao);
    }

    @isTest
    public static void GetTipoBloqueioCartaoTest(){

        Test.StartTest();
        String statusProvisorio = BCSF_BloqueioCartaoController.getTipoBloqueioCartao('NORM');
        String statusDefinitivo = BCSF_BloqueioCartaoController.getTipoBloqueioCartao('LOST');
        Test.StopTest();

        System.AssertEquals('STATUS_PROVISORIO', statusProvisorio);
        System.AssertEquals('STATUS_DEFINITIVO', statusDefinitivo);
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
        BCSF_BloqueioCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '1', 'Whatsapp');
        BCSF_BloqueioCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '2', 'Whatsapp');
        BCSF_BloqueioCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '6', 'Whatsapp');
        Test.StopTest();

        System.AssertEquals(3, [SELECT COUNT() FROM Case]);
    }


    @isTest
    public static void createCaseFalecimento(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        
        Test.StartTest();
        BCSF_BloqueioCartaoController.createCaseFalecimento('Ouvidoria', cf.Id, acc.Id,'1', 'Whatsapp', '119912341234 ');
        
        Test.StopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Case]);
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
        BCSF_BloqueioCartaoController.updateAtivo(cf.Id, '5438.XXXX.XXXX.9799', 'BLCK');
        Test.StopTest();
    }

    @isTest 
    public static void GetInfoStatus(){
        InfoStatus__c ifst = new InfoStatus__c();
        ifst.Descricao__c = 'Descrição de teste!';
        ifst.Name = 'BLCK';
        insert ifst;

        Test.StartTest();
        InfoStatus__c rt = BCSF_BloqueioCartaoController.getInfoStatus('BLCK');
        Test.StopTest();

        System.AssertEquals(rt.Descricao__c, 'Descrição de teste!');
        System.AssertEquals(rt.Name, 'BLCK');
    }
}