public class FlowAbrirIncidenteMiraki {
    @InvocableMethod(label='Abrir incidente Miraki')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            Integer resultado = AbrirIncidenteMiraki.makeAPIRequest(item.orderCode, item.reasonCode);

            novoOutput.statusCode = resultado;
            listaOutputs.add(novoOutput);
        }
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='orderCode' required=true)
        public String orderCode;
        @InvocableVariable(label='reasonCode' required=true)
        public String reasonCode;

    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public Integer statusCode;
    }
}