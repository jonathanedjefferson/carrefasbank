global with sharing class ConsignmentStatusHistoryWrapper {
    @AuraEnabled 
    public String status;
    
    @AuraEnabled 
    public String origin;
    
    @AuraEnabled 
    public String creationTime;
}