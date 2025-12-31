public class ConsultarPedidosClienteTO {
    public class Retorno {
        public String numeroPedido;
        public String modalidade;
        public String status;
        public String dataAtualizacaoStatus;
        public String statusCode;
		public Integer quantidadePedidos;
		public String type;
		public List<mapConsigmentCodeName> consigmentCodesNames;
    }

	public class responseWrapper {
		public List<Objects> objects;
	}

	public class Status {
		public String status;
		public String creationTime;
	}
	
	public class Consignments {
		public String type;
		public Delivery delivery;
		public Status status;
		public String consignmentCode;
		public List<Items> items;
	}
	
	public class Objects {
		public String orderCode;
		public List<Consignments> consignments;
	}
	
	public class Delivery {
		public String modality; 
		public String estimateDate;
	}

	public class Items {
		public String name;
	}

	public class mapConsigmentCodeName {
		public String consigmentCode;
		public String name;
		public String estimateDate;
		public String status;
	}
	
}