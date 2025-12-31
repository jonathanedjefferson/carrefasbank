@isTest
public with sharing class FlowEnvioMensagemSellerTest {
    @isTest
    public static void test() {
        List<FlowEnvioMensagemSeller.Input> lstInputs = new List<FlowEnvioMensagemSeller.Input>();

        FlowEnvioMensagemSeller.Input newInput = new FlowEnvioMensagemSeller.Input();
        newInput.consigmentCode = '123';
        newInput.bodyMessage = 'teste';
        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new EnvioMensagemSellerTest.EnvioMensagemSellerMock());
        FlowEnvioMensagemSeller.chamarAPI(lstInputs);
    }
}