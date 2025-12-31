public class ConsultaPedidoResponse {
    @AuraEnabled @InvocableVariable  
    public String orderId; 
    @AuraEnabled @InvocableVariable 
    public String status;
    @AuraEnabled @InvocableVariable 
    public Date creationDate;
    @AuraEnabled @InvocableVariable 
    public String isAnyDelivered;
    @AuraEnabled @InvocableVariable 
    public String ShippingEstimatedDateMin;
    @AuraEnabled @InvocableVariable 
    public String ShippingEstimatedDateMax;

}