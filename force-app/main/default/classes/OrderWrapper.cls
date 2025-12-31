global with sharing class OrderWrapper {
    @AuraEnabled 
    public String orderCode;
    
    @AuraEnabled 
    public String principalCode;
    
    @AuraEnabled 
    public String deliveryNumber;
    
    @AuraEnabled 
    public Integer totalValue;
    
    @AuraEnabled 
    public Integer totalItemValue;
    
    @AuraEnabled 
    public Integer totalFreight;
    
    @AuraEnabled 
    public Integer totalDiscounts;
    
    @AuraEnabled 
    public Integer totalTaxValue;
    
    @AuraEnabled 
    public Integer totalChangeValue;
    
    @AuraEnabled 
    public Integer salesChannelId;
    
    @AuraEnabled 
    public String salesChannel;
    
    @AuraEnabled 
    public String status;
    
    @AuraEnabled 
    public String creationDate;
    
    @AuraEnabled 
    public String lastUpdateDate;
    
    @AuraEnabled 
    public Boolean allowCancellation;
    
    @AuraEnabled 
    public CustomerWrapper customer;
    
    @AuraEnabled 
    public BillingAddressWrapper billingAddress;
    
    @AuraEnabled 
    public SellerWrapper seller;
    
    @AuraEnabled 
    public List<PaymentWrapper> payments;
    
    @AuraEnabled 
    public List<ConsignmentWrapper> consignments;
    
    @AuraEnabled 
    public List<ChangeWrapper> changes;
}