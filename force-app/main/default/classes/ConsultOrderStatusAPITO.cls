public class ConsultOrderStatusAPITO {
    
    public class ResponseWrapper{ 
        @InvocableVariable  
        public List<List_Z> list_Z; 
    }
    public class List_Z{
        @InvocableVariable  
        public String orderId; 
        @InvocableVariable 
        public String status;
        @InvocableVariable 
        public String creationDate;
        @InvocableVariable 
        public String isAnyDelivered;
        @InvocableVariable 
        public String ShippingEstimatedDateMax;
        @InvocableVariable 
        public String ShippingEstimatedDateMin;
    }
}