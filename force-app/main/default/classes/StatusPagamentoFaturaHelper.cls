public with sharing class StatusPagamentoFaturaHelper {
    @invocableMethod(label='Status de Pagamento da Fatura ')
    public static List<IntegracoesFaturas.OutputFaturaResumida> statusPagamentoFatura(List<InputStatusPagamentoFatura> inputs){
        List<IntegracoesFaturas.OutputFaturaResumida> retorno = new  List<IntegracoesFaturas.OutputFaturaResumida>();
        List<IntegracoesFaturas.OutputFaturasResumidas> responses = new List<IntegracoesFaturas.OutputFaturasResumidas>();
        

        for (InputStatusPagamentoFatura item: inputs) {
            responses.add(IntegracoesFaturas.faturasResumidas(item.numeroConta, item.idEmpresa, item.cpf, item.canal));
        }
        if(responses[0].statusReponse == 'OK'){
            for(IntegracoesFaturas.OutputFaturasResumidas response : responses) {
                if(response.faturas.size() > 1){
                    for (IntegracoesFaturas.OutputFaturaResumida fatura : response.faturas) {
                        if (fatura.ultimaFechada == true) {
                            Date data = Date.valueOf(fatura.dataVencimento);
                            Integer mes = data.month();
                            Integer ano = data.year();
    
                            String mesStr = (mes < 10) ? '0' + String.valueOf(mes) : String.valueOf(mes);
                            String anoStr = String.valueOf(ano).substring(2, 4);
                            
                            fatura.tipoFatura = fatura.tipoFatura == 'PagaParcial'? 'Paga parcialmente' : fatura.tipoFatura;
                            fatura.dataVencFormatada = mesStr + '/' + anoStr;
                            fatura.statusReponse = response.statusReponse;
                            retorno.add(fatura);
                            break;
                        }
                    }
                }else if(response.faturas.size() == 1){
                    Date data = Date.valueOf(response.faturas[0].dataVencimento);
                    Integer mes = data.month();
                    Integer ano = data.year();
    
                    String mesStr = (mes < 10) ? '0' + String.valueOf(mes) : String.valueOf(mes);
                    String anoStr = String.valueOf(ano).substring(2, 4);
                    
                    response.faturas[0].tipoFatura = response.faturas[0].tipoFatura == 'PagaParcial'? 'Paga parcialmente' : response.faturas[0].tipoFatura;
                    response.faturas[0].dataVencFormatada = mesStr + '/' + anoStr;
                    response.faturas[0].statusReponse = response.statusReponse;
                    retorno.add(response.faturas[0]);
                }
            }
        }else{
            IntegracoesFaturas.OutputFaturaResumida retornoErro = new  IntegracoesFaturas.OutputFaturaResumida();
            retornoErro.statusReponse = responses[0].statusReponse;
            retorno.add(retornoErro);
        }
        return retorno;
    }

    
    public class InputStatusPagamentoFatura{    
        @InvocableVariable(required = true)
        public String numeroConta; 
        @InvocableVariable(required = true)
        public String  idEmpresa; 
        @InvocableVariable(required = true)
        public String  cpf;  
        @InvocableVariable(required = true)
        public String canal; 
    }
}