public class InterfaceAlterarTipoEnvioFatura {
    
    /*
    1 = Correio 
    2 = E-mail
    4 = App/Site
    8 = WhatsApp
    16 = SMS
    */
    
    @invocableMethod(label='Alterar Tipo de Envio Fatura')
    public static List<ResponseAlterarTiposEnvioFatura> AlterarTipoEnvioFatura(List<RequestAlterarTiposEnvioFatura> parametersRequest) {

        List<ResponseAlterarTiposEnvioFatura> toReturn = new List<ResponseAlterarTiposEnvioFatura>();
        ResponseAlterarTiposEnvioFatura responseAlterarTiposEnvioFatura = new ResponseAlterarTiposEnvioFatura();

        AlterarModoEnvioFatura.OutputUpdateModoEnvioFatura output = null;
        for(RequestAlterarTiposEnvioFatura request: parametersRequest){   
            output = AlterarModoEnvioFatura.UpdateTipoEnvioFatura(
                request.idEmpresa, request.sistema, 
                request.canal, request.area , request.cpf, 
                request.numeroConta, request.tipoEnvioFatura, false);
            break;      
        }

        if(output != null && 'OK'.equals(output.StatusAPI)){
            responseAlterarTiposEnvioFatura.statusRetorno = 'OK';
        } else {
            responseAlterarTiposEnvioFatura.statusRetorno = 'ERRO';
        }

        toReturn.add(responseAlterarTiposEnvioFatura);
        return toReturn;
    }

    public class RequestAlterarTiposEnvioFatura {
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Tipo Envio Fatura' required=true)
        public String tipoEnvioFatura;
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
        @InvocableVariable(label='Area' required=true)
        public String area;
        @InvocableVariable(label='Sistema' required=true)
        public String sistema;
    }

    public class ResponseAlterarTiposEnvioFatura {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
    }

}