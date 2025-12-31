public with sharing class CaseDAO {
    private static final CaseDAO instance = new CaseDAO();

    public static CaseDAO getInstance(){
        return instance;
    }

    public Case getById(Id caseId){
        List<Case> lst = getBySetId(new Set<Id> { caseId });
        return lst.isEmpty() ? null : lst[0];
    }

    public List<Case> getBySetId(Set<Id> setIds){
        return [
            SELECT 
                Id,
                CaseNumber,
                ContaFinanceira__c
            FROM    
                Case
            WHERE 
                Id IN :setIds
        ];
    }

    public Case getByCaseNumber(String caseNumber) {
        if (String.isBlank(caseNumber)) return null;
        List<Case> lst = [
            SELECT Id, CaseNumber, ContaFinanceira__c, CPFContato__c, AccountId
            FROM Case
            WHERE CaseNumber = :caseNumber
            LIMIT 1
        ];
        return lst.isEmpty() ? null : lst[0];
    }

    public Case createBCSFSacCase(String cpf, Id accountId, String conversationId) {
        Case cs = new Case();
        cs.RecordTypeId    = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_SAC').getRecordTypeId();
        cs.Origin          = 'SAC';
        cs.CanalEntrada__c = 'Voz';

        if (String.isNotBlank(cpf))            cs.CPFContato__c     = cpf;
        if (accountId != null)                 cs.AccountId         = accountId;
        if (String.isNotBlank(conversationId)) cs.ConversationId__c = conversationId;

        insert cs;
        return cs;
    }
    

    public void updateCaseFields(Id caseId, Map<String, Object> fieldsToUpdate) {
        if (caseId == null || fieldsToUpdate == null || fieldsToUpdate.isEmpty()) return;
    
        Case cs = new Case(Id = caseId);
        for (String fieldName : fieldsToUpdate.keySet()) {
            Object value = fieldsToUpdate.get(fieldName);
            if (value != null && String.valueOf(value).trim() != '') {
                cs.put(fieldName, value);
            }
        }
        update cs;
    }
    
}