public class InterfaceCadastrarDebitoAutomatico {
    @InvocableMethod(label='Cadastrar Débito Automático')
    public static List<ResponseCadastrarDebito> CadastrarDebitoAutomatico(List<RequestCadastrarDebito> parametersRequest){
        List<ResponseCadastrarDebito> toReturn = new List<ResponseCadastrarDebito>();
        ResponseCadastrarDebito responseCadastrarDebito = new ResponseCadastrarDebito();
    
        for(RequestCadastrarDebito request: parametersRequest){
        
            String tipoPagamento;
            if('Sim'.equals(request.chequeEspecial)){
                if('Sim'.equals(request.tentativaAposVencimento)){
                    tipoPagamento = 'q';
                } else {
                    tipoPagamento = 'o';
                }
            } else {
                if('Sim'.equals(request.tentativaAposVencimento)){
                    tipoPagamento = 'p';
                } else {
                    tipoPagamento = 'd';
                }
            }
        
            String codigoBanco = '';
            if(!String.isBlank(request.numeroBanco)){
                String[] banco = request.numeroBanco.split(' ');
                if(banco.size() > 1){
                    codigoBanco = banco[1].removeStart('0');
                }
            }
            
            String numeroAgencia = '';
            if(!String.isBlank(request.numeroAgencia)){
                numeroAgencia = request.numeroAgencia.replaceAll('[^0-9]', '');
            }
            
            String numeroContaBancaria = '';
            if(!String.isBlank(request.numeroContaBancaria)){
                numeroContaBancaria = request.numeroContaBancaria.replaceAll('[^0-9]', '');
            }
            
            boolean cadastrarDebitoAutomatico = false;
            if(!String.isBlank(codigoBanco) && !String.isBlank(numeroAgencia) && !String.isBlank(numeroContaBancaria)){
                cadastrarDebitoAutomatico = DebitoAutomatico.CadastrarDebitoAutomatico(request.cpf, request.numeroConta, request.nomeCorrentista, codigoBanco, numeroAgencia, numeroContaBancaria, tipoPagamento, request.idEmpresa, request.canal);
            }
            
            if(cadastrarDebitoAutomatico){
                responseCadastrarDebito.statusChamada =  'OK';
            } else {
                responseCadastrarDebito.statusChamada =  'ERRO';
            }
        }
        
            
        toReturn.add(responseCadastrarDebito);
        
        return toReturn;
    }
        
    public class RequestCadastrarDebito {
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
        @InvocableVariable(label = 'Opt-in Cheque Especial')
        public String chequeEspecial;
        @InvocableVariable(label = 'Opt-in Tentativa Apos Vencimento')
        public String tentativaAposVencimento;
        @InvocableVariable(required = true)
        public String canal;
    }
    
    public class ResponseCadastrarDebito {
        @InvocableVariable(label='Status chamada')
        public String statusChamada;
    }
}