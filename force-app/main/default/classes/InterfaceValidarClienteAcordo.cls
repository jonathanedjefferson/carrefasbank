public class InterfaceValidarClienteAcordo {
    @InvocableMethod(label='Validar Cliente Acordo')
    public static List<ResponseValidarCliente> ValidarClienteAcordo(List<RequestValidarCliente> parametersRequest){
        List<ResponseValidarCliente> toReturn = new List<ResponseValidarCliente>();
        ResponseValidarCliente retorno = new ResponseValidarCliente();
        
        for(RequestValidarCliente request: parametersRequest){
            AcordoDivida.OutputValidaClienteAcordo validarCliente = new AcordoDivida.OutputValidaClienteAcordo();
            String dataNascimento = Util.formatYYYYMMDD(request.dataNascimento, '/', '-');
            
            if(String.isNotBlank(dataNascimento)){
                validarCliente = AcordoDivida.ValidarClienteAcordo(request.identificador, dataNascimento, request.idEmpresa, request.cpf, request.canal);
                retorno.Status = validarCliente.Status;
                retorno.Situacao = validarCliente.Situacao;
                toReturn.add(retorno);
                break;
            }    
        }
        
        return toReturn;
    }
    
    public class RequestValidarCliente {
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='CPF Cliente' required=true)
        public String cpf;
        @InvocableVariable(label='Data Nascimento' required=true)
        public String dataNascimento;
        @InvocableVariable(label='Identificador Acordo' required=true)
        public String identificador;
        @InvocableVariable(required=true)
        public String canal;
    }
    
    public class ResponseValidarCliente {
        @InvocableVariable
        public String Status;
        @InvocableVariable
        public Boolean Situacao;
    }
}