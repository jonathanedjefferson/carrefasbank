global with sharing class ChangeWrapper {
    @AuraEnabled 
    public String reason;
    
    @AuraEnabled 
    public String receiptId;
    
    @AuraEnabled 
    public Integer discountValue;
    
    @AuraEnabled 
    public Integer incrementValue;
    
    @AuraEnabled 
    public String changeDate;
    
    @AuraEnabled 
    public List<ItemAddedWrapper> itemsAdded;
    
    @AuraEnabled 
    public List<ItemRemovedWrapper> itemsRemoved;
}