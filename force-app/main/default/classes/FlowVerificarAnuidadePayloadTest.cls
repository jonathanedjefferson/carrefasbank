@isTest
public with sharing class FlowVerificarAnuidadePayloadTest {
    @isTest
    public static void test() {
        List<FlowVerificarAnuidadePayload.Input> lstInputs = new List<FlowVerificarAnuidadePayload.Input>();

        FlowVerificarAnuidadePayload.Input newInput = new FlowVerificarAnuidadePayload.Input();
        newInput.codigoMembership = '10555100810295410';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new VerificarAnuidadePayloadMock());
        FlowVerificarAnuidadePayload.chamarAPIVerificarAnuidade(lstInputs);
    }
}