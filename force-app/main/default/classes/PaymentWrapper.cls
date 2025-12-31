global with sharing class PaymentWrapper {
    @AuraEnabled 
    public String type;
    
    @AuraEnabled 
    public String brand;
    
    @AuraEnabled 
    public Integer installments;
    
    @AuraEnabled 
    public Integer value;
    
    @AuraEnabled 
    public String paymentStatus;
    
    @AuraEnabled 
    public String url;
    
    @AuraEnabled 
    public String acquirer;
    
    @AuraEnabled 
    public String dueDate;
    
    @AuraEnabled 
    public String authorizedDate;
}