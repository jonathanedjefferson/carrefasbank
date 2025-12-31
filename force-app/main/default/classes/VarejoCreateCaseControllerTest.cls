@isTest
global class VarejoCreateCaseControllerTest {
    @isTest
    public static void CreateCaseTDCATest() {
        Test.setMock(HttpCalloutMock.class, new APICaseCreationTest.APICreateCaseMock());
        String messagingId = '0Mw8B0000004IHJSA2';
        String channel = 'WhatsApp';
        String orderNumber = '23562';
        String consignmentCode = '1321562';
        String document = '12345245';
        String emailClient = 'teste@gmail.com';
        String customerName = 'teste';
        String telephone = '9203470';
        String description = 'teste';
        String brand = 'CARREFOUR';
        String bot = 'Menu Inicial';
        String protocolo = 'Lojas > 2 via de NF';
        String opcao = '';
        Test.startTest();
        String retorno = VarejoCreateCaseController.CreateCaseTDCA(messagingId, channel, orderNumber, consignmentCode, document, emailClient, customerName, telephone, description, brand, bot, protocolo, opcao);
        String staticRessource = VarejoCreateCaseController.getStaticRessource();
        Test.stopTest();

        System.assertEquals(retorno, '1234');
        System.assertNotEquals(staticRessource, null);
    }



    global with sharing class APICreateCaseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setBody('{"success":true, "id":"1234"}');
            response.setStatusCode(201);
            return response;
        }
    }
}