@isTest
public with sharing class VerificarAnuidadePayloadTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new VerificarAnuidadePayloadMock());
        VerificarAnuidadePayload.makeAPIRequest('10555100810295410');
    }
}