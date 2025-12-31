public class APIJanisV2TO {
	public class ResponseWrapper {
		public List<Objects> objects {get;set;} 
	}

	public class responseWithNoList{
        public Objects objects;
    }

	public class Status {
		public String status {get;set;} 
	}
	
	public class Consignments {
		public String type {get;set;} 
		public Status status {get;set;} 
		public Delivery delivery {get;set;} 
		public List<Items> items;
	}
		
	public class Objects {
		public List<Consignments> consignments {get;set;} 
		public String orderCode {get;set;} 
		public String orderDate {get;set;} 
	}
	
	public class Delivery {
		public String estimateDate {get;set;} 
		public String modality {get;set;} 
		public String carrierName{get;set;} 
	}

	public class Items {
		public String name;
	}

	public class Retorno {
		public String type;
		public string status;
		public String estimateDate;
		public String carrierName;
		public String modality;
		public String orderCode;
		public String orderDate;
		public Integer statusCode;
		public Boolean orderFound;
		public Integer howManyOrders;
		public String items;
	}
}