public with sharing class MelhorDiaCompraCockpitController {
    @AuraEnabled
    public static string getMelhorDiaCompra(String numeroConta, String cpf, String unidade, String canal){
        return MelhorDiaCompraCockpit.getMelhorDiaCompra(numeroConta, cpf, unidade, canal);
    }
    
    @AuraEnabled
    public static MelhorDiaCompraCockpit.ResponseAPI getDataULtimaFatura(String numeroConta, String cpf, String unidade, String canal){
        return MelhorDiaCompraCockpit.getDataULtimaFatura(numeroConta, unidade, cpf, canal);
    }

    @AuraEnabled
    public static ContaFinanceira__c getInfoContaFinanceira(String IdCF){
        return BCSF_CancelamentoContaDAO.getInstance().getContaFinanceira(IdCF);
    }
}