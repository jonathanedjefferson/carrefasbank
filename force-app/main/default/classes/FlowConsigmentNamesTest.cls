@isTest
public with sharing class FlowConsigmentNamesTest {
    @isTest
    public static void test() {
        List<FlowConsigmentNames.Input> lstInputs = new List<FlowConsigmentNames.Input>();

        FlowConsigmentNames.Input newInput = new FlowConsigmentNames.Input();
        newInput.email = 'teste@gmail.com';
        newInput.numPedido = '540372342';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultarPedidosClienteTest.ConsultarPedidosClienteMock());
        FlowConsigmentNames.chamarAPI(lstInputs);
    }
}