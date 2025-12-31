@IsTest
public class FlowAPIJanisV2Test {
    @IsTest
    static void testFlow() {
        List<FlowAPIJanisV2.Input> inputList = new List<FlowAPIJanisV2.Input>();
        FlowAPIJanisV2.Input input = new FlowAPIJanisV2.Input();
        input.orderCode = '123';
        input.email = '1';
        inputList.add(input);

        Test.setMock(HttpCalloutMock.class, new APIJanisV2Test.APIJanisV2Mock());        
        FlowAPIJanisV2.chamarAPI(inputList);        
    }
}