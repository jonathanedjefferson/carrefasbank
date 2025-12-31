global with sharing class GetOrdersByCPFResponseWrapper {

    public GetOrdersByCPFResponseWrapper() {}
    
    @InvocableVariable
    @AuraEnabled 
    public List<ContentWrapper> content;
    
    @InvocableVariable
    @AuraEnabled 
    public PageInfo page;

    @InvocableVariable
    @AuraEnabled 
    public Integer statusCode;
}