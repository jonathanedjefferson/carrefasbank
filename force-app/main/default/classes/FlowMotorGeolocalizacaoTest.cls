@isTest
public with sharing class FlowMotorGeolocalizacaoTest {
    @isTest
    public static void test() {
        List<FlowMotorGeolocalizacao.Input> lstInputs = new List<FlowMotorGeolocalizacao.Input>();

        FlowMotorGeolocalizacao.Input newInput = new FlowMotorGeolocalizacao.Input();
        newInput.categoria = 'carrefour';
        newInput.CEP = '36047100';

        lstInputs.add(newInput);
        Test.setMock(HttpCalloutMock.class, new MotorGeolocalizacaoMock());
        FlowMotorGeolocalizacao.chamarAPI(lstInputs);
    }
}