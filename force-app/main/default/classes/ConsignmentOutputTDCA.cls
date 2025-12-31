public with sharing class ConsignmentOutputTDCA {
    
    public ConsignmentOutputTDCA(){
        this.itens = new List<ItemsOutputTDCA>();
    }
    @AuraEnabled
    public List<ItemsOutputTDCA> itens;
    @AuraEnabled
    public String consignmentCode;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String trackingLink;
    @AuraEnabled
    public String shippingEstimateDate;
    @AuraEnabled
    public String modality;
    
    
}