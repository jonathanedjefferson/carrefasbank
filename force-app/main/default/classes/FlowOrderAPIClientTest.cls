@isTest
public with sharing class FlowOrderAPIClientTest {
    @isTest
    static void testCancelamentoProdutoWhatsApp_Success() {
        List<FlowOrderAPIClient.Input> inputList = new List<FlowOrderAPIClient.Input>();
        FlowOrderAPIClient.Input input = new FlowOrderAPIClient.Input();
        input.email = 'EmailDeTeste@gmail.com';
        inputList.add(input);
        Test.setMock(HttpCalloutMock.class, new OrderAPIMockHttpCallout(200));        
        FlowOrderAPIClient.chamarAPIPedido1P(inputList);
    }
}