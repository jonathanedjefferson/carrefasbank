public with sharing class FlowCriarProtocolo {
    @invocableMethod(label='Criar protocolo NeoAssist')
    public static List<Output> chamarAPIProtocolo(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            if(item.numPedido != null){
                item.numPedido = item.numPedido.replace('#', '');
            }
            
            NeoAssistApiTO.resposneWrapper newResult = NeoAssistAPI.makeAPIRequest(item.name, item.fieldU, item.expertId, item.Email, item.numPedido, item.catedoryId, item.observacao, item.wfObservacao, item.departamentoId, item.prazo);
            Output newOutput = new Output();

            if(newResult != null || newResult.Protocolo != null) {
                Integer numProtocolo = newResult.Protocolo.Protocolo;
                newOutput.Protocolo = numProtocolo;
            }
            newResult.Status = newResult.Status;

            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='expertId' required=true)
        public String expertId;

        @InvocableVariable(label='email' required=true)
        public String email;

        @InvocableVariable(label='wfObservacao' required=true)
        public String wfObservacao;

        @InvocableVariable(label='numPedido' required=false)
        public String numPedido;
        
        @InvocableVariable(label='catedoryId' required=true)
        public Integer catedoryId;

        @InvocableVariable(label='observacao' required=true)
        public String observacao;

        @InvocableVariable(label='departamentoId' required=true)
        public Integer departamentoId;

        @InvocableVariable(label='prazo' required=true)
        public Integer prazo;

        @InvocableVariable(label='name' required=false)
        public String name;

        @InvocableVariable(label='fieldU' required=false)
        public String fieldU;
    }

    public class Output{
        @InvocableVariable
        public Integer Protocolo;
        @InvocableVariable
        public Integer Status;
    }
}