@IsTest
public class FlowAbrirIncidenteMirakiTest {
    @IsTest
    static void testFlow() {
        List<FlowAbrirIncidenteMiraki.Input> inputList = new List<FlowAbrirIncidenteMiraki.Input>();
        FlowAbrirIncidenteMiraki.Input input = new FlowAbrirIncidenteMiraki.Input();
        input.orderCode = '123';
        input.reasonCode = '1';
        inputList.add(input);

        Test.setMock(HttpCalloutMock.class, new AbrirIncidenteMirakiTest.AbrirInicidenteMirakiMock());        
        FlowAbrirIncidenteMiraki.chamarAPI(inputList);        
    }
}