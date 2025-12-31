public class InterfaceObterResumoFaturaFechada {
    @InvocableMethod(label='Obter Resumo Fatura Fechada')
    public static List<ResponseObterResumo> ObterResumoFaturaFechada(List<RequestObterResumo> parametersRequest){
        List<ResponseObterResumo> toReturn = new List<ResponseObterResumo>();
        ResponseObterResumo responseObterResumo = new ResponseObterResumo();
    
        for(RequestObterResumo request: parametersRequest){

            IntegracoesFaturas.OutputObterResumo resumoFaturaFechada = IntegracoesFaturas.ObterResumoFaturaFechada(request.cpf, request.numeroConta, request.canal, request.idEmpresa);
            if(resumoFaturaFechada == null) {
                responseObterResumo.statusRetorno = 'ERRO';
            } else if(resumoFaturaFechada.StatusAPI == 'OK'){
                responseObterResumo.statusRetorno = 'OK';
                List<String> opcoesMenu = new List<String>();
                String codigoBarras = null;
                if(String.isNotBlank(resumoFaturaFechada.codigoBarras)){
                    codigoBarras = resumoFaturaFechada.codigoBarras.trim();
                }
                responseObterResumo.codigoBarras = codigoBarras;

                String valorFatura = '--';
                if(resumoFaturaFechada.valorFatura != null){
                    valorFatura = resumoFaturaFechada.valorFatura.moeda + ' ' + decimal.valueOf(resumoFaturaFechada.valorFatura.valor).format();
                }
                responseObterResumo.valorFatura = valorFatura;

                String dataVencimento = resumoFaturaFechada.dataVencimento;
                if(String.isNotBlank(dataVencimento)){
                    dataVencimento = dataVencimento.split('T')[0];
                    dataVencimento = Util.formatMMDD(dataVencimento, '-', '/');
                    opcoesMenu.add('Pagar fatura com vencimento em ' + dataVencimento);
                } else {
                    dataVencimento = '--';
                }
                responseObterResumo.dataVencimento = dataVencimento;
                opcoesMenu.add('Antecipar pagamento da fatura');
                responseObterResumo.opcoesMenu = opcoesMenu;
            } else {
                responseObterResumo.statusRetorno = 'ERRO';
            }
            
            toReturn.add(responseObterResumo);
        }
        
        return toReturn;
    }
        
    public class RequestObterResumo {
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='CPF Cliente' required=true)
        public String cpf;
        @InvocableVariable(required=true)
        public String canal;
    }
    
    public class ResponseObterResumo {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Data Vencimento')
        public String dataVencimento;
        @InvocableVariable(label='Código de barras')
        public String codigoBarras;
        @InvocableVariable(label='Valor fatura')
        public String valorFatura;
        @InvocableVariable(label='Lista Opções Menu')
        public List<String> opcoesMenu;

    }
}