public with sharing class FlowCriarProtocoloAnexo {
    @invocableMethod(label='Criar protocolo NeoAssist com anexo')
    public static List<Output> chamarAPIProtocolo(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            if(item.numPedido != null){
                item.numPedido = item.numPedido.replace('#', '');
            }
            String idEmpresa = item.idEmpresa != null ? item.idEmpresa : '1';
            String resolverProtocolo = item.resolverProtocolo != null ? item.resolverProtocolo : '';
            String fieldU = item.fieldU != null ? item.fileId : '';
            Integer departamentoId = item.departamentoId != null ? item.departamentoId : 1;
            Integer prazo = item.prazo != null ? item.prazo : 24;
            String wfObservacao = item.wfObservacao != null ? item.wfObservacao : '';
            String assunto = item.assunto != null ? item.assunto : '';

            NeoAssistApiTO.resposneWrapper newResult = NeoAssistAPIAnexo.makeAPIRequest(item.name, fieldU, item.fileId, item.expertId, item.Email, item.numPedido, item.catedoryId, item.observacao, wfObservacao, departamentoId, prazo, idEmpresa, item.extencaoArquivo, item.origin, item.aguardandoComplemento, resolverProtocolo, assunto);
            Output newOutput = new Output();

            if(newResult.Status == 200) {
                Integer numProtocolo = newResult.Protocolo.Protocolo;
                newOutput.Protocolo = numProtocolo;
            }
            
            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Content Vertion Id' required=true)
        public String fileId;

        @InvocableVariable(label='expertId' required=true)
        public String expertId;

        @InvocableVariable(label='email' required=true)
        public String email;

        @InvocableVariable(label='wfObservacao' required=false)
        public String wfObservacao;

        @InvocableVariable(label='numPedido' required=false)
        public String numPedido;
        
        @InvocableVariable(label='categoryId' required=true)
        public Integer catedoryId;

        @InvocableVariable(label='observacao' required=false)
        public String observacao;

        @InvocableVariable(label='departamentoId' required=false)
        public Integer departamentoId;

        @InvocableVariable(label='prazo' required=false)
        public Integer prazo;

        @InvocableVariable(label='name' required=false)
        public String name;

        @InvocableVariable(label='fieldU' required=false)
        public String fieldU;

        @InvocableVariable(label='brand' required=false)
        public String idEmpresa; 
        
        @InvocableVariable(label='extencaoArquivo' required=true)
        public String extencaoArquivo;
        
        @InvocableVariable(label='origin' required=true)
        public Integer origin;

        @InvocableVariable(label='aguardandoComplemento' required=true)
        public String aguardandoComplemento;
     
        @InvocableVariable(label='resolverProtocolo' required=false)
        public String resolverProtocolo;

        @InvocableVariable(label='assunto' required=false)
        public String assunto;
    }

    public class Output{
        @InvocableVariable
        public Integer Protocolo;
    }
}