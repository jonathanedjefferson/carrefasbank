public class DadosPagamentoHelper {
    @invocableMethod(label='Dados de Pagamento de Fatura Fechada')
    public static List<IntegracoesFaturas.OutputDadosPagamentoFaturaFechada> DadosPagamentoFaturaFechada(List<InputDadosPagamentoFaturaFechada> inputs){
        List<IntegracoesFaturas.OutputDadosPagamentoFaturaFechada> retorno = new List<IntegracoesFaturas.OutputDadosPagamentoFaturaFechada>();
        
        for (InputDadosPagamentoFaturaFechada item: inputs) {
            retorno.add(IntegracoesFaturas.DadosPagamentoFaturaFechada(item.numeroConta, item.idEmpresa, item.cpf, item.mesAnoVencimento, item.canal));
        }

        return retorno;
    }

    
    public class InputDadosPagamentoFaturaFechada{    
        @InvocableVariable(required = true)
        public String numeroConta; 
        @InvocableVariable(required = true)
        public String  idEmpresa; 
        @InvocableVariable(required = true)
        public String  cpf; 
        @InvocableVariable(required = true)
        public String  mesAnoVencimento;   
        @InvocableVariable(required = true)
        public String canal; 
    }
}