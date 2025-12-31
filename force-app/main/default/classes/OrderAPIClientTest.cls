@isTest
public class OrderAPIClientTest {
    @isTest
    static void testGetResponsePedido1P_Success() {
        // Define o mock para a chamada de HTTP com status code 200
        Test.setMock(HttpCalloutMock.class, new OrderAPIMockHttpCallout(200));
        OrderAPIClientTO.ResponseWrapper response = OrderAPIClient.getResponsePedido1P('EmailDeTest@hotmail.com');
        System.assertEquals(2, response.objects.size());
    }
    @isTest
    static void testGetResponsePedido1P_Error() {
        // Define o mock para a chamada de HTTP com status diferente de 200
        Test.setMock(HttpCalloutMock.class, new OrderAPIMockHttpCallout(404));
        OrderAPIClientTO.ResponseWrapper response = OrderAPIClient.getResponsePedido1P('EmailDeTeste@hotmail.com');
        System.assert(response.objects == null);
    }
}