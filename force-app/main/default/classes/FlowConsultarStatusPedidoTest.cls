@isTest
public with sharing class FlowConsultarStatusPedidoTest {
    @isTest
    public static void test() {
        List<FlowConsultarStatusPedido.Input> lstInputs = new List<FlowConsultarStatusPedido.Input>();

        FlowConsultarStatusPedido.Input newInput = new FlowConsultarStatusPedido.Input();
        newInput.orderCode = '12344534';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultarStatusPedidoTest.ConsultarStatusPedidoMock());
        FlowConsultarStatusPedido.chamarAPI(lstInputs);
    }
}