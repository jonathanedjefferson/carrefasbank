public class RetornaValoresCartaoReemissao {
    @invocableMethod(label='Retorna Valores - Cartão Reemissão')
    public static List<OutputValores> RetornaValoresCartaoReemissao(List<InputValores> inputs){

        List<OutputValores> listRetorno = new List<OutputValores>();
        OutputValores objRetorno = new OutputValores();
        
        List<String> listaOpcoesCartoes = new List<String>();
        List<String> listaSernoIds = new List<String>();
        List<String> listaStatusCartoes = new List<String>();
        
        String cartaoOpcaoSelecionada = '';
        String numeroParcelas = '';
        Integer indexOpcao = 0;
        boolean cartaoEncontrado = false;
        for (InputValores requestInput: inputs) {
            listaOpcoesCartoes.addAll(requestInput.listaOpcoesCartoes.split(';'));
            listaSernoIds.addAll(requestInput.listaSernoIds.split(';'));
            listaStatusCartoes.addAll(requestInput.listaStatusCartoes.split(';'));
            cartaoOpcaoSelecionada = requestInput.cartaoOpcaoSelecionada;
            break;
        }
        
        if(!String.isBlank(cartaoOpcaoSelecionada)){
            for(String opcaoCartao : listaOpcoesCartoes){
                if(opcaoCartao.equals(cartaoOpcaoSelecionada)){
                    cartaoEncontrado = true;
                    break;
                }
                
                indexOpcao++;
            }
        }
                    
        if(cartaoEncontrado){         
            List<String> statusBloqueadoDefinitivo = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueadoDefinitivo');

            String status = listaStatusCartoes[indexOpcao];
            if(statusBloqueadoDefinitivo != null && statusBloqueadoDefinitivo.contains(status)){
                objRetorno.cartaoBloqueado = 'BLOQ';
            } else {
                objRetorno.cartaoBloqueado = 'N_BLOQ';
            }

            objRetorno.sernoCartao = listaSernoIds[indexOpcao];
            objRetorno.statusCartaoSelecionado = status;
        }

        listRetorno.add(objRetorno);
        return listRetorno;
    }

    public class InputValores{
        @InvocableVariable(required = true)
        public String cartaoOpcaoSelecionada;
        @InvocableVariable(required = true)
        public String listaOpcoesCartoes;
        @InvocableVariable(required = true)
        public String listaSernoIds;
        @InvocableVariable(required = true)
        public String listaStatusCartoes;
    }

    public class OutputValores{
        @InvocableVariable(label='O cartão está bloqueado')
        public String cartaoBloqueado;
        @InvocableVariable(label='Número serno cartão')
        public String sernoCartao;
        @InvocableVariable(label='Status do cartão')
        public String statusCartaoSelecionado;
    }
}