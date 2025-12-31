public class BuscarDetalhesChamadosTO {   
    public class ResponseWrapper {
        public List<Data> data; 
        public Integer NumberPages; 
        public Integer CurrentPage; 
        public Integer PreviousPage; 
    }

    public class Data {
        public Integer Protocolo;
        public String Status;
        public String Date_Z;
        public String DateUpdate;
        public Integer Resolution;
        public String ProtocoloResolutionDate;
        public String ExpertFullName;
        public String CategoryID;
        public String StatusPrazo;
        public String TagID;
        public Integer WorkflowStatus;
        public String ProtocoloFieldA;
        public String bodyProtocolo;
    }
}