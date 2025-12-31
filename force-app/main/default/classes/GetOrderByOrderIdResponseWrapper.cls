public class GetOrderByOrderIdResponseWrapper{
	public String orderCode;  //string
	public String origin;  //string
	public String principalCode;  //string
	public String deliveryNumber;  //string
	public Decimal totalValue;  //0
	public Decimal totalItemValue;  //0
	public Decimal totalFreight;  //0
	public Decimal totalDiscounts;  //0
	public Decimal totalTaxValue;  //0
	public Decimal totalChangeValue;  //0
	public Decimal salesChannelId;  //0
	public String salesChannel;  //string
	public String status;  //string
	public String creationDate;  //string
	public String lastUpdateDate;  //string
	public boolean allowCancellation;
	public cls_customer customer;
	public cls_billingAddress billingAddress;
	public cls_seller seller;
	public PaymentsOutputTDCA[] payments;
	public ConsignmentsWrapper[] consignments;
	public Actions actions;
	public Flags flags;
	public GetOrderByOrderIdResponseWrapper(){
	  this.consignments = new List<ConsignmentsWrapper>();
	}
	public cls_changes[] changes;
	 public class cls_customer {
	  public String firstName;  //string
	  public String lastName;  //string
	  public String email;  //string
	  public String documentType;  //string
	  public String documentNumber;  //string
	}
	 public class cls_billingAddress {
	  public String street;  //string
	  public String number_z;  //string
	  public String complement;  //string
	  public String neighborhood;  //string
	  public String city;  //string
	  public String state;  //string
	  public String country;  //string
	  public String postalCode;  //string
	}
	 public class cls_seller {
	  public String id;  //string
	  public String name;  //string
	}
	 public class cls_payments {
	  public String type;  //string
	  public String brand;  //string
	  public Decimal installments;  //0
	  public Decimal value;  //0
	  public String paymentStatus;  //string
	  public String url;  //string
	  public String acquirer;  //string
	  public String dueDate;  //string
	  public String authorizedDate;  //string
	}
	 public class cls_delivery {
	  public cls_delivery(){
		this.deliveryAddress = new cls_deliveryAddress();
		this.pickupInfo = new cls_pickupInfo();
	  }
	  public String modality;  //string
	  public String warehouseName;  //string
	  public String warehouseId;  //string	
	  public String deliveryOption;  //string
	  public String deliveryCompany;  //string
	  public String trackingCode;  //string
	  public String shippingEstimateTime;  //string
	  public String shippingEstimate;  //string
	  public String shippingEstimateDate;  //string
	  public String shippingWindowStartDate;  //string
	  public String shippingWindowEndDate;  //string
	  public String shippingConcludedTime;
	  public String trackingLink;
	  public cls_deliveryAddress deliveryAddress;
	  public cls_pickupInfo pickupInfo;
	}
	 public class cls_deliveryAddress {
	  public String street;  //string
	  public String number_z;  //string
	  public String complement;  //string
	  public String neighborhood;  //string
	  public String city;  //string
	  public String state;  //string
	  public String country;  //string
	  public String postalCode;  //string
	}
	 public class cls_pickupInfo {
	  public String storeName;  //string
	  public cls_address address;
	}
	 public class cls_address {
	  public String street;  //string
	  public String number_z;  //string
	  public String complement;  //string
	  public String neighborhood;  //string
	  public String city;  //string
	  public String state;  //string
	  public String country;  //string
	  public String postalCode;  //string
	}
	 public class cls_items {
	  public String id;  //string
	  public String name;  //string
	  public Decimal unitPrice;  //0
	  public Decimal quantity;  //0
	  public Decimal subtotal;  //0
	  public String descriptionUrl;  //string
	  public String orderLineId;
	  public String imageUrl;  //string
	}
	 public class cls_consignmentStatusHistory {
	  public String status;  //string
	  public String origin;  //string
	  public String creationTime;  //string
	  public String description;
	}
	 public class cls_changes {
	  public String reason;  //string
	  public String receiptId;  //string
	  public Decimal discountValue;  //0
	  public Decimal incrementValue;  //0
	  public String changeDate;  //string
	  public cls_itemsAdded[] itemsAdded;
	  public cls_itemsRemoved[] itemsRemoved;
	}
	 public class cls_itemsAdded {
	  public String id;  //string
	  public String name;  //string
	  public Decimal unitPrice;  //0
	  public Decimal quantity;  //0
	  public Decimal subtotal;  //0
	  public String descriptionUrl;  //string
	  public String imageUrl;  //string
	}
	 public class cls_itemsRemoved {
	  public String id;  //string
	  public String name;  //string
	  public Decimal unitPrice;  //0
	  public Decimal quantity;  //0
	  public Decimal subtotal;  //0
	  public String descriptionUrl;  //string
	  public String imageUrl;  //string
	}
	public class Actions{
	  public Boolean returnAllowed;
	  public Boolean getInvoiceAllowed;
	  public Boolean getBankSlipAllowed;
	  public Boolean refundOrderAllowed;
	  public Boolean cancelOrderAllowed;
	  public List<String> consignmentsWithInvoiceAllowed;
	}
	public class Flags{
	  public boolean deliveryLate;
		  public boolean suspended;
		  public boolean suspendedStatus;
		  public boolean linkedOrders;
		  public boolean international;
		  public boolean carrefourEnvios;
	}
	public class cls_marketplaceInfo {
	  public String trackingCode;  //AA223634660BR
	  public String labelCarrefourEnvios;  //https://storagefusion.blob.core.windows.net/fusionetiquetas/9983/b41663981f9f47791240e2add163a036.pdf
	  public boolean wevoReceivedCancelRequest;
	  public cls_miraklStatusHistory[] miraklStatusHistory;
	}
	public class cls_miraklStatusHistory {
	  public String status;  //Entrega Realizada Normalmente
	  public String origin;  //MIRAKL
	  public String creationTime;  //02/08/2024 15:30:00
	}
  }