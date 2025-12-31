@isTest
public with sharing class NeoAssistUpdateChamadosTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new NeoAssistUpdateChamadosMock());

        FlowNeoAssistUpdateChamados.Input input = new FlowNeoAssistUpdateChamados.Input();
        input.protocolo = '462300918';
        List<FlowNeoAssistUpdateChamados.Input> entrada = new List<FlowNeoAssistUpdateChamados.Input>();
        entrada.add(input);
        FlowNeoAssistUpdateChamados.UpdatedCalls(entrada);
    }
}