/**
	Classe de teste responsável por cobrir as classes:
    BCSF_AvaliacaoEmergencial,
    BCSF_AvaliacaoEmergencialController
**/
@isTest
private class BCSF_AvaliacaoEmergencialTest {
    
    @isTest
    static void testConsultarDadosAvaliacao() {
	   HttpResponse responseCSFServices = new HttpResponse();
       responseCSFServices.setStatusCode(200);
       responseCSFServices.setBody('{"access_token": "2LdGtLYKrCeJ4jxPpotObro-ZRDFOghQfeM","token_type": "Bearer","not-before-policy": 1667242382,"session_state": "6772121d-308c-4a79-b696-130e36bd4ae5","scope": "email profile"}');

       HttpResponse responseSuccessDados = new HttpResponse();
       responseSuccessDados.setStatusCode(200);
       responseSuccessDados.setBody('{"AceiteAvaliacaoEmergencial":true,"DataUltimaModificacaoAvaliacaoEmergencial":"20/03/2025"}');
       
       Map<String, HttpResponse> mockResponses = new Map<String, HttpResponse>{
           '/idp/csf-servicos' =>responseCSFServices,
           '/v3/AvaliacaoEmergencial/Consultar' => responseSuccessDados
       };
	   
	   System.debug(mockResponses);	
       Test.setMock(HttpCalloutMock.class, new BCSF_AvaliacaoEmergencialMock(mockResponses));
        
	   Test.StartTest();
       String responseDados = BCSF_AvaliacaoEmergencialController.Consultar('07837196473','37000002503', 'cobranca','cockpit');
	   Test.StopTest();
       
       System.assertEquals('{"AceiteAvaliacaoEmergencial":true,"DataUltimaModificacaoAvaliacaoEmergencial":"20/03/2025"}',responseDados);
    }
    
    @isTest
    static void testGravarDadosAvaliacaoAdesao() {
       HttpResponse responseCSFServices = new HttpResponse();
       responseCSFServices.setStatusCode(200);
       responseCSFServices.setBody('{"access_token": "ic2lkIjoiNjc3MjEyMWQtMzA4Yy00YTc5LWI2OTYtMTMwZTM2YmQ0YWU1In0.fcqOGQ3a2LdGtLYKrCeJ4jxPpotObro-ZRDFOghQfeM","token_type": "Bearer","not-before-policy": 1667242382,"session_state": "6772121d-308c-4a79-b696-130e36bd4ae5","scope": "email profile"}');

       HttpResponse responseSuccessDados = new HttpResponse();
       responseSuccessDados.setStatusCode(200);
       responseSuccessDados.setBody('{"accountNumber":"37000002503","operation":"cancelamento"}');
       
       Map<String, HttpResponse> mockResponses = new Map<String, HttpResponse>{
           '/idp/csf-servicos' =>responseCSFServices,
           '/v3/AvaliacaoEmergencial/Gravarcockpit' => responseSuccessDados
       };
	   
	   System.debug(mockResponses);	
       Test.setMock(HttpCalloutMock.class, new BCSF_AvaliacaoEmergencialMock(mockResponses));
        
	   Test.StartTest();
       String responseDados = BCSF_AvaliacaoEmergencialController.Gravar('07837196473','37000002503','cobranca','cockpit','1','0');
	   Test.StopTest();
       
       System.assertEquals('{"accountNumber":"37000002503","operation":"cancelamento"}',responseDados);
    }
    /*
    @isTest
    static void testConsultarTaxasAvaliacao() {
        Test.setMock(HttpCalloutMock.class, new BCSF_AvaliacaoEmergencialMock());
        
        Test.startTest();
        String response = BCSF_AvaliacaoEmergencial.consultarTaxasAvaliacao('56180230676','37000000648' ,'apag_conta_digital', 'cockpit','CONTA MC GOLD BASICO L','17/01/2025');
        
        System.assertNotEquals('{"message":"Acesso não autorizado"}', response, 'Acesso não autorizado');
        System.assert(response.contains('"taxaEmDia": 18.9'), 'Resposta deve conter taxaEmDia');
    }
    */

    @isTest
    static void testConsultarTermoAvaliacao() {
       HttpResponse responseCSFServices = new HttpResponse();
       responseCSFServices.setStatusCode(200);
       responseCSFServices.setBody('{"access_token": "fcqOGQ3a2LdGtLYKrCeJ4jxPpotObro-ZRDFOghQfeM","token_type": "Bearer","not-before-policy": 1667242382,"session_state": "6772121d-308c-4a79-b696-130e36bd4ae5","scope": "email profile"}');

       HttpResponse responseSuccessDados = new HttpResponse();
       responseSuccessDados.setStatusCode(200);
        responseSuccessDados.setBody('{"template":"<div class=\"opcaoOverlimit\" style=\"display:block\">   <div>    <div style=\"width: 100%; height: 40px;\"><p>Opção escolhida pelo cliente: <b>Não</b></p></div>   </div>   <hr>  </div>  <div class=\"wrapperImpressao\">    <div>     <div>      <div style=\"width: 100%; height: 40px;\"><p>Termo de Cancelamento Avalia}');
       
       Map<String, HttpResponse> mockResponses = new Map<String, HttpResponse>{
           '/idp/csf-servicos' =>responseCSFServices,
           '/v3/AvaliacaoEmergencial/consultar-termo-template' => responseSuccessDados
       };
	   
	   System.debug(mockResponses);	
       Test.setMock(HttpCalloutMock.class, new BCSF_AvaliacaoEmergencialMock(mockResponses));
        
	   Test.StartTest();
       String responseDados = BCSF_AvaliacaoEmergencialController.ConsultarTermo('07837196473','37000002503','cobranca','cockpit','53');
	   Test.StopTest();
       
       System.assert(responseDados.contains('template'),'Deve conter o termo "template"');
    }

    @isTest
    public static void getContaFinanceiraAndAssetTest(){
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

		Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

		Asset ativo = new Asset();
		ativo.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ativo.NumeroCartao__c = '5438821131329799'; 
        ativo.CPF__c = '12345678912'; 
        ativo.TipoTitularidade__c = 'TITULAR';
        ativo.TipoCartao__c = 'C';
        ativo.CartaoPrimario__c  = true;
        ativo.ContaFinanceira__c = cf.Id;
        ativo.Name = 'Cartão'; 
        ativo.Status = '72';
        ativo.DataAtivacaoCartao__c = Date.newInstance(2025, 2, 10);insert ativo;
				
        Test.startTest();
        ContaFinanceiraBO.ContaFinanceira result = BCSF_AvaliacaoEmergencialController.getContaFinanceira(cf.Id);
		AssetBO.AssetTO resultAsset = BCSF_AvaliacaoEmergencialController.getAssetTitular(cf.Id);
        Test.stopTest();

        System.assertEquals(result.Nome, 'Teste');
        System.assertEquals(result.CPF, '123.456.789-12');
        System.assertEquals(result.StatusConta, 'NORM');
        System.assertEquals(result.NumeroConta, '11111111111');
        System.assertEquals(result.TipoConta, '1');
        System.assertEquals(result.AccountId, acc.Id);
    }

    

}