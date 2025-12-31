public with sharing class BCSF_SegundaViaCartaoDAO {
    private static final BCSF_SegundaViaCartaoDAO instance = new BCSF_SegundaViaCartaoDAO();
    public static BCSF_SegundaViaCartaoDAO getInstance(){
        return instance;
    }
    public List<StatusBloqueadosModoCartao__mdt> getStatus() {
        List<StatusBloqueadosModoCartao__mdt> lst = [
            SELECT  
                Status__c
            FROM 
                StatusBloqueadosModoCartao__mdt
        ];
        return lst.isEmpty() ? null : lst;
    }

    public Case getCase(String caseId){
        return [SELECT CaseNumber FROM Case WHERE Id = : caseId];
    }

}