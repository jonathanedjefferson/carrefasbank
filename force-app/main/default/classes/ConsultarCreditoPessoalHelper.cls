public class ConsultarCreditoPessoalHelper {
    @invocableMethod(label='Consulta de Crédito Pessoal')
    public static List<outputConsultaCredito>  consultarCreditoPessoal(List<InputConsultaCredito> inputs){
        List<ConsultarCreditoPessoal.ConsultaAPI> retorno = new List<ConsultarCreditoPessoal.ConsultaAPI>();

        List<outputConsultaCredito> retornoFinal = new List<outputConsultaCredito>();
        outputConsultaCredito objFinal = new outputConsultaCredito();

        for (InputConsultaCredito item: inputs) {
            retorno.add(ConsultarCreditoPessoal.consultarCreditoPessoal(item.numeroConta, item.cpf, item.idEmpresa, item.canal));
        }

        for (ConsultarCreditoPessoal.ConsultaAPI item  : retorno) {
            objFinal.descricao = item.resultado.descricao;
            objFinal.sucesso = item.resultado.sucesso;
            objFinal.saldoDisponivelNumero = item.saldoDisponivel == null ? 0 : item.saldoDisponivel;
            Decimal dec = objFinal.saldoDisponivelNumero;
            String amount;

            if (!string.valueof(dec.format()).right(3).contains(',')){
                amount = string.valueof(dec.format()) + ',00';
            }else if (string.valueof(dec.format()).right(2).contains(',')){
                amount = string.valueof(dec.format()) + '0';
            }else {
                amount = string.valueof(dec.format());
            }

            objFinal.saldoDisponivel = amount;
        }
        retornoFinal.add(objFinal);

        return retornoFinal;
    }


    public class InputConsultaCredito{
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String idEmpresa;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String canal;
    }

    public class outputConsultaCredito {
        @InvocableVariable
        public String saldoDisponivel;
        @InvocableVariable
        public Decimal saldoDisponivelNumero;
        @InvocableVariable
        public String descricao;
        @InvocableVariable
        public Boolean sucesso;
    }
}