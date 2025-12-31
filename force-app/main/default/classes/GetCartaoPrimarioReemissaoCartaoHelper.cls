public class GetCartaoPrimarioReemissaoCartaoHelper {
    @invocableMethod(label='Get Cartao Primario Reemissao Cartao')
    public static List<ResponseCartaoReemissao> GetCartaoReemissao(List<RequestCartaoReemissao> parametersRequest) {
        List<ResponseCartaoReemissao> toReturn = new List<ResponseCartaoReemissao>();
        ResponseCartaoReemissao responseCartao = new ResponseCartaoReemissao();

        ReemissaoCartao.OutputListCartoesParaReemissao outputListarCartoes = null;
        for(RequestCartaoReemissao request: parametersRequest){   
            outputListarCartoes = ReemissaoCartao.ListCartoesParaReemissao(request.canal, request.area, request.cpf, request.numeroConta, request.idEmpresa);   
            break;      
        }

        if(outputListarCartoes == null || outputListarCartoes.StatusAPI == 'ERROR'){
            responseCartao.statusRetorno = 'ERROR';
        } else {            
            responseCartao.statusRetorno = 'SEM CARTAO PRIMARIO';

            if(outputListarCartoes.cartoesElegiveis != null && outputListarCartoes.cartoesElegiveis.size() > 0){               
                for(ReemissaoCartao.CartoesElegiveis item : outputListarCartoes.cartoesElegiveis){
                    if(item.nomeCartao != null && item.numeroCartaoOfuscado != null && item.ehPrimario){
                        responseCartao.SernoId = item.numeroCartaoSerno;
                        responseCartao.NomeCartao = item.nomeCartao;
                        responseCartao.NomePortador = item.nomePortador;
                        responseCartao.Ultimos4Digitos = item.numeroCartaoOfuscado.split('\\.')[3];
                        responseCartao.statusRetorno = 'OK';
                        break;
                    }
                }
            }
        }

        toReturn.add(responseCartao);
        return toReturn;
    }

    public class RequestCartaoReemissao {
        @InvocableVariable(label='Numero da conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Area' required=true)
        public String area;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
    }

    public class ResponseCartaoReemissao {
        @InvocableVariable(label='Status Retorno')
        public String statusRetorno;
        @InvocableVariable(label='Serno Id')
        public String SernoId;
        @InvocableVariable(label='4 Ultimos Digitos do Cartão')
        public String Ultimos4Digitos;
        @InvocableVariable(label='Nome no Cartão')
        public String NomeCartao;
        @InvocableVariable(label='Nome do Portador')
        public String NomePortador;
    }
}