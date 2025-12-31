public class InterfaceConsultarDebitoAutomatico {
    @InvocableMethod(label='Consultar Débito Automático')
    public static List<ResponseConsultarDebito> ConsultarDebitoAutomatico(List<RequestConsultarDebito> parametersRequest){
        List<ResponseConsultarDebito> toReturn = new List<ResponseConsultarDebito>();
        ResponseConsultarDebito responseConsultarDebito = new ResponseConsultarDebito();
    
        DebitoAutomatico.OutputDebitoAutomatico detalhesDebitoAutomatico = null;
        for(RequestConsultarDebito request: parametersRequest){
            detalhesDebitoAutomatico = DebitoAutomatico.ConsultarDebitoAutomatico(request.cpf, request.numeroConta, request.nomeCorrentista, request.idEmpresa, request.canal);
        }
        
        if(detalhesDebitoAutomatico == null){
            responseConsultarDebito.tipoDebito = '-1';
        } else if(detalhesDebitoAutomatico.tipoDebito == '0'){
            responseConsultarDebito.tipoDebito = detalhesDebitoAutomatico.tipoDebito;
        } else {
            if(!String.isBlank(detalhesDebitoAutomatico.nrBancoAgencia)){
                String[] nrBancoAgencia = detalhesDebitoAutomatico.nrBancoAgencia.split('-');
                responseConsultarDebito.numeroBanco = nrBancoAgencia[0];
                responseConsultarDebito.numeroAgencia = nrBancoAgencia[1];
                
                String codigoBanco = responseConsultarDebito.numeroBanco;
                codigoBanco = codigoBanco.leftPad(3, '0');
                Banco__mdt dadosBanco = BancoDAO.getInstance().getBancoByCodigoBanco(codigoBanco );
                if(dadosBanco != null){
                    responseConsultarDebito.numeroBanco = dadosBanco.Label + ' ' + dadosBanco.Codigo_Banco__c;
                }   
            }
            
            responseConsultarDebito.numeroContaBancaria = detalhesDebitoAutomatico.numeroContaBancaria;
            responseConsultarDebito.tipoDebito = detalhesDebitoAutomatico.tipoDebito;
            String tipoPagamento = detalhesDebitoAutomatico.tipoPagamento;
            responseConsultarDebito.tipoPagamento = tipoPagamento;
            
            switch on tipoPagamento {
                when 'd' {
                    // sem cheque especial e sem pagamento após o vencimento
                    responseConsultarDebito.chequeEspecial = 'Não';
                    responseConsultarDebito.tentativaAposVencimento = 'Não';
                }
                when 'o' {
                    // com cheque especial e sem pagamento após o vencimento
                    responseConsultarDebito.chequeEspecial = 'Sim';
                    responseConsultarDebito.tentativaAposVencimento = 'Não';
                }
                when 'p' {
                    // sem cheque especial e com pagamento após o vencimento
                    responseConsultarDebito.chequeEspecial = 'Não';
                    responseConsultarDebito.tentativaAposVencimento = 'Sim';
                }
                when 'q' {
                    // com cheque especial e com pagamento após o vencimento
                    responseConsultarDebito.chequeEspecial = 'Sim';
                    responseConsultarDebito.tentativaAposVencimento = 'Sim';
                }
            }
        }
            
        toReturn.add(responseConsultarDebito);
        
        return toReturn;
    }
        
    public class RequestConsultarDebito {
        @InvocableVariable(label='CPF Cliente' required=true)
        public String cpf;
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Nome Correntista' required=true)
        public String nomeCorrentista;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(required=true)
        public String canal;
    }
    
    public class ResponseConsultarDebito {
        @InvocableVariable(label='Número Banco')
        public String numeroBanco;
        @InvocableVariable(label='Número Agência')
        public String numeroAgencia;
        @InvocableVariable(label='Número Conta Bancária')
        public String numeroContaBancaria;
        @InvocableVariable(label='Tipo Débito')
        public String tipoDebito;
        @InvocableVariable(label='Tipo Pagamento')
        public String tipoPagamento;
        @InvocableVariable(label='Opt-in Cheque Especial')
        public String chequeEspecial;
        @InvocableVariable(label='Opt-in Tentativa Apos Vencimento')
        public String tentativaAposVencimento;
    }
}