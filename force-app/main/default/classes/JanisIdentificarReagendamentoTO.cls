public class JanisIdentificarReagendamentoTO {
    public class Retorno {
		public String status;
        public String commerceSequentialId;
        public String receiverName;
        public String receiverDocument;
        public String paymentGroup;
        public String carrierId;
        public String deliveryId;
		public String shippingUrl;
        public String initialDate;
        public String finalDate;
        public Integer statusCode;
		public String items;
		public String commerceSalesChannel;
    }

	public String status {get;set;}
	public String commerceSequentialId {get;set;} 
	public String commerceSalesChannel {get;set;} 
	public String Id;
	public List<Addresses> addresses {get;set;} 
	public List<Payments> payments {get;set;} 
	public List<Shippings> shippings {get;set;} 
	public List<Items> items {get;set;}

	public class Items {
		public String name;
	}

	public class Payments { 
		public String paymentGroup {get;set;} 
	}
	
	public class Addresses {
		public String receiverName {get;set;} 
		public String receiverDocument {get;set;} 
	}
	
	public class DeliveryWindow {
		public String initialDate {get;set;} 
		public String finalDate {get;set;} 
	}
	
	public class Shippings {
		public String carrierId {get;set;} 
		public String deliveryId {get;set;} 
		public DeliveryWindow deliveryWindow {get;set;} 
	}
}