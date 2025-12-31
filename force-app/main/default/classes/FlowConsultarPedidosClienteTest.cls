@isTest
public with sharing class FlowConsultarPedidosClienteTest {
    @isTest
    public static void test() {
        List<FlowConsultarPedidosCliente.Input> lstInputs = new List<FlowConsultarPedidosCliente.Input>();

        FlowConsultarPedidosCliente.Input newInput = new FlowConsultarPedidosCliente.Input();
        newInput.email = 'teste@gmail.com';
        newInput.numPedido = '12345';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultarPedidosClienteTest.ConsultarPedidosClienteMock());
        FlowConsultarPedidosCliente.chamarAPI(lstInputs);
    }
}