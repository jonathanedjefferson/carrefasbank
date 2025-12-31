/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - AlteracaoVencimentoController                        100%         *
*    - AlteracaoVencimentoBO                                96%          *
*    - AlteracaoVencimentoDAO                               100%         *
**************************************************************************/
@isTest
public class AlteracaoVencimentoTest {
    @isTest
    public static void getContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Test.startTest();
        AlteracaoVencimentoBO.ContaFinanceiraTO result = AlteracaoVencimentoController.getContaFinanceira(cf.Id);
        Test.stopTest();

        System.assertEquals(result.Nome, 'Teste');
        System.assertEquals(result.CPF, '123.456.789-12');
        System.assertEquals(result.StatusConta, 'NORM');
        System.assertEquals(result.NumeroConta, '11111111111');
        System.assertEquals(result.TipoConta, '1');
        System.assertEquals(result.AccountId, acc.Id);
    }

    @isTest
    public static void TratarAssetTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.CartaoPrimario__c = true;
        ass1.Product2Id = produto.Id;
        insert ass1;

        Test.startTest();
        AlteracaoVencimentoBO.AssetTO result = AlteracaoVencimentoController.tratarAsset(cf.Id);
        Test.stopTest();

        System.assertEquals(result.ProductName, 'MC HIBRIDO GOLD BASICO I');
    }

    @isTest
    public static void GetDataVencimentoFaturaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseGetDataVencimentoFatura = new HttpResponse();
        responseGetDataVencimentoFatura.setStatusCode(200);
        responseGetDataVencimentoFatura.setBody('{"listaDiasVencimento":[],"alteracaoPermitida":false,"dataUltimaAlteracao":"2024-04-09T09:36:35","dataVencimento":"2027-04-21T00:00:00-03:00","dataFechamento":"2027-04-08T00:00:00-03:00"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000035179/faturas/lista-data-vencimento' => responseGetDataVencimentoFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();

        AlteracaoVencimentoBO.DataVencimentoTO retorno = AlteracaoVencimentoController.getDataVencimentoFatura('23117497498', '10000035179', 'chat', '1');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Obter Data de Vencimento de Fatura'];
        System.AssertEquals(retorno.alteracaoPermitida, 'Não Permitido Alterar');
        System.AssertEquals(retorno.StatusAPI, 'OK');
        System.AssertEquals(retorno.dataUltimaAlteracao, '09/04/2024');
        System.AssertEquals(retorno.dataVencimento,'21/04/2027');
        System.AssertEquals(retorno.diaVencimento,'21');
        System.AssertEquals(retorno.dataDisponivelAlteracao,'12/10/2024');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '23117497498');
    }

    @isTest
    public static void GetDataVencimentoAtualizadaFaturaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseGetDataVencimentoFatura = new HttpResponse();
        responseGetDataVencimentoFatura.setStatusCode(200);
        responseGetDataVencimentoFatura.setBody('{"dataVencimento":"2027-04-21T00:00:00-03:00","dataFechamento":"2027-04-08T00:00:00-03:00"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000035179/faturas/data-vencimento-tsys' => responseGetDataVencimentoFatura
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();

        AlteracaoVencimentoBO.DataVencimentoTO retorno = AlteracaoVencimentoController.getDataVencimentoAtualizadaFatura('23117497498', '10000035179', 'chat', '1');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Obter Data de Vencimento Atualizada Fatura'];
        System.AssertEquals('21/04/2027', retorno.dataVencimento);
        System.AssertEquals('08/04/2027', retorno.dataFechamento);
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '23117497498');
    }

    @isTest
    public static void AlterarVencimentoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseAlterarVencimento = new HttpResponse();
        responseAlterarVencimento.setStatusCode(200);
        responseAlterarVencimento.setBody('{"dataVencimento":"2027-03-21T00:00:00-03:00","dataFechamento":"2027-03-08T00:00:00-03:00"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/10000035179/faturas/alterar-data-vencimento' => responseAlterarVencimento
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();

        AlteracaoVencimentoBO.AlterarVencimentoTO retorno = AlteracaoVencimentoController.alterarVencimento('23117497498', '10000035179', 'cockpit', 'ouvidoria', 'ouvidoria', '1', '25');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alteração de Vencimento'];
        System.AssertEquals(retorno.StatusAPI, 'OK');
        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '23117497498');
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
        AlteracaoVencimentoController.criarCaso(cf.Id, acc.Id, '1', 'Ouvidoria', 'Whatsapp');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }
}