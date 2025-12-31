public with sharing class MetadataValidationConfigController { 
    
    @AuraEnabled
    public static MetadataValidationConfigTO.MetadataValidationUserWrapper GetUserValidationData(Id userId) {
        return MetadataValidationConfigBO.getUserValidationData(userId);
    }

     @AuraEnabled
    public static Integer GetTempoLimiteCF() {
        return MetadataValidationConfigBO.getTempoLimiteCF();
    }

    @AuraEnabled
    public static String GetPerfisCF() {
        return MetadataValidationConfigBO.getPerfisCF();
    }

    @AuraEnabled
    public static MetadataValidationConfigTO.MetadataValidationWrapper GetAllValidationData(Id contaFinanceiraId, Id userId) {
        return MetadataValidationConfigBO.getAllValidationData(contaFinanceiraId, userId);
    }
}