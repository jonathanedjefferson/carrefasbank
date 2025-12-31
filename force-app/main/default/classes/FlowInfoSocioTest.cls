@isTest
public with sharing class FlowInfoSocioTest {
    @isTest
    public static void test() {
        List<FlowInfoSocio.Input> lstInputs = new List<FlowInfoSocio.Input>();

        FlowInfoSocio.Input newInput = new FlowInfoSocio.Input();
        newInput.CPF = '53058919816';
        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new IdentificarSocioTest.IdentificarSocioMock());
        FlowInfoSocio.chamarIdentificarSocio(lstInputs);
    }
}