public class ConsultarStatusPedidoTO {
	public class Status {
		public String status;
	}

	public class Consignments {
		public List<Status> status;
	}

    public class responseWrapper {
        public String orderCode;
        public List<Consignments> consignments;
	}

}