@isTest
public with sharing class bcsf_CaseFieldSetsControllerTest {
    public static testMethod void getFieldSetTest() {
        Test.startTest();
        bcsf_CaseFieldSetsController.getFieldSet('Encargos, Tarifas e Anuidade');
        Test.stopTest();
    }
}