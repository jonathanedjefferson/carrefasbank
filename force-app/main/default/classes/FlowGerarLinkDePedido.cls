public class FlowGerarLinkDePedido {
    @InvocableMethod(label='Gerar Link de produtos')
    public static List<Output> chamarLinkCatalogo(List<Input> lstEntrada) {
        List<Output> outputList = new List<Output>();
        try{
            String Items = lstEntrada[0].items != null ?lstEntrada[0].items.replaceAll(',', '-'): '';
            String Categoria = lstEntrada[0].categoria != null ?lstEntrada[0].categoria: '';
            String CEP = lstEntrada[0].cep != null ?lstEntrada[0].cep: '';
            
            if ( Categoria != null && CEP != null) { 
                GerarLinkDeCatalogoTO.ResponseWrapper result = GerarLinkDeCatalogo.gerarLink(Items, Categoria, CEP);     
                System.debug('Return flow' + result);
                if (result.success == true) {
                    Output output = new Output();
                    output.orderURL = result.payload.orderURL;
                    output.orderFormId = result.payload.orderFormId;
    
                    outputList.add(output); // Adicionar objeto Output à lista de output
                    System.debug('output: '+ output);
                }
            }
        }catch(Exception ex){
                System.debug('Error: ' + ex.getMessage());
            return null;
        }
       return outputList;
    }

    public class Input {
        @InvocableVariable(label='Items' required=false)
        public String Items;
        @InvocableVariable(label='Categoria' required=true)
        public String Categoria;
        @InvocableVariable(label='CEP' required=true)
        public String CEP;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public String orderFormId;
        @AuraEnabled @InvocableVariable
        public String orderURL;
    }
}