public class ConsultaElegibilidadeSeguros {
    @InvocableMethod (label = 'Consulta Elegibilidade Seguros - Chat Enhanced')
    
    public static list<ResponseElegibilidade> OfertaSeguro(List<RequestSeguro> parametersRequest) {
        
        List<ResponseElegibilidade> toReturn = new List<ResponseElegibilidade>();
        ResponseElegibilidade responseSeguro = new ResponseElegibilidade();
        
        
        for(RequestSeguro requestSeguro: parametersRequest){

            String token = TokenCSFServicos.getTokenByCPF(requestSeguro.canal, requestSeguro.cpf).access_token;

            List<String> produtosLst = requestSeguro.produtos != null ? new List<String>{requestSeguro.produtos} : new List<String>();
           
            OfertaSeguro.ElegibilidadeTO elegivelPara = OfertaSeguro.getElegibilidade(requestSeguro.numeroConta, requestSeguro.idEmpresa, produtosLst, token, requestSeguro.canal);
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
        @InvocableVariable(label='Token Logado')
        public String tokenLogado;
        @InvocableVariable(label='Id Empresa' required=true)
        public Integer idEmpresa;
        @InvocableVariable(required=true)
        public String canal;
        @InvocableVariable(required=true)
        public String cpf;
    }

    public class ResponseElegibilidade {
        @InvocableVariable(label='Status Chamada')
        public String elegivel;
        @InvocableVariable(label='Id do Plano')
        public String idPlano;
    }
}