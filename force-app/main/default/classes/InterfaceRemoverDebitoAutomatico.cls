public class InterfaceRemoverDebitoAutomatico {
    @InvocableMethod(label='Remover Débito Automático')
    public static List<ResponseRemoverDebito> RemoverDebitoAutomatico(List<RequestRemoverDebito> parametersRequest){
        List<ResponseRemoverDebito> toReturn = new List<ResponseRemoverDebito>();
        ResponseRemoverDebito responseRemoverDebito = new ResponseRemoverDebito();
    
        for(RequestRemoverDebito request: parametersRequest){
        
            String codigoBanco = '';
            if(!String.isBlank(request.numeroBanco)){
                String[] banco = request.numeroBanco.split(' ');
                if(banco.size() > 1){
                    codigoBanco = banco[1].removeStart('0');
                }
            }
            boolean removerDebitoAutomatico = DebitoAutomatico.RemoverDebitoAutomatico(request.cpf, request.numeroConta, request.nomeCorrentista, codigoBanco, request.numeroAgencia, request.numeroContaBancaria, request.tipoPagamento, request.idEmpresa, request.canal);
            
            if(removerDebitoAutomatico){
                responseRemoverDebito.statusChamada =  'OK';
            } else {
                responseRemoverDebito.statusChamada =  'ERRO';
            }
        }
        
            
        toReturn.add(responseRemoverDebito);
        
        return toReturn;
    }
        
    public class RequestRemoverDebito {
        @InvocableVariable(label = 'CPF Cliente' required = true)
        public String cpf;
        @InvocableVariable(label = 'Número Conta' required = true)
        public String numeroConta;
        @InvocableVariable(label = 'Nome Correntista' required = true)
        public String nomeCorrentista;
        @InvocableVariable(label = 'Id Empresa' required = true)
        public String idEmpresa;
        @InvocableVariable(label = 'Número Banco')
        public String numeroBanco;
        @InvocableVariable(label = 'Número Agência')
        public String numeroAgencia;
        @InvocableVariable(label = 'Número Conta Bancária')
        public String numeroContaBancaria;
        @InvocableVariable(label = 'Opt-in Tipo Pagamento')
        public String tipoPagamento;
        @InvocableVariable(required = true)
        public String canal;
    }
    
    public class ResponseRemoverDebito {
        @InvocableVariable(label='Status chamada')
        public String statusChamada;
    }
}