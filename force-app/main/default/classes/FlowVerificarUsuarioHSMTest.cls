@isTest
public with sharing class FlowVerificarUsuarioHSMTest {
    @isTest
    public static void test() {
        List<FlowVerificarUsuarioHSM.Input> lstInputs = new List<FlowVerificarUsuarioHSM.Input>();

        FlowVerificarUsuarioHSM.Input newInput = new FlowVerificarUsuarioHSM.Input();
        newInput.phone = '4002-8922';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new VerificarUsuarioHSMTest.VerificarUsuarioHSMMock());
        FlowVerificarUsuarioHSM.chamarAPI(lstInputs);
    }
}