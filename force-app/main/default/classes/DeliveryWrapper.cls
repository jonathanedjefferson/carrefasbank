global with sharing class DeliveryWrapper {
    @AuraEnabled 
    public String modality;
    
    @AuraEnabled 
    public String deliveryOption;
    
    @AuraEnabled 
    public String deliveryCompany;
    
    @AuraEnabled 
    public String trackingCode;
    
    @AuraEnabled 
    public String shippingEstimateTime;
    
    @AuraEnabled 
    public String shippingEstimate;
    
    @AuraEnabled 
    public String shippingEstimateDate;
    
    @AuraEnabled 
    public String shippingWindowStartDate;
    
    @AuraEnabled 
    public String shippingWindowEndDate;
    
    @AuraEnabled 
    public DeliveryAddressWrapper deliveryAddress;
    
    @AuraEnabled 
    public PickupInfoWrapper pickupInfo;
}