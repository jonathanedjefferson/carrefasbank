global with sharing class FlowGetOrderByIdTDCAResponseWrapper {

    @AuraEnabled @InvocableVariable
    public Boolean getBankSlipAllowed;

    @AuraEnabled @InvocableVariable
    public String sellerName;
    
    @AuraEnabled @InvocableVariable
    public String email;

    @AuraEnabled @InvocableVariable
    public String modality; 

    @AuraEnabled @InvocableVariable
    public String status;

    @AuraEnabled @InvocableVariable
    public String statusPedido;

    @AuraEnabled @InvocableVariable
    public String firstName;
    
    @AuraEnabled @InvocableVariable
    public String lastName;
    
    @AuraEnabled @InvocableVariable
    public String document;
    
    @AuraEnabled @InvocableVariable
    public String totalValuePedido;
    
    @AuraEnabled @InvocableVariable
    public String creationDate;

    @AuraEnabled @InvocableVariable
    public Boolean deliveryLate;

    @AuraEnabled @InvocableVariable
    public List<String> consignmentsWithInvoiceAllowed;

    @AuraEnabled @InvocableVariable
    public List<ItemsOutputTDCA> items;
    
    @AuraEnabled @InvocableVariable
    global List<ConsignmentsWrapper> consignments;

    @AuraEnabled @InvocableVariable
    global List<PaymentsOutputTDCA> payments;

    public class Items {
        public String unitPrice;
    }
}