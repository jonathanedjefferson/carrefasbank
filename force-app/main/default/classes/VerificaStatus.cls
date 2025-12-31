public class VerificaStatus {
	@InvocableMethod(label='Verifica status')
    public static List<ResponseVerificaStatus> VerificaStatus(List<RequestVerificaStatus> parametersRequest){
        List<ResponseVerificaStatus> toReturn = new List<ResponseVerificaStatus>();
        ResponseVerificaStatus responseVerificaStatus = new ResponseVerificaStatus();
        
        List<String> statusCancelado = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoCancelado');
        List<String> statusBloqueado = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueado');
        List<String> statusBloqueadoDefinitivo = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueadoDefinitivo');
        List<String> statusFraude = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoFraude');
        List<String> statusCartaoPlanoParcelamento = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoPlanoParcelamento');
        List<String> statusCartaoCobranca = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoCobranca');
        List<String> statusCartaoNormal = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoNormal');
        List<String> statusCartaoBloqueioParcelamento = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoBloqueioParcelamento');
   
        String codigoStatusCartao;
        String codigoStatusConta;
        String codigoStatusRetorno;
        
        for(RequestVerificaStatus request: parametersRequest){
            codigoStatusCartao = request.codigoStatusCartao;
            codigoStatusConta = request.codigoStatusConta;
        }
             
		if(!String.isBlank(codigoStatusConta)){
            if(codigoStatusConta == 'NORM'){
                codigoStatusCartao = codigoStatusCartao.trim();
            	codigoStatusRetorno = codigoStatusCartao;
            }
            else{
				codigoStatusConta = codigoStatusConta.trim();
                codigoStatusRetorno = codigoStatusConta;
            }
		}
        else if(!String.isBlank(codigoStatusCartao)){
            codigoStatusCartao = codigoStatusCartao.trim();
			codigoStatusRetorno = codigoStatusCartao;
        }  
		
		if(statusCancelado.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'CANCEL';
		} else if(statusBloqueado.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'BLOQ';
		} else if(statusBloqueadoDefinitivo.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'BLOQ_DEFIN';
		} else if(statusFraude.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'FRAUDE';
		} else if(statusCartaoPlanoParcelamento.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'PLANO_PARCELAMENTO';
		} else if(statusCartaoCobranca.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'COBR';
		} else if(statusCartaoNormal.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'NORMAL';
		} else if(statusCartaoBloqueioParcelamento.contains(codigoStatusRetorno)){
			responseVerificaStatus.status = 'BLOQ_PARC';
		} else {
			responseVerificaStatus.status = 'OUTROS';
		}
                
        toReturn.add(responseVerificaStatus);
        return toReturn;
    }
        
    public class RequestVerificaStatus {
        @InvocableVariable(label='Status Conta' required=true)
        public String codigoStatusConta;
        @InvocableVariable(label='Status Cartão' required=true)
        public String codigoStatusCartao;
    }
    
    public class ResponseVerificaStatus {
        @InvocableVariable(label='Status')
        public String status;
    }
}