global with sharing class PageInfo {
    @AuraEnabled 
    public Integer size;
    
    @AuraEnabled 
    public Integer number_z;
    
    @AuraEnabled 
    public Integer totalElements;
    
    @AuraEnabled 
    public Integer totalPages;
}