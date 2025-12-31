public class InterfaceListarTiposEnvioFatura {

    /*
    1 = Correio 
    2 = E-mail
    4 = App/Site
    8 = WhatsApp
    16 = SMS
    */
    
    @invocableMethod(label='Listar Tipos de Envio Fatura')
    public static List<ResponseListarTiposEnvioFatura> ListarTiposEnvioFatura(List<RequestListarTiposEnvioFatura> parametersRequest) {

        List<ResponseListarTiposEnvioFatura> toReturn = new List<ResponseListarTiposEnvioFatura>();
        ResponseListarTiposEnvioFatura responseListarTiposEnvioFatura = new ResponseListarTiposEnvioFatura();

        AlterarModoEnvioFatura.OutputTiposEnvioFatura output = null;
        for(RequestListarTiposEnvioFatura request: parametersRequest){   
            output = AlterarModoEnvioFatura.GetTiposEnvioFatura(request.canal, request.cpf, request.idEmpresa);   
            break;      
        }

        Tipo_Envio_Fatura__mdt tipoFatura;
        if(output != null && 'OK'.equals(output.StatusAPI)){
            responseListarTiposEnvioFatura.statusRetorno = 'OK';

            List<String> tiposEnvioFatura = new List<String>();
            for(Integer tipo : output.tiposEnvioFatura){
                tipoFatura = TipoEnvioFaturaDAO.getInstance().getDescricaoByCodigoTipoEnvioFatura(String.valueOf(tipo));
                if(tipoFatura != null){
                    tiposEnvioFatura.add(tipoFatura.label);
                }
            }

            responseListarTiposEnvioFatura.tiposEnvioFatura = tiposEnvioFatura;
        } else {
            responseListarTiposEnvioFatura.statusRetorno = 'ERRO';
        }

        toReturn.add(responseListarTiposEnvioFatura);
        return toReturn;
    }

    public class RequestListarTiposEnvioFatura {
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
    }

    public class ResponseListarTiposEnvioFatura {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Lista Tipos de Envio Fatura')
        public List<String> tiposEnvioFatura;
    }

}