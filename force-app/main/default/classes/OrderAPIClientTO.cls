public  class OrderAPIClientTO {
    
    public class ResponseWrapper {
         @InvocableVariable  
        public List<Objects> objects;
        public Paging paging;
    }
    
    public class responseWithNoList{
        public Objects objects;
        public Paging paging;
    }

    public class Objects {
         @InvocableVariable  
        public List<Consignments> consignments;
         @InvocableVariable 
        public String sellersName; 
         @InvocableVariable
        public String orderCode; 
         @InvocableVariable
        public String orderDate;
    }
    public class Consignments {
         @InvocableVariable
        public String type;
         @InvocableVariable
        public ConsignmentStatus status;
         @InvocableVariable
        public Delivery delivery;
         @InvocableVariable
        public List<Item> items;
    }
    public class ConsignmentStatus {
         @InvocableVariable
        public String status;
        @InvocableVariable
        public String creationTime;
    }
    public class Delivery {
         @InvocableVariable
        public String estimateDate;
         @InvocableVariable
        public String modality;
      
    }
    public class Item {
        @InvocableVariable
        public String name;
       
    }
    public class Paging {
        public Integer offset;
        public Integer totalRecords;
    }
}