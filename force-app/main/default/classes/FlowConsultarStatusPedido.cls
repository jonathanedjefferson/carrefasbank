public class FlowConsultarStatusPedido {
    @InvocableMethod(label='Consultar se a NFE foi emitida')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            item.orderCode = item.orderCode.replace('#', '');
            Boolean resultado = ConsultarStatusPedido.notaFiscalEmitida(item.orderCode);

            novoOutput.result = resultado;

            listaOutputs.add(novoOutput);
        }
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='orderCode' required=true)
        public String orderCode;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public Boolean result;
    }
}