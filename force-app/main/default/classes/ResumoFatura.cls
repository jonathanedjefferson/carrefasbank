public class ResumoFatura {

    public static OutputFatura obterResumoFaturaConta(String numeroConta, String cpf, String unidadeNegocio, String canal){  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterResumoFaturaConta');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{numeroConta}', numeroConta),
            Integer.valueof(config.Timeout__c)
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());

        LogIntegracaoBO.InsertLog(
            'Obter Resumo Fatura Conta', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{numeroConta}', numeroConta), 
            cpf, 
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   
                
        OutputFatura retorno = new OutputFatura();
        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputFatura) System.JSON.deserialize(objHttpResponse.getBody(), OutputFatura.class);
            retorno.StatusAPI = 'OK';
        } else {
            retorno.StatusAPI = 'ERROR';
        }

        return retorno;
    }

    public static OutputFatura obterResumoFaturaMes(String numeroConta, String mesAno, String cpf, String unidadeNegocio, String canal){  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterResumoFaturaMes');
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{numeroConta}', numeroConta).replace('{mesAno}', mesAno), 
            Integer.valueof(config.Timeout__c)
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        String body = objHttpResponse.getBody();
        System.debug(body);

        LogIntegracaoBO.InsertLog(
            'Obter Resumo Fatura Mes', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{numeroConta}', numeroConta).replace('{mesAno}', mesAno), 
            cpf, 
            status, 
            body,
            unidadeNegocio,
            canal.capitalize()
        );   
                
        OutputFatura retorno = new OutputFatura();

        if (status == '200') {
            if (String.isNotBlank(body)) {
                try {
                    retorno = (OutputFatura) System.JSON.deserialize(body, OutputFatura.class);
            retorno.StatusAPI = 'OK';
                } catch (Exception e) {
                    retorno.StatusAPI = 'PARSE_ERROR';
                    System.debug('Erro ao desserializar resposta da API: ' + e.getMessage());
                }
            } else {
                retorno.StatusAPI = 'EMPTY_BODY';
                System.debug('Resposta 200 mas sem body na API.');
            }
        } else if (status == '204') {
            retorno.StatusAPI = 'NO_CONTENT';
            System.debug('A API retornou 204 - sem conteúdo.');
        } else {
            retorno.StatusAPI = 'ERROR';
            System.debug('Erro na chamada da API: Status ' + status + ' | Body: ' + body);
        }

        return retorno;
    }

    public class OutputFatura{
        @AuraEnabled
        public String StatusAPI;
        @AuraEnabled
        public String numeroConta;
        @AuraEnabled
        public String mesAno;
        @AuraEnabled
        public DetalheFatura fatura;
        @AuraEnabled
        public List<DetalheFatura> faturas;
    }

    public class DetalheFatura {
        @AuraEnabled
        public String idFatura;
        @AuraEnabled
        public boolean ultimaFechada;
		@AuraEnabled
        public Valor valorFatura;
		@AuraEnabled
        public Valor valorMinimo;
		@AuraEnabled
        public Valor valorPago;
        @AuraEnabled
        public Valor limiteTotal;
        @AuraEnabled
        public Valor limiteDisponivel;
        @AuraEnabled
        public String dataFechamento;
        @AuraEnabled
        public String dataVencimento;
        @AuraEnabled
        public Integer idTipoFatura;
        @AuraEnabled
        public String tipoFatura;
        @AuraEnabled
        public List<String> faturasAnteriores;
        @AuraEnabled
        public String linhaDigitavel;
	}

    public class Valor{
        @AuraEnabled public Double valor;
        @AuraEnabled public String moeda;
    }

}