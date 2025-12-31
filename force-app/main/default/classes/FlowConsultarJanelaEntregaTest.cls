@isTest
public with sharing class FlowConsultarJanelaEntregaTest {
    @isTest
    public static void test() {
        List<FlowConsultarJanelaEntrega.Input> lstInputs = new List<FlowConsultarJanelaEntrega.Input>();

        FlowConsultarJanelaEntrega.Input newInput = new FlowConsultarJanelaEntrega.Input();
        newInput.carrierId = 'teste';
        newInput.initialDate = Date.today();
        newInput.daysToAdd = 3;

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultarJanelaEntregaTest.ConsultarJanelaEntregaMock());
        FlowConsultarJanelaEntrega.chamarAPI(lstInputs);
    }
}