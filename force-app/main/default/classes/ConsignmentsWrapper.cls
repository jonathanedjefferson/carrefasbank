global class ConsignmentsWrapper {
    public ConsignmentsWrapper(){
        this.delivery = new GetOrderByOrderIdResponseWrapper.cls_delivery();
        this.flags = new GetOrderByOrderIdResponseWrapper.flags();
    }
    @AuraEnabled @InvocableVariable
    public String consignmentCode;

    @AuraEnabled @InvocableVariable
    public String mostRecentConsignmentStatus;
    
    @AuraEnabled @InvocableVariable
    public String consignmentState;

    @AuraEnabled @InvocableVariable
    public String invoiceUrl;

    @AuraEnabled @InvocableVariable
    public String invoiceKey;

    @AuraEnabled @InvocableVariable
    public String type;

    @AuraEnabled @InvocableVariable
    public String status;

    @AuraEnabled @InvocableVariable
    public Decimal totalValue;

    @AuraEnabled @InvocableVariable
    public Decimal totalItemValue;

    @AuraEnabled @InvocableVariable
    public Decimal totalFreight;

    @AuraEnabled @InvocableVariable
    public Decimal totalDiscounts;

    @AuraEnabled @InvocableVariable
    public Boolean suspended;

    @AuraEnabled @InvocableVariable
    public Boolean deliveryLate;

    @AuraEnabled @InvocableVariable
    public Boolean cancelOrderAlloed;

    @AuraEnabled @InvocableVariable
    public Boolean refundOrderAllowed;

    @AuraEnabled @InvocableVariable
    public String modality;

    @AuraEnabled @InvocableVariable
    public String deliveryCompany;

    @AuraEnabled @InvocableVariable
    public String trackingLink;

    @AuraEnabled @InvocableVariable
    public String shippingEstimateDate;

    @AuraEnabled @InvocableVariable
    public String shippingConcludedTime;

    @AuraEnabled
    public GetOrderByOrderIdResponseWrapper.Actions actions;


    public GetOrderByOrderIdResponseWrapper.cls_marketplaceInfo marketplaceInfo;
    
    public GetOrderByOrderIdResponseWrapper.cls_delivery delivery;

    public GetOrderByOrderIdResponseWrapper.flags flags;

    public ItemsOutputTDCA[] items;

    public GetOrderByOrderIdResponseWrapper.cls_consignmentStatusHistory[] consignmentStatusHistory;
}