public with sharing class MetadataValidationConfigDAO {
    
    public static Set<String> BuscaPerfisBypassCF() {
        Set<String> perfis = new Set<String>();
        PerfisBypass__c pf = PerfisBypass__c.getInstance();
        
        if (pf != null && !String.isBlank(pf.Perfis__c)) {
            for (String perf : pf.Perfis__c.split(';')) {
                if (!String.isBlank(perf)) {
                    perfis.add(perf.trim());
                }
            }
        }
        
        return perfis;
    }
    
    public static User BuscaPerfilUsuario(Id userId) {
        try {
            return [
                SELECT Id, Profile.Name
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('⚠️ Erro ao buscar User: ' + e.getMessage());
            return null;
        }
    }
    
    
  
    public static IntervaloAtualizacaoDados__mdt BuscaTempoCF() {
        try {
            return [
                SELECT Tempo__c 
                FROM IntervaloAtualizacaoDados__mdt 
                WHERE DeveloperName = 'ContaFinanceira'
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('⚠️ Erro ao buscar metadado IntervaloAtualizacaoDados__mdt: ' + e.getMessage());
            return null;
        }
    }
    
    
    public static ContaFinanceira__c BuscaContaFinanceiraById(Id contaFinanceiraId) {
        try {
            return [
                SELECT DataLimiteDesbloqueio__c, UltimoOperador__c,StatusConta__c
                FROM ContaFinanceira__c
                WHERE Id = :contaFinanceiraId
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('⚠️ Erro ao buscar ContaFinanceira__c: ' + e.getMessage());
            return null;
        }
    }

    
}