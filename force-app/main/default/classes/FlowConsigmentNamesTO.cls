global with sharing class FlowConsigmentNamesTO {
    @AuraEnabled @InvocableVariable
    public String consigmentCode;
    @AuraEnabled @InvocableVariable
    public String name;
    @AuraEnabled @InvocableVariable
    public String estimateDate;
    @AuraEnabled @InvocableVariable
    public String status;
}