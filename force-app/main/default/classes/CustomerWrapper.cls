global with sharing class CustomerWrapper {
    @AuraEnabled 
    public String firstName;
    
    @AuraEnabled 
    public String lastName;
    
    @AuraEnabled 
    public String email;
    
    @AuraEnabled 
    public String documentType;
    
    @AuraEnabled 
    public String documentNumber;
}