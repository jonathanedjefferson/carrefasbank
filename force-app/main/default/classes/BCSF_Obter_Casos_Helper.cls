public without sharing class BCSF_Obter_Casos_Helper {
    
    @AuraEnabled(Cacheable=true)
    public static List<Case> getListOfRecords(String cpfCliente){
        Id RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CAS_CasoChat').getRecordTypeId();

        List<Case> cases = [SELECT id, Assunto__c, CaseNumber, Type, Status FROM Case WHERE Account.CPF__c =: cpfCliente AND RecordTypeID = :RT_ID AND Assunto__c = 'Encargos, Tarifas e Anuidade' AND Type = 'Solicitação'];

        if(cases.isEmpty()) throw new AuraHandledException('Nenhum caso de estorno com este CPF foi encontrado.');
        
        return cases;
    }

}