@IsTest
public class FlowNeoAssistUpdateChamadosTest {
    @IsTest
    public static void testUpdatedCalls() {
        // Criação dos dados de entrada para o método UpdatedCalls
        FlowNeoAssistUpdateChamados.Input input = new FlowNeoAssistUpdateChamados.Input();
        input.protocolo = 'XYZ123';
        
        List<FlowNeoAssistUpdateChamados.Input> inputs = new List<FlowNeoAssistUpdateChamados.Input>();
        inputs.add(input);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NeoAssistUpdateChamadosMock());
        FlowNeoAssistUpdateChamados.UpdatedCalls(inputs);
        Test.stopTest();
    }
}