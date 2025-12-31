public class FlowValidarDocumento {
    @invocableMethod(label='Varejo - Validar Documento')
    public static List<Output> validarDocumento(List<Input> lstInput) {
        List<Output> lstRetorno = new List<Output>();
        
        for(Input item: lstInput) {
            Output out = new Output();
            out.cpfValido = UtilsVarejo.validarCpf(item.documento);
            out.cnpjValido = UtilsVarejo.validarCnpj(item.documento);

            lstRetorno.add(out);
            break;
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Documento' required=true)
        public String documento;
    }

    public class Output {
        public Output(){
            this.cpfValido = false;
            this.cnpjValido = false;
        }

        @InvocableVariable(label='CPF Válido')
        public Boolean cpfValido;
        @InvocableVariable(label='CNPJ Válido')
        public Boolean cnpjValido;
    }
}