public class FlowAverageSpeedToAnswer {
    @InvocableMethod(label='Consultar a média de tempo para ser atendido')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            Double resultado = AverageSpeedToAnswer.getAverageSpeedToAnswer(item.queueId, item.startDate, item.endDate);

            novoOutput.averageSpeed = resultado;
            listaOutputs.add(novoOutput);
        }
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='queueId' required=true)
        public String queueId;
        @InvocableVariable(label='startDate' required=true)
        public Datetime startDate;
        @InvocableVariable(label='endDate' required=true)
        public Datetime endDate;

    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public Double averageSpeed;
    }
}