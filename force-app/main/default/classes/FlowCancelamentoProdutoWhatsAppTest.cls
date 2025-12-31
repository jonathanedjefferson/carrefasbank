@IsTest
public class FlowCancelamentoProdutoWhatsAppTest {
    @IsTest
    static void testCancelamentoProdutoWhatsApp_Success() {
        List<FlowCancelamentoProdutoWhatsApp.Input> inputList = new List<FlowCancelamentoProdutoWhatsApp.Input>();
        FlowCancelamentoProdutoWhatsApp.Input input = new FlowCancelamentoProdutoWhatsApp.Input();
        input.email = 'EmailDeTeste@gmail.com';
        input.pedido = '530492836';
        inputList.add(input);
        Test.setMock(HttpCalloutMock.class, new OrderAPIMockHttpCallout(200));        
        List<FlowResponseOrder> returnList = FlowCancelamentoProdutoWhatsApp.cancelamentoProdutoWhatsApp(inputList);
        System.assertEquals(1, returnList.size()); 
    }
    @IsTest
    static void testCancelamentoProdutoWhatsApp_Error() {
        FlowCancelamentoProdutoWhatsApp.Input input = new FlowCancelamentoProdutoWhatsApp.Input();
        input.email = '';
        input.pedido = '';
        Test.setMock(HttpCalloutMock.class, new OrderAPIMockHttpCallout(404));
        List<FlowResponseOrder> result = FlowCancelamentoProdutoWhatsApp.cancelamentoProdutoWhatsApp(new List<FlowCancelamentoProdutoWhatsApp.Input>{input});
        System.assertEquals(0, result.size()); 
    }
}