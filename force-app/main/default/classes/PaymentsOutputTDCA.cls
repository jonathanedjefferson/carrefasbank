public with sharing class PaymentsOutputTDCA {

    @AuraEnabled
    public String type;
    @AuraEnabled
    public String brand;
    @AuraEnabled
    public Integer installments;
    @AuraEnabled
    public Decimal value;
    @AuraEnabled
    public String acquirer;
    @AuraEnabled
    public String nsu;
    @AuraEnabled
    public String authorizedDate;
    @AuraEnabled
    public String tid;

}