public class InterfaceListarCartoesReemissao {

    @invocableMethod(label='Listar Cartões Elegíveis Reemissão de Cartão')
    public static List<ResponseListarCartoesReemissao> listarCartoesReemissao(List<RequestListarCartoesReemissao> parametersRequest) {

        List<ResponseListarCartoesReemissao> toReturn = new List<ResponseListarCartoesReemissao>();
        ResponseListarCartoesReemissao responseListarCartoes = new ResponseListarCartoesReemissao();

        ReemissaoCartao.OutputListCartoesParaReemissao outputListarCartoes = null;
        for(RequestListarCartoesReemissao request: parametersRequest){   
            outputListarCartoes = ReemissaoCartao.ListCartoesParaReemissao(
                request.canal, request.area, request.cpf, request.numeroConta, request.idEmpresa);   
            break;      
        }

        if(outputListarCartoes == null || outputListarCartoes.StatusAPI == 'ERROR'){
            responseListarCartoes.statusRetorno = 'ERRO';
        } else {
            responseListarCartoes.statusRetorno = 'OK';
            
            if(outputListarCartoes.cartoesElegiveis != null && outputListarCartoes.cartoesElegiveis.size() > 0){

                String listaSernoIds = '';
                String listaStatusCartoes = '';
                String listaOpcoesCartoesBkp = '';
                String opcaoCartao;
                List<String> listaOpcoesCartoes = new List<String>();
                for(ReemissaoCartao.CartoesElegiveis cartao : outputListarCartoes.cartoesElegiveis){
                    if(cartao.nomeCartao != null && cartao.numeroCartaoOfuscado != null){
                        opcaoCartao = cartao.nomeCartao + ' (' + cartao.numeroCartaoOfuscado + ')';
                        listaOpcoesCartoes.add(opcaoCartao);
                        listaOpcoesCartoesBkp += opcaoCartao + ';';
                        listaSernoIds += cartao.numeroCartaoSerno + ';';
                        listaStatusCartoes += cartao.status + ';';
                    }
                }

                responseListarCartoes.listaOpcoesCartoes = listaOpcoesCartoes;
                responseListarCartoes.listaSernoIds = listaSernoIds;
                responseListarCartoes.listaStatusCartoes = listaStatusCartoes;
                responseListarCartoes.listaOpcoesCartoesBkp = listaOpcoesCartoesBkp;
            }
        }

        toReturn.add(responseListarCartoes);
        return toReturn;
    }

    public class RequestListarCartoesReemissao {
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

    public class ResponseListarCartoesReemissao {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;

        @InvocableVariable(label='Cartões Elegíveis')
        public List<String> listaOpcoesCartoes;

        @InvocableVariable(label='Lista Serno Ids Cartoes')
        public String listaSernoIds;

        @InvocableVariable(label='Lista Status Cartões')
        public String listaStatusCartoes;

        @InvocableVariable(label='Lista Cartões Elegíveis')
        public String listaOpcoesCartoesBkp;

    }
}