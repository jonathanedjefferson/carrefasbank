public with sharing class RetornoJanisWrapper {
    public RetornoJanisWrapper() {

    }

    @AuraEnabled 
    public String type;
    @AuraEnabled
    public string status;
    @AuraEnabled
    public String estimateDate;
    @AuraEnabled
    public String modality;
    @AuraEnabled
    public String carrierName;
    @AuraEnabled
    public String orderCode;
    @AuraEnabled
    public String orderDate;
    @AuraEnabled
    public Integer statusCode;
    @AuraEnabled
    public Boolean orderFound;
    @AuraEnabled
    public Integer howManyOrders;
}