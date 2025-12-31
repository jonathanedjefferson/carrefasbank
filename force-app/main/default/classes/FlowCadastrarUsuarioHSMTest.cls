@isTest
public with sharing class FlowCadastrarUsuarioHSMTest {
    @isTest
    public static void test() {
        List<FlowCadastrarUsuarioHSM.Input> lstInputs = new List<FlowCadastrarUsuarioHSM.Input>();

        FlowCadastrarUsuarioHSM.Input newInput = new FlowCadastrarUsuarioHSM.Input();
        newInput.phone = '4002-8922';
        newInput.name = 'teste';
        newInput.acronymLoja = 'teste';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new CadastrarUsuarioHSMTest.CadastrarUsuarioHSMMock());
        FlowCadastrarUsuarioHSM.chamarAPI(lstInputs);
    }
}