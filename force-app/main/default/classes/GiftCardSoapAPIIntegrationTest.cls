@isTest
public with sharing class GiftCardSoapAPIIntegrationTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new GiftCardSoapAPIIntegrationMock());
        GiftCardSoapAPIIntegration.executeRequest('6361698121000000928', '5215');
    }
}