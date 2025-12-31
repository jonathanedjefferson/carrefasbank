public class InterfaceDesbloqueioCartao {
    @invocableMethod(label='Desbloqueio de cartao')
    public static List<Output> desbloquearCartao(List<Input> inputList){
        Boolean retornoAPI = BCSF_DesbloqueioCartaoController.desbloquearCartao(inputList[0].idEmpresa, inputList[0].sistema, inputList[0].canal, inputList[0].area, inputList[0].cpf, inputList[0].numeroConta, inputList[0].numeroCartaoSerno);

        List<Output> outputLst = new List<Output>();
        Output retorno = new Output();
        retorno.retornoAPI = retornoAPI;
        outputLst.add(retorno);

        return outputLst;
    }

    public class Input{
        @InvocableVariable
        public String idEmpresa;
        @InvocableVariable
        public String sistema;
        @InvocableVariable
        public String canal;
        @InvocableVariable
        public String area;
        @InvocableVariable
        public String cpf;
        @InvocableVariable
        public String numeroConta;
        @InvocableVariable
        public String numeroCartaoSerno;
    }

    public class Output{
        @InvocableVariable
        public boolean retornoAPI;
    }
}