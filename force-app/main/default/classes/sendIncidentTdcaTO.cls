public class sendIncidentTdcaTO {
    
    // Classe interna para Request (Requisição)
    public class request {
        public String orderId;
        public String consignmentId;
        public String orderLineId; 
        public String contactReason;
    }

    public class response {
        public Integer status;
        public String message;
    }
}