public with sharing class disabeCustomerInactiveButtonController {
    @AuraEnabled
    public static string getStaticRessource(){
        StaticResource sr= [SELECT Id, Body FROM StaticResource WHERE Name = 'disableCustomerInactiveButton'];

        String allcontents = sr.body.toString();

        System.debug('SR ->> ' + allcontents);

        return allcontents;
    }
}