public class FlowConsultarJanelaEntrega {
    @InvocableMethod(label='Consultar janela de entrega')
    public static List<List<FlowConsultarJanelaEntregaTO>> chamarAPI(List<Input> lstEntrada) {
        List<FlowConsultarJanelaEntregaTO> listaOutput = new List<FlowConsultarJanelaEntregaTO>();
        List<List<FlowConsultarJanelaEntregaTO>> listOutputsAdd = new List<List<FlowConsultarJanelaEntregaTO>>();

        for(Input objInput: lstEntrada) {
            DateTime inputDateTime = DateTime.newInstance(objInput.initialDate.year(), objInput.initialDate.month(), objInput.initialDate.day(), 0, 0, 0);
            List<ConsultarJanelaEntregaTO> resultado = ConsultarJanelaEntrega.makeAPIRequest(objInput.carrierId, inputDateTime, objInput.daysToAdd);
            for(ConsultarJanelaEntregaTO janelaEntrega: resultado) {
                FlowConsultarJanelaEntregaTO newOutput = new FlowConsultarJanelaEntregaTO();
                newOutput.statusCode = janelaEntrega.statusCode;
                newOutput.dateStart = String.valueOf(convertDate(janelaEntrega.dateStart));
                newOutput.dateEnd = String.valueOf(convertDate(janelaEntrega.dateEnd));
                listaOutput.add(newOutput);
            }
            listOutputsAdd.add(listaOutput);
        }

        return listOutputsAdd;
    }

    public static Datetime convertDate(String startDate) {
        String datePortion = startDate.substring(0, 10);
        String timePortion = startDate.substring(11, 19);
        String resultDateTime = datePortion + ' ' + timePortion;
        return DateTime.valueOf(resultDateTime);
    }

    public class Input {
        @InvocableVariable(label='carrierId' required=true)
        public String carrierId;
        @InvocableVariable(label='initialDate' required=true)
        public Date initialDate;
        @InvocableVariable(label='daysToAdd' required=true)
        public Integer daysToAdd;
    }
}