public class ItemsOutputTDCA {
        
    public ItemsOutputTDCA(String id, String name, Decimal unitPrice, Decimal quantity, Decimal subtotal) {
        this.id = id;
        this.name = name;
        this.unitPrice = unitPrice != null ? unitPrice : 0;
        this.quantity = quantity != null ? quantity : 0;
        this.subtotal = subtotal != null ? subtotal : 0;
    }

    @AuraEnabled
    public String id;	//string
    @AuraEnabled
    public String consigmentCode;	//string
    @AuraEnabled
    public String name;	//string
    @AuraEnabled
    public Decimal unitPrice;	//0
    @AuraEnabled
    public Decimal quantity;	//0
    @AuraEnabled
    public Decimal subtotal;	//0
    @AuraEnabled
    public String descriptionUrl;	//string
    @AuraEnabled
    public String orderLineId;	//string
    @AuraEnabled
    public String imageUrl;	//string
}