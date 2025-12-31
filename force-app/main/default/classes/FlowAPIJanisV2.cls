public class FlowAPIJanisV2 {
    @InvocableMethod(label='APIJanis V2: consultar se pedido existe no email')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            if(item.orderCode != null) {
                item.orderCode = item.orderCode.replace('#', '');
            }
            APIJanisV2TO.Retorno resultado = APIJanisV2.makeAPIRequest(item.orderCode, item.email);

            novoOutput.type = resultado.type;
            novoOutput.status = resultado.status;
            novoOutput.estimateDate = resultado.estimateDate;
            novoOutput.modality = resultado.modality;
            novoOutput.orderCode = resultado.orderCode;
            novoOutput.orderDate = resultado.orderDate;
            novoOutput.statusCode = resultado.statusCode;
            novoOutput.orderFound = resultado.orderFound;
            novoOutput.howManyOrders = resultado.howManyOrders;
            listaOutputs.add(novoOutput);
        }
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='orderCode' required=false)
        public String orderCode;
        @InvocableVariable(label='email' required=true)
        public String email;

    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public String type;
        @AuraEnabled @InvocableVariable
		public string status;
        @AuraEnabled @InvocableVariable
		public String estimateDate;
        @AuraEnabled @InvocableVariable
		public String modality;
        @AuraEnabled @InvocableVariable
		public String orderCode;
        @AuraEnabled @InvocableVariable
		public String orderDate;
        @AuraEnabled @InvocableVariable
		public Integer statusCode;
        @AuraEnabled @InvocableVariable
		public Boolean orderFound;
        @AuraEnabled @InvocableVariable
        public Integer howManyOrders;
    }
}