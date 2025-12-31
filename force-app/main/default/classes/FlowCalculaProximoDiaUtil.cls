public class FlowCalculaProximoDiaUtil {
    @InvocableMethod(label='Consultar próximo dia útil')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            Output novoOutput = new Output();
            Date resultado = calculaProximoDiaUtil.proximoDiaUtil(item.qntDiasAdicionar, item.dataBase);
            novoOutput.dataResultado = resultado;
            
            listaOutputs.add(novoOutput);
        }
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='qntDiasAdicionar' required=true)
        public Integer qntDiasAdicionar;
        @InvocableVariable(label='dataBase' required=true) 
        public Date dataBase;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public Date dataResultado;
    }
}