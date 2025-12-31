@isTest
public with sharing class FlowConsultOrderStatusAPITest {
    @isTest
    public static void test() {
        List<FlowConsultOrderStatusAPI.Input> lstInputs = new List<FlowConsultOrderStatusAPI.Input>();

        FlowConsultOrderStatusAPI.Input newInput = new FlowConsultOrderStatusAPI.Input();
        newInput.cpf = '123';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultOrderStatusAPITest.ConsultOrderStatusAPIMock());
        FlowConsultOrderStatusAPI.consultaStatusPedidoFlow(lstInputs);
    }
}