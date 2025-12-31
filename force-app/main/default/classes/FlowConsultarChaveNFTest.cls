@isTest
public with sharing class FlowConsultarChaveNFTest {
    @isTest
    public static void test() {
        List<FlowConsultarChaveNF.Input> lstInputs = new List<FlowConsultarChaveNF.Input>();

        FlowConsultarChaveNF.Input newInput = new FlowConsultarChaveNF.Input();
        newInput.orderCode = '12345';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new ConsultarChaveNFTest.ConsultarChaveNFMock());
        FlowConsultarChaveNF.chamarAPI(lstInputs);
    }
}