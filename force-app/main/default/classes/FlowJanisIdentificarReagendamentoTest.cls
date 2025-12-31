@isTest
public with sharing class FlowJanisIdentificarReagendamentoTest {
    @isTest
    public static void test() {
        List<FlowJanisIdentificarReagendamento.Input> lstInputs = new List<FlowJanisIdentificarReagendamento.Input>();

        FlowJanisIdentificarReagendamento.Input newInput = new FlowJanisIdentificarReagendamento.Input();
        newInput.numPedido = '123';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new JanisIdentificarReagendamentoTest.JanisIdentificarReagendamentoMock());
        FlowJanisIdentificarReagendamento.chamarAPI(lstInputs);
    }
}