global with sharing class ContentWrapper {
    @AuraEnabled 
    public String code;
    
    @AuraEnabled 
    public String principalCode;
    
    @AuraEnabled 
    public String createdAt;
    
    @AuraEnabled 
    public OrderWrapper order;
    
}