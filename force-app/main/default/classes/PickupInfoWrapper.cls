global with sharing class PickupInfoWrapper {
    @AuraEnabled 
    public String storeName;
    
    @AuraEnabled 
    public AddressWrapper address;
}