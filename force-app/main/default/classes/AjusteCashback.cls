public class AjusteCashback {

    @InvocableMethod(label='Ajustar Resgate Cashback')
    public static List<Output> ajustar(List<Input> inputs) {
        Output retorno = new Output();
        try {
            Input input = inputs[0];

            Cashback.ResultadoAjusteCashback resultado = CashbackController.ajusteCashback(
                input.cpf,
                input.canal,
                input.unidadeNegocio,
                input.idTransacao,
                input.dueAmount,
                input.dueAmountBank
            );
            retorno.erroData = false;
            if (resultado.sucesso) {
                retorno.sucesso = true;
                retorno.mensagem = 'Ajuste realizado com sucesso.';
            } else if (resultado.statusCode == 422 && resultado.mensagem != null && resultado.mensagem.containsIgnoreCase('Data atual não permite')) {
                retorno.sucesso = false;
                retorno.erroData = true;
                retorno.mensagem = 'Não é possível realizar o ajuste na data atual.';
            } else {
                retorno.sucesso = false;
                retorno.mensagem = 'Erro ao ajustar cashback: ' + resultado.mensagem;
            }

        } catch (Exception e) {
            retorno.sucesso = false;
            retorno.mensagem = 'Erro inesperado ao ajustar cashback: ' + e.getMessage();
        }
        System.debug('retorno');
        System.debug(retorno);
        return new List<Output>{ retorno };
    }

    public class Input {
        @InvocableVariable(required=true)
        public String cpf;
        @InvocableVariable(required=true)
        public String canal;
        @InvocableVariable
        public String unidadeNegocio;
        @InvocableVariable(required=true)
        public String idTransacao;
        @InvocableVariable
        public String dueAmount;
        @InvocableVariable
        public String dueAmountBank;
    }

    public class Output {
        @InvocableVariable
        public Boolean sucesso;
        @InvocableVariable
        public String mensagem;
        @InvocableVariable
        public Boolean erroData;
    }
}