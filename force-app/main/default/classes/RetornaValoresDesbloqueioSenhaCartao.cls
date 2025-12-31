public class RetornaValoresDesbloqueioSenhaCartao {

    @invocableMethod(label='Retorna Valores - Desbloqueio Senha Cartão')
    public static List<OutputValores> RetornaValoresDesbloqueioSenhaCartao(List<InputValores> inputs){

        List<OutputValores> listRetorno = new List<OutputValores>();
        OutputValores objRetorno = new OutputValores();
        
        List<String> listaSernoIds = new List<String>();
        List<String> listaCartoes = new List<String>();
        
        String cartaoOpcaoSelecionada = '';
        Integer indexOpcao = 0;
        boolean cartaoEncontrado = false;
        for (InputValores requestInput: inputs) {
            listaCartoes.addAll(requestInput.listaCartoes.split(';'));
            listaSernoIds.addAll(requestInput.listaSernoIds.split(';'));
            cartaoOpcaoSelecionada = requestInput.cartaoOpcaoSelecionada;
            break;
        }
        
        if(!String.isBlank(cartaoOpcaoSelecionada)){
            for(String opcaoCartao : listaCartoes){
                if(opcaoCartao.equals(cartaoOpcaoSelecionada)){
                    cartaoEncontrado = true;
                    break;
                }
                
                indexOpcao++;
            }
        }
                    
        if(cartaoEncontrado){         
            objRetorno.sernoCartao = listaSernoIds[indexOpcao];
        }

        listRetorno.add(objRetorno);
        return listRetorno;
    }

    public class InputValores{
        @InvocableVariable(required = true)
        public String cartaoOpcaoSelecionada;
        @InvocableVariable(required = true)
        public String listaCartoes;
        @InvocableVariable(required = true)
        public String listaSernoIds;
    }

    public class OutputValores{
        @InvocableVariable(label='Número Serno Cartão')
        public String sernoCartao;
    }
}