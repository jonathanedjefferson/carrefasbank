public class ConsultIncident {
    
    public class Response{
        
        public String orderCode;
        public String consignmentCode;
        public String createdAt;
        public Customer customer;
        public String status;
        public List<Incident> incident;
        
         public Response(String orderCode, String consignmentCode, String createdAt, Customer customer, String status, List<Incident> incident){
            this.orderCode = orderCode; 
            this.consignmentCode = consignmentCode; 
            this.createdAt = createdAt;
            this.customer = customer;
            this.status = status;
            this.incident = incident;
        }

        public Response(){
            this.incident = new List<Incident>();
        }

        
    }
    
    public class Customer {
        public String document;
        public String email;
        public String firstName;
        public String lastName;
        
        public Customer(String document, String email, String firstName, String lastName){
           	this.document = document;
            this.email = email;
            this.firstName = firstName;
            this.lastName = lastName;
            
        }
    }
    
    public class Incident {
        public String id;
        public String hasRefund;
        public String status;
        public String reasonDescription;
        public String reasonCode;
        public Double price;
        public String productSku;
        public String productDescription;
        public String createdAt;
        
        public Incident(String id, String hasRefund, String status, String reasonDescription, String reasonCode, Double price, String productSku, String productDescription, String createdAt){
            this.id = id;
            this.hasRefund = hasRefund;
            this.status = status;
            this.reasonDescription = reasonDescription;
            this.reasonCode = reasonCode;
            this.price =  price;
            this.productSku = productSku;
            this.productDescription = productDescription;
            this.createdAt = createdAt;
        }
    }
}