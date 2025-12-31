global with sharing class ConsignmentWrapper {
    @AuraEnabled 
    public String consignmentCode;
    
    @AuraEnabled 
    public String consignmentState;
    
    @AuraEnabled 
    public String invoiceUrl;
    
    @AuraEnabled 
    public String invoiceKey;
    
    @AuraEnabled 
    public String type;
    
    @AuraEnabled 
    public String status;
    
    @AuraEnabled 
    public Integer totalValue;
    
    @AuraEnabled 
    public Integer totalItemValue;
    
    @AuraEnabled 
    public Integer totalFreight;
    
    @AuraEnabled 
    public Integer totalDiscounts;
    
    @AuraEnabled 
    public DeliveryWrapper delivery;
    
    @AuraEnabled 
    public List<ItemWrapper> items;
    
    @AuraEnabled 
    public List<ConsignmentStatusHistoryWrapper> consignmentStatusHistory;
}