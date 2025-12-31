global with sharing class ItemWrapper {
    @AuraEnabled 
    public String id;
    
    @AuraEnabled 
    public String name;
    
    @AuraEnabled 
    public Integer unitPrice;
    
    @AuraEnabled 
    public Integer quantity;
    
    @AuraEnabled 
    public Integer subtotal;
    
    @AuraEnabled 
    public String descriptionUrl;
    
    @AuraEnabled 
    public String imageUrl;
}