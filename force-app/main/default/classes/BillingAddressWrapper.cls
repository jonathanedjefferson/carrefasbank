global with sharing class BillingAddressWrapper {
    @AuraEnabled 
    public String street;
    
    @AuraEnabled 
    public String number_z;
    
    @AuraEnabled 
    public String complement;
    
    @AuraEnabled 
    public String neighborhood;
    
    @AuraEnabled 
    public String city;
    
    @AuraEnabled 
    public String state;
    
    @AuraEnabled 
    public String country;
    
    @AuraEnabled 
    public String postalCode;
}