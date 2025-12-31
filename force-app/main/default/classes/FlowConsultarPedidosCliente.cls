public class FlowConsultarPedidosCliente {
    @InvocableMethod(label='Consultar se o pedido existe no email')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            if(item.numPedido != null) {
                item.numPedido = item.numPedido.replace('#', '');

            }
            ConsultarPedidosClienteTO.Retorno resultado = ConsultarPedidosCliente.makeAPIRequest(item.email, item.numPedido);

            novoOutput.status = resultado.statusCode;
            if(resultado.statusCode == '0') {
                novoOutput.numeroPedido = resultado.numeroPedido;
                novoOutput.modalidade = resultado.modalidade;
                novoOutput.status = resultado.status;
                novoOutput.dataAtualizacaoStatus = resultado.dataAtualizacaoStatus;
                novoOutput.type = resultado.type;
            }
            novoOutput.quantidadePedidos = resultado.quantidadePedidos;
            listaOutputs.add(novoOutput);
        }
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='email' required=true)
        public String email;
        @InvocableVariable(label='número do pedido' required=false)
        public String numPedido;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public String numeroPedido;
        @AuraEnabled @InvocableVariable
        public String modalidade;
        @AuraEnabled @InvocableVariable
        public String status;
        @AuraEnabled @InvocableVariable
        public String dataAtualizacaoStatus;
        @AuraEnabled @InvocableVariable
        public String statusCode;
        @AuraEnabled @InvocableVariable
        public Integer quantidadePedidos;
        @AuraEnabled @InvocableVariable
        public String type;
    }
}