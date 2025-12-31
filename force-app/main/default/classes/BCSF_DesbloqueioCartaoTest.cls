@isTest
public class BCSF_DesbloqueioCartaoTest {
    @isTest
    public static void DesbloquearCartaoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/711243/desbloquear' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        Boolean retorno =  BCSF_DesbloqueioCartaoController.desbloquearCartao('1', 'cockpit', 'cockpit', 'Ouvidoria', '49926079857', '10000019496', '711243');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Desbloquear Cartão' LIMIT 1];

        System.AssertEquals(true, retorno);
        System.AssertEquals('49926079857', log.CPF__c);
        System.AssertEquals('PATCH', log.Metodo__c);
    }

    @isTest
    public static void ListCartoesParaDesbloqueioTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('[{"numeroCartaoOfuscado": "5438.XXXX.XXXX.9799","numeroCartaoSerno": "711243","status": "BLCK","ehPrimario": true,"nomeCartao": "BENJAMIN B ANDRADE","nomePortador": "BENJAMIN BARBOSA ANDRADE"},{"numeroCartaoOfuscado": "5438.XXXX.XXXX.3546","numeroCartaoSerno": "722796","status": "NORM","ehPrimario": false,"nomeCartao": "JULIANA SOUZA","nomePortador": "JULIANA SOUZA"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                'api/contas/10000019496/cartoes/desbloquear/listar-cartoes' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        List<DesbloqueioCartao.OutputListCartoesParaDesbloqueio> output =  BCSF_DesbloqueioCartaoController.getListCartoes('cockpit', 'Ouvidoria', '49926079857', '10000019496');
        Test.StopTest();

        System.AssertEquals('BLCK', output[0].status);
        System.AssertEquals('NORM', output[1].status);
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
        BCSF_DesbloqueioCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '1', 'Whatsapp');
        BCSF_DesbloqueioCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '2', 'Whatsapp');
        BCSF_DesbloqueioCartaoController.createCase('Ouvidoria',  cf.Id, acc.Id, '6', 'Whatsapp');
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
        BCSF_DesbloqueioCartaoController.updateAtivo(cf.Id, '5438.XXXX.XXXX.9799', 'BLCK');
        Test.StopTest();
    }

    @isTest
    public static void interfaceDesbloquearCartaoTestSucess(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        InterfaceDesbloqueioCartao.Input input = new InterfaceDesbloqueioCartao.Input();
        input.idEmpresa = '1';
        input.sistema = 'cockpit';
        input.canal = 'cockpit';
        input.area = 'Ouvidoria';
        input.cpf = '49926079857';
        input.numeroConta = '10000019496';
        input.numeroCartaoSerno = '711243';

        List<InterfaceDesbloqueioCartao.Input> inputLst = new List<InterfaceDesbloqueioCartao.Input>();
        inputLst.add(input);


        Test.StartTest();
        List<InterfaceDesbloqueioCartao.Output> retorno = InterfaceDesbloqueioCartao.desbloquearCartao(inputLst);
        Test.StopTest();

        Assert.isTrue(retorno[0].retornoAPI, 'O retorno deve sinalizar que a requisição foi feita como sucesso');
    }

    @isTest
    public static void interfaceDesbloquearCartaoTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        InterfaceDesbloqueioCartao.Input input = new InterfaceDesbloqueioCartao.Input();
        input.idEmpresa = '1';
        input.sistema = 'cockpit';
        input.canal = 'cockpit';
        input.area = 'Ouvidoria';
        input.cpf = '49926079857';
        input.numeroConta = '10000019496';
        input.numeroCartaoSerno = '711243';

        List<InterfaceDesbloqueioCartao.Input> inputLst = new List<InterfaceDesbloqueioCartao.Input>();
        inputLst.add(input);


        Test.StartTest();
        List<InterfaceDesbloqueioCartao.Output> retorno = InterfaceDesbloqueioCartao.desbloquearCartao(inputLst);
        Test.StopTest();

        Assert.isFalse(retorno[0].retornoAPI, 'O retorno deve sinalizar que houve um erro na requisição');
    }

}