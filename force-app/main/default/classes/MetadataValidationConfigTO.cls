public with sharing class MetadataValidationConfigTO {
    
    public class MetadataValidationUserWrapper {
        @AuraEnabled public String perfisBypass;
        @AuraEnabled public String perfilUsuario;
    }
     public class MetadataValidationWrapper {
        @AuraEnabled public Decimal tempoLimite;
        @AuraEnabled public String perfisBypass;
        @AuraEnabled public String perfilUsuario;
        @AuraEnabled public DateTime dataLimiteDesbloqueio;
        @AuraEnabled public Id ultimoOperador;
        @AuraEnabled public String statusConta;
    }
}