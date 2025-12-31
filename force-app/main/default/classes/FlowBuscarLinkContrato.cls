public class FlowBuscarLinkContrato {

    @InvocableMethod(label='Buscar link de contrato por pedido')
    public static List<Output> buscar(List<Input> lstInputs) {
        Input input = lstInputs[0];
        BuscarLinkContrato.WarrantyResponse response = BuscarLinkContrato.buscarGarantiaPedido(input.orderId, input.brand);

        Output out = new Output();
        if (response != null) {
            out.linkTicket = response.linkTicket;
        }

        return new List<Output>{ out };
    }

    public class Input {
        @InvocableVariable(required=true)
        public String orderId;

        @InvocableVariable(required=true)
        public String brand;
    }

    public class Output {
        @InvocableVariable
        public String linkTicket;
    }
}