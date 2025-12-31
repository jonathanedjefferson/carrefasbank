@isTest
public with sharing class MotorGeoLocalizacaoTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new MotorGeolocalizacaoMock());
        MotorGeoLocalizacao.makeAPIRequest('36047100', 'carrefour');
    }
}