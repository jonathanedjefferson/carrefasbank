public with sharing class OfertaSeguroWhatsApp {
    @InvocableMethod (label = 'Oferta Seguro WhatsApp')
    
    public static list<ResponseElegibilidade> OfertaSeguro(List<RequestSeguro> parametersRequest) {
        
        List<ResponseElegibilidade> toReturn = new List<ResponseElegibilidade>();
        ResponseElegibilidade responseSeguro = new ResponseElegibilidade();
        
        
        for(RequestSeguro requestSeguro: parametersRequest){

            List<String> produtosLst = requestSeguro.produtos != null ? new List<String>{requestSeguro.produtos} : new List<String>();
           
            OfertaSeguro.ElegibilidadeTO elegivelPara = OfertaSeguro.getElegibilidade(requestSeguro.numeroConta, requestSeguro.idEmpresa, produtosLst, '', requestSeguro.canal, requestSeguro.cpf);
            if(elegivelPara != null && elegivelPara.produtos.size() != 0){
                responseSeguro.elegivel = 'OK';
                for(OfertaSeguro.ProdutoTO produto : elegivelPara.produtos){
                    if(!produto.coberturasPlano.isEmpty()){
                        for(OfertaSeguro.coberturasPlanoTO cobertura : produto.coberturasPlano){
                            if(cobertura.idPlano != null){
                                responseSeguro.idPlano=cobertura.idPlano;
                                break;
                            }
                        }
                    }    
                    if(responseSeguro.idPlano != null) break;
                }
            }
            
            else if(elegivelPara != null && elegivelPara.produtos.size() == 0){
                responseSeguro.elegivel = 'NAO ELEGIVEL';
            }    
        
            else {
                responseSeguro.elegivel  = 'ERRO';
            } 
            toReturn.add(responseSeguro);

        }
        return toReturn;
    }
    
    public class RequestSeguro {
        @InvocableVariable(label='Numero conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Produtos')
        public String produtos;
        @InvocableVariable(label='cpf')
        public String cpf;
        @InvocableVariable(label='Id Empresa' required=true)
        public Integer idEmpresa;
        @InvocableVariable(required=true)
        public String canal;
    }

    public class ResponseElegibilidade {
        @InvocableVariable(label='Status Chamada')
        public String elegivel;
        @InvocableVariable(label='Id do Plano')
        public String idPlano;
    }
}