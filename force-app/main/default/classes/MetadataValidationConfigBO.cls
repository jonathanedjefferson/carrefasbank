public with sharing class MetadataValidationConfigBO {
    
    public static MetadataValidationConfigTO.MetadataValidationUserWrapper getUserValidationData(Id userId) {
        
        MetadataValidationConfigTO.MetadataValidationUserWrapper wrapper =
            new MetadataValidationConfigTO.MetadataValidationUserWrapper();
        
        
        Set<String> perfis = MetadataValidationConfigDAO.BuscaPerfisBypassCF();
        wrapper.perfisBypass = perfis != null && !perfis.isEmpty()
            ? String.join(new List<String>(perfis), ';')
            : '';
        
        
        
        User usuario = MetadataValidationConfigDAO.BuscaPerfilUsuario(userId);
        if (usuario != null) {
            wrapper.perfilUsuario = usuario.Profile.Name;
        }
        
        return wrapper;
    }
    
    public static Integer getTempoLimiteCF() {
        IntervaloAtualizacaoDados__mdt getempoLimite = MetadataValidationConfigDAO.BuscaTempoCF();
        Integer tempoLimite = getempoLimite != null ? Integer.valueOf(getempoLimite.Tempo__c) : null;
        if(tempoLimite != null) {
            return tempoLimite;
        }
        System.debug('⚠️ TempoLimite nulo');
        return null;
    }
    public static String getPerfisCF() {
        Set<String> perfSet = MetadataValidationConfigDAO.BuscaPerfisBypassCF();
        
        if (perfSet != null && !perfSet.isEmpty()) {
            return String.join(new List<String>(perfSet), ';');
        }
        
        return '';
    }
    
    public static MetadataValidationConfigTO.MetadataValidationWrapper getAllValidationData(Id contaFinanceiraId, Id userId) {
        MetadataValidationConfigTO.MetadataValidationWrapper wrapper = new MetadataValidationConfigTO.MetadataValidationWrapper();
        
        IntervaloAtualizacaoDados__mdt tempoMeta = MetadataValidationConfigDAO.BuscaTempoCF();
        wrapper.tempoLimite = tempoMeta != null ? tempoMeta.Tempo__c : null;
        
        Set<String> perfis = MetadataValidationConfigDAO.BuscaPerfisBypassCF();
        wrapper.perfisBypass = String.join(new List<String>(perfis), ';');
        System.debug('Perfil do usuário: ' + wrapper.perfisBypass);
        ContaFinanceira__c conta = MetadataValidationConfigDAO.BuscaContaFinanceiraById(contaFinanceiraId);
        if (conta != null) {
            wrapper.dataLimiteDesbloqueio = conta.DataLimiteDesbloqueio__c;
            wrapper.ultimoOperador = conta.UltimoOperador__c;
            wrapper.statusConta= conta.StatusConta__c;
        }
        
        User usuario = MetadataValidationConfigDAO.BuscaPerfilUsuario(userId);
        if (usuario != null) {
            wrapper.perfilUsuario = usuario.Profile.Name;
            
        }
        return wrapper;
    }
    
}