public class FlowConsigmentNames {
    @InvocableMethod(label='Consultar consigmentsCodes e names')
    public static List<List<FlowConsigmentNamesTO>> chamarAPI(List<Input> lstEntrada) {
        String email = lstEntrada[0].email;
        String numPedido = lstEntrada[0].numPedido;
        numPedido = numPedido.replace('#', '');

        List<FlowConsigmentNamesTO> listaOutput = new List<FlowConsigmentNamesTO>();
        List<List<FlowConsigmentNamesTO>> listOutputsAdd = new List<List<FlowConsigmentNamesTO>>();
        ConsultarPedidosClienteTO.Retorno resultado = ConsultarPedidosCliente.makeAPIRequest(email, numPedido);

        if(resultado.statusCode == '0') {
            for(ConsultarPedidosClienteTO.mapConsigmentCodeName consigmentsResult: resultado.consigmentCodesNames) {
                FlowConsigmentNamesTO newOutput = new FlowConsigmentNamesTO();
                newOutput.name = consigmentsResult.name;
                newOutput.consigmentCode = consigmentsResult.consigmentCode;
                newOutput.estimateDate = consigmentsResult.estimateDate;
                newOutput.status = consigmentsResult.status;
                listaOutput.add(newOutput);
            }
        }

        listOutputsAdd.add(listaOutput);
        return listOutputsAdd;
    }

    public class Input {
        @InvocableVariable(label='email' required=true)
        public String email;
        @InvocableVariable(label='número do pedido' required=false)
        public String numPedido;
    }
}