@isTest
public with sharing class FlowCartaoPresenteTest {
    @isTest
    public static void test() {
        List<FlowCartaoPresente.Input> lstInputs = new List<FlowCartaoPresente.Input>();

        FlowCartaoPresente.Input newInput = new FlowCartaoPresente.Input();
        newInput.numCartao = '6361698121000000928';
        newInput.senhaCartao = '5215';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new GiftCardSoapAPIIntegrationMock());
        FlowCartaoPresente.chamarAPICartaoPresente(lstInputs);
    }
}