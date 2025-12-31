public class ConsultarChaveNFTO {
    public class Retorno {
		public String orderCode;
        public Integer statusCode;
        public String key;
        public String paymentMethod;
    }

    public List<Consignments> consignments;
	public List<Payments> payments; 
	
	public class Consignments {
		public List<Invoices> invoices; 
	}
	
	public class Payments {
		public String paymentMethod;
	}
	
	public class Invoices {
		public String key;
	}
}