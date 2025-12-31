@isTest
public with sharing class FlowConsultarCodigoPostagemTest {
    @isTest
    public static void test() {
        List<FlowConsultarCodigoPostagem.Input> lstInputs = new List<FlowConsultarCodigoPostagem.Input>();

        FlowConsultarCodigoPostagem.Input newInput = new FlowConsultarCodigoPostagem.Input();
        newInput.orderCode = 'teste12345mock';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultarCodigoPostagemTest.ConsultarCodigoPostagemMock());
        FlowConsultarCodigoPostagem.chamarAPI(lstInputs);
    }
}