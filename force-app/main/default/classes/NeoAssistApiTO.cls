public class NeoAssistApiTO {
    public jsonData jsonData;

    public class jsonData{
        public Integer CategoryID;
        public Data Data;
        public Integer Origin;
        public String Observacao;
        public String AguardandoComplemento;
        public String ResolverProtocolo;
        public String ClassificacaoCRM;
        public String rbEncaminhar;
        public Integer DepartamentoID;
        public String WFObservacao;
        public String Assunto;
        public Integer Prazo;
    }

    public class Data {
        public String Name;
        public String EMail;
        public String ProtocoloFieldA;
        public String FieldU;
    }

	public class Workflow {
		public Boolean success;
		public String msg;
		public WF WF;
	}
    
	public class WF {
		public Integer Status;
		public String Info;
		public String WorkflowID;
	}

    public class Protocolo {
        public Integer Protocolo;
    }

    public class resposneWrapper {
        public Protocolo Protocolo;
        public Integer Status;
    }
}