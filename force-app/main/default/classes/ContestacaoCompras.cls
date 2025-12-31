public class ContestacaoCompras {

    private static String MTI = '9900'; // Identificador do Tipo de Mensagem

    public static List<OutputMarcarTransacao> MarcarTransacaoPaytrue(
        String canal, String idEmpresa, String cpf, String dataFraudeReportada,
        String tipoFraude, List<LancamentoContestadoBO.LancamentoContestado> lancamentosContestados){

        List<OutputMarcarTransacao> toReturn = new List<OutputMarcarTransacao>();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('MarcarTransacaoPaytrue');
        GenerateServerToken.ResponseToken token = GenerateServerToken.GetToken('TokenCSFServicos', canal);
        String accessToken = null;
        if(token != null){
            accessToken = token.access_token;
        }
            
        OutputMarcarTransacao retornoMarcacao = null;
        if(config == null || accessToken == null){
            retornoMarcacao = new OutputMarcarTransacao();
            retornoMarcacao.retornoAPI = 'ERROR';
            toReturn.add(retornoMarcacao);
        } else {
            String requestBody = null;
            String uat = config.UAT__c != null ? config.UAT__c : '';

            for(LancamentoContestadoBO.LancamentoContestado transacao : lancamentosContestados){
                retornoMarcacao = new OutputMarcarTransacao();

                requestBody = config.Body__c.replace('{mti}', MTI)
                .replace('{dataReporte}', dataFraudeReportada)
                .replace('{numeroCartao}', transacao.numeroCartaoOfuscado)
                .replace('{numeroConta}', transacao.numeroConta)
                .replace('{codigoAutorizacao}', transacao.codigoTransacao)
                .replace('{dataTransacao}', transacao.dataTransacaoISO)
                .replace('{tipoFraude}', tipoFraude);
                
                
                HttpResponse objHttpResponse = Util.executarHttpRequest(
                    config.Endpoint__c + config.Path__c,
                    config.Method__c, 
                    new Map<String, String> {
                        'Content-Type' => 'application/json',
                        'Authorization' => 'Bearer '+ accessToken,
                        'x-uat' => uat
                    }, 
                    requestBody,
                    Integer.valueof(config.Timeout__c)
                );
                
                String status = String.valueOf(objHttpResponse.getStatusCode());
                LogIntegracaoBO.InsertLog(
                    'Marcar Transação Paytrue', 
                    config.Endpoint__c + config.Path__c, 
                    config.Method__c, 
                    requestBody,
                    cpf, 
                    status, 
                    objHttpResponse.getBody(),
                    idEmpresa,
                    canal.capitalize()
                );   
    
                if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
                    retornoMarcacao = (OutputMarcarTransacao) System.JSON.deserialize(objHttpResponse.getBody(), OutputMarcarTransacao.class);
                    retornoMarcacao.retornoAPI = 'OK';
                } else {
                    retornoMarcacao.retornoAPI = 'ERROR';
                }

                toReturn.add(retornoMarcacao);
            }
        }

        return toReturn;
    }

    public class OutputMarcarTransacao {
        @AuraEnabled
		public String retornoAPI;
		@AuraEnabled
		public String N_MTI;
        @AuraEnabled
		public String N_STATUS;
        @AuraEnabled
        public String S_RESPONSE_TEXT;
    }
}