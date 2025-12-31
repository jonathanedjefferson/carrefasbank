public class VerificaStatusCartao {

    @InvocableMethod(label='Verifica status cartão')
    public static List<ResponseVerificaStatusCartao> VerificaStatusCartao(List<RequestVerificaStatusCartao> parametersRequest){
        List<ResponseVerificaStatusCartao> toReturn = new List<ResponseVerificaStatusCartao>();
        ResponseVerificaStatusCartao responseVerificaStatusCartao = new ResponseVerificaStatusCartao();
        
        List<String> statusCancelado = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoCancelado');
        List<String> statusBloqueado = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueado');
        List<String> statusBloqueadoDefinitivo = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueadoDefinitivo');
        List<String> statusFraude = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoFraude');
        List<String> statusCartaoPlanoParcelamento = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoPlanoParcelamento');
        List<String> statusCartaoCobranca = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoCobranca');
        List<String> statusCartaoNormal = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoNormal');
        List<String> statusCartaoBloqueioParcelamento = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueioParcelamento');
   
        for(RequestVerificaStatusCartao request: parametersRequest){

            String codigoStatusCartao = request.codigoStatusCartao;
            if(!String.isBlank(codigoStatusCartao)){
                codigoStatusCartao = codigoStatusCartao.trim();
            }
            
            if(statusCancelado.contains(codigoStatusCartao)){
                    responseVerificaStatusCartao.statusCartao = 'CANCEL';
            } else if(statusBloqueado.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'BLOQ';
            } else if(statusBloqueadoDefinitivo.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'BLOQ_DEFIN';
            } else if(statusFraude.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'FRAUDE';
            } else if(statusCartaoPlanoParcelamento.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'PLANO_PARCELAMENTO';
            } else if(statusCartaoCobranca.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'COBR';
            } else if(statusCartaoNormal.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'NORMAL';
            } else if(statusCartaoBloqueioParcelamento.contains(codigoStatusCartao)){
                responseVerificaStatusCartao.statusCartao = 'BLOQ_PARC';
            } else {
                responseVerificaStatusCartao.statusCartao = 'OUTROS';
            }
        
        }
        
        toReturn.add(responseVerificaStatusCartao);
        return toReturn;
    }
        
    public class RequestVerificaStatusCartao {
        @InvocableVariable(label='Status Cartão' required=true)
        public String codigoStatusCartao;
    }
    
    public class ResponseVerificaStatusCartao {
        @InvocableVariable(label='Status do cartão')
        public String statusCartao;
    }
}