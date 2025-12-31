public with sharing class FlowReagendarEntrega {
    @invocableMethod(label='Reagendar entrega')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            Integer resultado = ReagendarEntrega.makeAPIRequest(item.shippingUrl, item.shippingId, item.carrierId, item.initialDate, item.finalDate, item.name, item.document);
            Output newOutput = new Output();
            newOutput.statusCode = resultado;
            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='shippingUrl' required=true)
        public String shippingId;
        @InvocableVariable(label='shippingId' required=true)
        public String shippingUrl;
        @InvocableVariable(label='carrierId' required=true)
        public String carrierId;
        @InvocableVariable(label='initialDate' required=true)
        public String initialDate;
        @InvocableVariable(label='finalDate' required=true)
        public String finalDate;
        @InvocableVariable(label='name' required=true)
        public String name;
        @InvocableVariable(label='document')
        public String document;
    }
    public class Output {
        @InvocableVariable 
        public Integer statusCode;
    }
}