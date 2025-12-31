public without sharing class BCSF_ConsultarPropostaDAO {

    private static final BCSF_ConsultarPropostaDAO instance = new BCSF_ConsultarPropostaDAO();

    public static BCSF_ConsultarPropostaDAO getInstance() { return instance; }

    public Case getCase(String caseId) {
        List<Case> lst = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId];
        return lst.isEmpty() ? null : lst[0];
    }

    public List<ParametrosConsultaProposta__mdt> getListParametrosProposta() {
        return [
            SELECT  
                Label,
                DeveloperName,
                Label__c,
                TipoParametro__c,
                Valor__c
            FROM 
                ParametrosConsultaProposta__mdt
        ];
    }

    public PerfisConsultaProsposta__mdt getAcessoPerfil(String label) {
        return [
            SELECT  
                Label,
                DeveloperName,
                Acesso__c
            FROM 
                PerfisConsultaProsposta__mdt
            WHERE
            Label =: label
        ];
    }

}