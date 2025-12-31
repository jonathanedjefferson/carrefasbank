public class FlowConsultarCodigoPostagem {
    @InvocableMethod(label='Consultar o código de postagem')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            ConsultarCodigoPostagemTO.Retorno resultado = ConsultarCodigoPostagem.makeAPIRequest(item.orderCode);

            if(resultado.codigoPostagem != null) {
                novoOutput.codigoPostagem = resultado.codigoPostagem;
            }
            novoOutput.orderId = resultado.orderId;
            novoOutput.shippingPriorityName = resultado.shippingPriorityName;
            novoOutput.lastUpdatedDate = resultado.lastUpdatedDate;
            novoOutput.orderLineState = resultado.orderLineState;
            novoOutput.orderLineStateReasonCode = resultado.orderLineStateReasonCode;
            novoOutput.orderLineStateReasonLabel = resultado.orderLineStateReasonLabel;
            if(resultado.shippingPriorityName != null) {
                novoOutput.shippedDate = resultado.shippedDate;
            }
            novoOutput.shippingDeadline = resultado.shippingDeadline;
            novoOutput.statusCode = resultado.statusCode;
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
        public Integer statusCode;
        @AuraEnabled @InvocableVariable
        public String codigoPostagem;
        @AuraEnabled @InvocableVariable
        public String shippingPriorityName;
        @AuraEnabled @InvocableVariable
        public String orderId;
        @AuraEnabled @InvocableVariable
        public String lastUpdatedDate;
        @AuraEnabled @InvocableVariable
		public String orderLineState;
        @AuraEnabled @InvocableVariable
		public String orderLineStateReasonCode;
        @AuraEnabled @InvocableVariable
		public String orderLineStateReasonLabel;
        @AuraEnabled @InvocableVariable
		public String shippedDate;
        @AuraEnabled @InvocableVariable
		public String shippingDeadline;
    }
}