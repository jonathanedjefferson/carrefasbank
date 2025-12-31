public class InterfaceReemitirCartao {
    @invocableMethod(label='Reemitir Cartão')
    public static List<ResponseReemitirCartao> reemitirCartao(List<RequestReemitirCartao> parametersRequest) {
        List<ResponseReemitirCartao> toReturn = new List<ResponseReemitirCartao>();
        ResponseReemitirCartao responseReemitirCartao = new ResponseReemitirCartao();

        ReemissaoCartao.ReemitirCartaoOutput outputReemitirCartao = new ReemissaoCartao.ReemitirCartaoOutput();
        for(RequestReemitirCartao request: parametersRequest){   
            String motivoBloqueio = request.motivoBloqueio;
            if(String.isBlank(motivoBloqueio)){
                motivoBloqueio = request.statusCartao;
                motivoBloqueio = motivoBloqueio.replaceAll(';', '');
            }

            outputReemitirCartao = ReemissaoCartao.ReemitirCartao(request.idEmpresa, request.sistema, request.canal, request.area, request.cpf, request.numeroConta, request.numeroCartaoSerno, motivoBloqueio);   
            break;      
        }

        if(outputReemitirCartao.StatusAPI){
            responseReemitirCartao.statusRetorno = 'OK';
        } else {
            responseReemitirCartao.statusRetorno = 'ERRO';
        }

        toReturn.add(responseReemitirCartao);
        return toReturn;
    }

    public static List<ResponseReemitirCartao> ReemitirCartaoComAlteracaoNomeReduzido(List<RequestReemitirCartao> parametersRequest) {
        List<ResponseReemitirCartao> toReturn = new List<ResponseReemitirCartao>();
        ResponseReemitirCartao responseReemitirCartao = new ResponseReemitirCartao();

        ReemissaoCartao.ReemitirCartaoOutput outputReemitirCartao = new ReemissaoCartao.ReemitirCartaoOutput();
        for(RequestReemitirCartao request: parametersRequest){   
            String motivoBloqueio = request.motivoBloqueio;
            if(String.isBlank(motivoBloqueio)){
                motivoBloqueio = request.statusCartao;
                motivoBloqueio = motivoBloqueio.replaceAll(';', '');
            }

            outputReemitirCartao = ReemissaoCartao.ReemitirCartaoComAlteracaoNomeReduzido(request.idEmpresa, request.sistema, request.canal, request.area, request.cpf, request.numeroConta, request.numeroCartaoSerno, motivoBloqueio, request.nomeReduzido);  
            break;      
        }

        if(outputReemitirCartao.StatusAPI){
            responseReemitirCartao.statusRetorno = 'OK';
        } else {
            responseReemitirCartao.statusRetorno = 'ERRO';
        }

        toReturn.add(responseReemitirCartao);
        return toReturn;
    }

    public class RequestReemitirCartao {
        @InvocableVariable(label='Numero da conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Número serno cartão' required=true)
        public String numeroCartaoSerno;
        @InvocableVariable(label='Motivo Bloqueio')
        public String motivoBloqueio;
        @InvocableVariable(label='Status cartão' required=true)
        public String statusCartao;
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Area' required=true)
        public String area;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
        @InvocableVariable(label='Sistema' required=true)
        public String sistema;
        @InvocableVariable(label='Nome Reduzido')
        public String nomeReduzido;
    }

    public class ResponseReemitirCartao {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
    }
    
}