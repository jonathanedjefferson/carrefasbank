public class InterfaceDesbloquearSenhaCartao {

    @invocableMethod(label='Desbloquear Senha Cartão')
    public static List<ResponseDesbloquearSenhaCartao> DesbloquearSenhaCartao(List<RequestDesbloquearSenhaCartao> parametersRequest) {

        List<ResponseDesbloquearSenhaCartao> toReturn = new List<ResponseDesbloquearSenhaCartao>();
        ResponseDesbloquearSenhaCartao responseDesbloquearSenhaCartao = new ResponseDesbloquearSenhaCartao();

        String idSernoCartao = null;
        DesbloqueioSenhaCartao.OutputDesbloquearSenhaCartao output = null;
        for(RequestDesbloquearSenhaCartao request: parametersRequest){   
            List<String> listaCartoesSerno = new List<String>();
            idSernoCartao = request.idSernoCartao;
            listaCartoesSerno.add(idSernoCartao);
            output = DesbloqueioSenhaCartao.DesbloquearSenhaCartao(
                request.cpf, request.numeroConta, 
                request.idEmpresa, request.canal, 
                request.area , request.sistema, listaCartoesSerno);
            break;      
        }

        if(output != null && 'OK'.equals(output.statusAPI)){
            String statusRetorno =  'ERRO';
            for(DesbloqueioSenhaCartao.SenhaCartaoDesbloqueada statusDesbloqueio : output.senhaCartaoDesbloqueada){
                if(statusDesbloqueio.idSerno == idSernoCartao && statusDesbloqueio.sucesso){
                    statusRetorno = 'OK';
                }
            }
            responseDesbloquearSenhaCartao.statusRetorno = statusRetorno;
        } else {
            responseDesbloquearSenhaCartao.statusRetorno = 'ERRO';
        }

        toReturn.add(responseDesbloquearSenhaCartao);
        return toReturn;
    }

    public class RequestDesbloquearSenhaCartao {
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Número Serno Cartão' required=true)
        public String idSernoCartao;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
        @InvocableVariable(label='Area' required=true)
        public String area;
        @InvocableVariable(label='Sistema' required=true)
        public String sistema;
    }

    public class ResponseDesbloquearSenhaCartao {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
    }
    
}