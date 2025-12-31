public class FlowConsultarChaveNF {
    @InvocableMethod(label='Consultar key para NF de um pedido')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            item.orderCode = item.orderCode.replace('#', '');
            ConsultarChaveNFTO.Retorno resultado = ConsultarChaveNF.makeAPIRequest(item.orderCode);

            novoOutput.orderCode = resultado.orderCode;
            novoOutput.statusCode = resultado.statusCode;
            novoOutput.key = resultado.key;
            novoOutput.paymentMethod = resultado.paymentMethod;
            
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
        public String orderCode;
        @AuraEnabled @InvocableVariable
        public Integer statusCode;
        @AuraEnabled @InvocableVariable
        public String key;
        @AuraEnabled @InvocableVariable
        public String paymentMethod;
    }
}