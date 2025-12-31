@isTest
public with sharing class FlowIdentificacaoPositivaClienteTest {
    @isTest
    public static void test() {
        List<FlowIdentificacaoPositivaCliente.Input> lstInputs = new List<FlowIdentificacaoPositivaCliente.Input>();

        FlowIdentificacaoPositivaCliente.Input newInput = new FlowIdentificacaoPositivaCliente.Input();
        newInput.CPF = '53058919816';
        newInput.name = 'Ayame Gomes';
        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new IdentificacaoPositivaClienteTest.IdentificacaoPositivaClienteMock());
        FlowIdentificacaoPositivaCliente.chamarAPI(lstInputs);
    }
}