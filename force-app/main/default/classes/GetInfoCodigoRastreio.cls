public class GetInfoCodigoRastreio {
    @invocableMethod(label='Código de Rastreio - Get Info Selecionada')
    public static List<Output> GetCodigoRastreior(List<Input> listInputs) {
        Output retorno = new Output();
        String optionSelected = '';
        List<String> listAllOptions = new List<String>();
        
        for (Input item: listInputs) {
            listAllOptions = item.ListStringAllCartoes.split('<br>');
            optionSelected = item.OpcaoSelecionada;
            break;
        }

        for (String item: listAllOptions) {
            if (item.containsIgnoreCase(optionSelected.split(' ')[2])) {
                retorno.InfoCartaoSelecionado = item;
                break;
            }
        }
        
        return new List<Output> {retorno};
    }

    public class Input{
        @InvocableVariable(required = true)
        public String OpcaoSelecionada; 
        @InvocableVariable(required = true)
        public String ListStringAllCartoes;
    }
    
    public class Output{
        @InvocableVariable
        public String InfoCartaoSelecionado;
    }
}