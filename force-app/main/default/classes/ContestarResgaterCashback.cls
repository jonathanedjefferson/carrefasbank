public class ContestarResgaterCashback {

    @InvocableMethod(label='Contestar Resgate Cashback')
    public static List<Output> contestar(List<Input> inputs) {
        Output retorno = new Output();
        try {
            Input input = inputs[0];

            Cashback.ResultadoContestacaoCashback resultado =
                CashbackController.ContestarResgate(
                    input.cpf,
                    input.canal,
                    input.unidadeNegocio,
                    input.idTransacao
                );

            retorno.erroData = false;

            if (resultado.sucesso) {
                retorno.sucesso  = true;
                retorno.mensagem = 'Contestação realizada com sucesso.';
            } else if (resultado.statusCode == 422
                    && resultado.mensagem != null
                    && resultado.mensagem.containsIgnoreCase('CurrentDateNotAllowed')) {
                retorno.sucesso  = false;
                retorno.erroData = true;
                retorno.mensagem = 'Não é possível contestar na data atual.';
            } else {
                retorno.sucesso  = false;
                retorno.mensagem = 'Não foi possível contestar o resgate: ' + resultado.mensagem;
            }

        } catch (Exception e) {
            retorno.sucesso  = false;
            retorno.mensagem = 'Erro ao contestar cashback: ' + e.getMessage();
        }

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