public class InterfaceBloqueioConta {

    @InvocableMethod(label='Bloquear Conta')
    public static List<ResponseBloquear> BloquearConta(List<RequestBloquear> parametersRequest){
    
        List<ResponseBloquear> toReturn = new List<ResponseBloquear>();
        ResponseBloquear responseBloquear= new ResponseBloquear();
        
        for(RequestBloquear requestBloquear: parametersRequest){
        
            Boolean bloqueadoSucesso = CancelamentoConta.CancelarConta(requestBloquear.numeroConta, requestBloquear.novoStatus, 
            requestBloquear.idEmpresa, requestBloquear.cpf, requestBloquear.sistema, requestBloquear.canal, requestBloquear.area);
                
            if(bloqueadoSucesso){
                responseBloquear.bloqueadoSucesso = 'OK';
            } else {
                responseBloquear.bloqueadoSucesso = 'ERRO';
            }
            
            toReturn.add(responseBloquear);
        }
        
        return toReturn;
    }
    
    public class RequestBloquear {
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Sistema' required=true)
        public String sistema;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
        @InvocableVariable(label='Área' required=true)
        public String area;
        @InvocableVariable(label='CPF Cliente' required=true)
        public String cpf;
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Novo Status' required=true)
        public String novoStatus;
    }
    
    public class ResponseBloquear {
        @InvocableVariable(label='Status Chamada')
        public String bloqueadoSucesso ;
    }
}