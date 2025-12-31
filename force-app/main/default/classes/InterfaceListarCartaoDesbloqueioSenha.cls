public class InterfaceListarCartaoDesbloqueioSenha {

    @invocableMethod(label='Listar Cartão Desbloqueio Senha')
    public static List<ResponseListarCartaoDesbloqueioSenha> ListarCartaoDesbloqueioSenha(List<RequestListarCartaoDesbloqueioSenha> parametersRequest) {

        List<ResponseListarCartaoDesbloqueioSenha> toReturn = new List<ResponseListarCartaoDesbloqueioSenha>();
        ResponseListarCartaoDesbloqueioSenha responseListarCartaoDesbloqueioSenha = new ResponseListarCartaoDesbloqueioSenha();

        DesbloqueioSenhaCartao.OutputListarCartaoDesbloqueioSenha output = null;
        for(RequestListarCartaoDesbloqueioSenha request: parametersRequest){   
            output = DesbloqueioSenhaCartao.ListarCartaoDesbloqueioSenha(
                request.cpf, request.numeroConta, 
                request.idEmpresa, request.canal, 
                request.area , request.sistema);
            break;      
        }

        if(output != null && 'OK'.equals(output.statusAPI)){
            responseListarCartaoDesbloqueioSenha.statusRetorno = 'OK';

            List<String> listaOpcoesCartoes = new List<String>();
            if(output.cartoesDesbloqueioSenha != null && output.cartoesDesbloqueioSenha.size() > 0){

                List<String> opcaoCartao;
                String cartaoOpt;
                String listaCartoes = '';
                String sernoCartoesDesbloqueioSenha = '';
                for(DesbloqueioSenhaCartao.cartoesDesbloqueioSenha cartao : output.cartoesDesbloqueioSenha){
                    if(String.isNotBlank(cartao.numeroCartaoSerno) && String.isNotBlank(cartao.numeroCartaoOfuscado)){
                        opcaoCartao = cartao.numeroCartaoOfuscado.split('\\.');
                        cartaoOpt = opcaoCartao[opcaoCartao.size() - 1];
                        listaOpcoesCartoes.add(cartaoOpt);
                        listaCartoes += cartaoOpt + ';';
                        sernoCartoesDesbloqueioSenha += cartao.numeroCartaoSerno + ';';
                    }
                }

                responseListarCartaoDesbloqueioSenha.listaCartoes = listaCartoes;
                responseListarCartaoDesbloqueioSenha.sernoCartoesDesbloqueioSenha = sernoCartoesDesbloqueioSenha;
            }
            
            responseListarCartaoDesbloqueioSenha.cartoesDesbloqueioSenha = listaOpcoesCartoes;
        } else {
            responseListarCartaoDesbloqueioSenha.statusRetorno = 'ERRO';
        }

        toReturn.add(responseListarCartaoDesbloqueioSenha);
        return toReturn;
    }

    public class RequestListarCartaoDesbloqueioSenha {
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='Canal' required=true)
        public String canal;
        @InvocableVariable(label='Area' required=true)
        public String area;
        @InvocableVariable(label='Sistema' required=true)
        public String sistema;
    }

    public class ResponseListarCartaoDesbloqueioSenha {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Lista Cartões Elegíveis')
        public List<String> cartoesDesbloqueioSenha;
        @InvocableVariable(label='Lista Serno Cartões')
        public String sernoCartoesDesbloqueioSenha;
        @InvocableVariable(label='Lista Cartões')
        public String listaCartoes;
    }
    
}