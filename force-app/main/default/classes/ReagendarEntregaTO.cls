public class ReagendarEntregaTO {
	public String shippingId {get;set;} 
	public String useSameWarehouseAndLocation {get;set;} 
	public String currentCarrier {get;set;} 
	public String carrierId {get;set;} 
	public DeliveryWindowRange deliveryWindowRange {get;set;} 
	public DeliveryWindow deliveryWindow {get;set;} 
	public String useLastAddress {get;set;} 
	public AddressReceiver addressReceiver {get;set;} 
	public String comment {get;set;} 
	
	public class DeliveryWindowRange {
		public String from_z;
		public String to;
	}
	
	public class DeliveryWindow {
		public String initialDate {get;set;} 
		public String finalDate {get;set;} 
	}
	
	public class AddressReceiver {
		public String name {get;set;} 
	}
}