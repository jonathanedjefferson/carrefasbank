public class ConsultarCodigoPostagemTO {
    public class Retorno {
        public String codigoPostagem;
        public String shippingPriorityName;
        public String orderId;
		public String lastUpdatedDate;
		public String orderLineState;
		public String orderLineStateReasonCode;
		public String orderLineStateReasonLabel;
		public String shippedDate;
		public String shippingDeadline;
        public Integer statusCode;
    }

    public class Orders {
		public List<Order_additional_fields> order_additional_fields;
		public String last_updated_date;
		public String shipping_deadline;
		public List<Order_lines> order_lines;
	}

	public List<Orders> orders;
    
	public class Order_additional_fields {
		public String code;
		public String type;
		public String value;
	}

	public class Order_lines {
		public String order_line_state;
		public String order_line_state_reason_code;
		public String order_line_state_reason_label;
		public String shipped_date;
	}
}