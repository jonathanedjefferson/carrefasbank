public with sharing class FlowCartaoPresente {
    @invocableMethod(label='Dados cartão presente')
    public static List<Output> chamarAPICartaoPresente(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            GiftCardTO resultado = GiftCardSoapAPIIntegration.executeRequest(item.numCartao, item.senhaCartao);
            Output newOutput = new Output();
            newOutput.Status = resultado.status;
            newOutput.Saldo = resultado.value;
            newOutput.DataValidade = resultado.expDate;
            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Cartao' required=true)
        public String numCartao;
        @InvocableVariable(label='Senha' required=true)
        public String senhaCartao;
    }

    public class Output{
        @InvocableVariable
        public String Status;
        @InvocableVariable
        public String Saldo;
        @InvocableVariable
        public String DataValidade;
    }
}