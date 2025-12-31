public with sharing class FlowJanisIdentificarReagendamento {
    @invocableMethod(label='Janis identificar reagendamento')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            item.numPedido = item.numPedido.replace('#', '');
            JanisIdentificarReagendamentoTO.Retorno resultado = JanisIdentificarReagendamento.makeAPIRequest(item.numPedido);
            Output newOutput = new Output();
            newOutput.statusCode = resultado.statusCode;
            if(resultado.statusCode == 200) {
                newOutput.status = resultado.status;
                newOutput.commerceSequentialId = resultado.commerceSequentialId;
                newOutput.receiverName = resultado.receiverName;
                newOutput.receiverDocument = resultado.receiverDocument;
                newOutput.paymentGroup = resultado.paymentGroup;
                newOutput.carrierId = resultado.carrierId;
                newOutput.deliveryId = resultado.deliveryId;
                newOutput.initialDate = resultado.initialDate;
                newOutput.finalDate = resultado.finalDate;
                newOutput.shippingUrl = resultado.shippingUrl;
                newOutput.items = resultado.items;
                newOutput.commerceSalesChannel = resultado.commerceSalesChannel;
            }
            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='numPedido' required=true)
        public String numPedido;
    }

    public class Output {
        @InvocableVariable
        public String commerceSequentialId;
        @InvocableVariable
        public String receiverName;
        @InvocableVariable
        public String receiverDocument;
        @InvocableVariable
        public String paymentGroup;
        @InvocableVariable
        public String carrierId;
        @InvocableVariable
        public String deliveryId;
        @InvocableVariable
        public String initialDate;
        @InvocableVariable
        public String finalDate;
        @InvocableVariable
        public Integer statusCode;
        @InvocableVariable
        public String shippingUrl;
        @InvocableVariable
        public String items;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String commerceSalesChannel;
    }
}