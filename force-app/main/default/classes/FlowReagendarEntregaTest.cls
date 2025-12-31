@IsTest
public class FlowReagendarEntregaTest {
    @IsTest
    public static void testUpdatedCalls() {
        // Criação dos dados de entrada para o método UpdatedCalls
        FlowReagendarEntrega.Input input = new FlowReagendarEntrega.Input();
        input.shippingId = '123';
        input.shippingUrl = '123';
        input.carrierId = '123';
        input.initialDate = '123';
        input.finalDate = '123';
        input.name = 'teste';
        input.document = '123';
        
        List<FlowReagendarEntrega.Input> inputs = new List<FlowReagendarEntrega.Input>();
        inputs.add(input);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReagendarEntregaTest.ReagendarEntregaMock());
        FlowReagendarEntrega.chamarAPI(inputs);
        Test.stopTest();
    }
}