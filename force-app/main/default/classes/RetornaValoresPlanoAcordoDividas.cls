public class RetornaValoresPlanoAcordoDividas {
    @invocableMethod(label='Retorna Valores Plano - Acordo de Dívidas')
    public static List<OutputValores> RetornaValoresPlanoAcordo(List<InputValores> inputs){
        System.debug('-------> '+ inputs);
        List<OutputValores> listRetorno = new List<OutputValores>();
        OutputValores objRetorno = new OutputValores();
        
        List<String> idsPlanosAcordo = new List<String>();
        List<String> valoresPlanosAcordo = new List<String>();
        List<String> identificadoresPlanosAcordo = new List<String>();
        List<String> descontosPlanosAcordo = new List<String>();
        
        String opcaoSelecionada = '';
        String numeroParcelas = '';
        Integer indexParcela = 0;
        boolean idParcelaEncontrado = false;
        for (InputValores item: inputs) {
            String indicadores = item.identificadoresPlanosAcordo + item.identificadoresPlanosAcordo2; 
        
            idsPlanosAcordo.addAll(item.idsPlanosAcordo.split(';'));
            valoresPlanosAcordo.addAll(item.valoresPlanosAcordo.split(';'));
            identificadoresPlanosAcordo.addAll(indicadores.split(';'));
            descontosPlanosAcordo.addAll(item.descontosPlanosAcordo.split(';'));
            opcaoSelecionada = item.acordoOpcaoSelecionada;
            break;
        }
        
        if(!String.isBlank(opcaoSelecionada)){
            // ex. 1 parcela de R$1.413,15
            String[] splitOpcaoSelecionada = opcaoSelecionada.split('parcela');
            if (opcaoSelecionada.contains('vista')) {
                numeroParcelas = '1';
            }else{
                numeroParcelas = splitOpcaoSelecionada[0].replace('*', '').replace('Em', '').replace(' ', '');
            }
            
            if(!String.isBlank(numeroParcelas)){
                for(String idPlano : idsPlanosAcordo){
                    if(numeroParcelas.equals(idPlano)){
                        idParcelaEncontrado = true;
                        break;
                    }
                    
                    indexParcela++;
                }
            }
        }
                    
        if(idParcelaEncontrado){          
            String valorParcela = valoresPlanosAcordo[indexParcela];
            objRetorno.numeroParcelaPlanoAcordo = numeroParcelas;
            objRetorno.descontoPlanoAcordo = descontosPlanosAcordo[indexParcela];
            objRetorno.identificadorPlanoAcordo = identificadoresPlanosAcordo[indexParcela];
            
            if(valorParcela != null){
                valorParcela = valorParcela.replace('.','').replace(',','.');
                Decimal valor = Decimal.valueOf(valorParcela);
                objRetorno.valorPlanoAcordo = 'R$' + String.valueOf(valor.format());
                Decimal valorFinal = valor * Integer.valueOf(objRetorno.numeroParcelaPlanoAcordo);
                objRetorno.valorFinalPlanoAcordo = 'R$' + String.valueOf(valorFinal.format());
            }
        }

        listRetorno.add(objRetorno);
        System.debug('-------> '+ listRetorno);

        return listRetorno;
    }

    public class InputValores{
        @InvocableVariable(required = true)
        public String acordoOpcaoSelecionada;
        @InvocableVariable(required = true)
        public String idsPlanosAcordo;
        @InvocableVariable(required = true)
        public String valoresPlanosAcordo;
        @InvocableVariable(required = true)
        public String identificadoresPlanosAcordo;
        @InvocableVariable/* (required = true) */
        public String identificadoresPlanosAcordo2;
        @InvocableVariable(required = true)
        public String descontosPlanosAcordo;
    }

    public class OutputValores{
        @InvocableVariable(label='Numero Parcela Plano Acordo')
        public String numeroParcelaPlanoAcordo;
        @InvocableVariable(label='Valor Plano Acordo')
        public String valorPlanoAcordo;
        @InvocableVariable(label='Desconto Plano Acordo')
        public String descontoPlanoAcordo;
        @InvocableVariable(label='Identificador Plano Acordo')
        public String identificadorPlanoAcordo;
        @InvocableVariable(label='Valor Final Plano Acordo')
        public String valorFinalPlanoAcordo;
    }
}