public class CalculadoraDividas {

    public static OutputObterParametros ObterParametrosBusca(String canal, String idEmpresa, String cpf, String numeroConta){
        OutputObterParametros retorno = new OutputObterParametros();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CalculadoraObterParametros');
        
        GenerateServerToken.ResponseToken token = GenerateServerToken.GetToken('TokenCalculadoraDividas', canal);
        String accessToken = null;
        if(token != null){
            accessToken = token.access_token;
        }

        String uat = config.UAT__c != null ? config.UAT__c : '';

        if(config == null || accessToken == null){
            retorno.codigoErro = 'ERROR';
        } else {
            HttpResponse objHttpResponse = Util.executarHttpRequest(
                config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta),
                config.Method__c, 
                new Map<String, String> {
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer '+ accessToken,
                    'x-uat' => uat
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
            
            String status = String.valueOf(objHttpResponse.getStatusCode());
            LogIntegracaoBO.InsertLog(
                'Calculadora de dívidas - Obter parâmetros busca', 
                config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
                config.Method__c, 
                config.Body__c, 
                cpf, 
                status, 
                objHttpResponse.getBody(),
                idEmpresa,
                canal.capitalize()
            );   

            if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
                retorno = (OutputObterParametros) System.JSON.deserialize(objHttpResponse.getBody(), OutputObterParametros.class);
                retorno.codigoErro = 'OK';
            } else if(status.equalsIgnoreCase('422')){
                retorno = (OutputObterParametros) System.JSON.deserialize(objHttpResponse.getBody(), OutputObterParametros.class);
            } else {
                retorno.codigoErro = 'ERROR';
            }
        }

        return retorno;
    }

    public static OutputCalculadoraDividas CalcularJurosEncargos(String canal, String idEmpresa, String cpf, String numeroConta,
        String dataPagamento, String valorPagamento ){
        OutputCalculadoraDividas retorno = new OutputCalculadoraDividas();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CalculadoraCalcularJurosEncargos');
        
        GenerateServerToken.ResponseToken token = GenerateServerToken.GetToken('TokenCalculadoraDividas', canal);
        String accessToken = null;
        if(token != null){
            accessToken = token.access_token;
        }

        String uat = config.UAT__c != null ? config.UAT__c : '';

        if(config == null || accessToken == null){
            retorno.codigoErro = 'ERROR';
        } else {
            String requestBody = '{}';
            if(dataPagamento != null && valorPagamento != null){
                requestBody = config.Body__c.replace('{dataPagamento}', dataPagamento).replace('{valorPagamento}', valorPagamento);
            }

            HttpResponse objHttpResponse = Util.executarHttpRequest(
                config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta),
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
                'Calculadora de dívidas - Calcular Juros e Encargos', 
                config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
                config.Method__c, 
                requestBody,
                cpf, 
                status, 
                objHttpResponse.getBody(),
                idEmpresa,
                canal.capitalize()
            );   

            if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
                retorno = (OutputCalculadoraDividas) System.JSON.deserialize(objHttpResponse.getBody(), OutputCalculadoraDividas.class);
                retorno.codigoErro = 'OK';
            } else if(status.equalsIgnoreCase('422')){
                retorno = (OutputCalculadoraDividas) System.JSON.deserialize(objHttpResponse.getBody(), OutputCalculadoraDividas.class);
            } else {
                retorno.codigoErro = 'ERROR';
            }
        }

        return retorno;
    }

    public static OutputCalculadoraDividas CalcularSaldoDevedor(String canal, String idEmpresa, String cpf, String numeroConta,
        String dataPagamento){
        OutputCalculadoraDividas retorno = new OutputCalculadoraDividas();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CalculadoraSaldoDevedor');
        
        GenerateServerToken.ResponseToken token = GenerateServerToken.GetToken('TokenCalculadoraDividas', canal);
        String accessToken = null;
        if(token != null){
            accessToken = token.access_token;
        }

        String uat = config.UAT__c != null ? config.UAT__c : '';

        if(config == null || accessToken == null){
            retorno.codigoErro = 'ERROR';
        } else {
            HttpResponse objHttpResponse = Util.executarHttpRequest(
                config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta),
                config.Method__c, 
                new Map<String, String> {
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer '+ accessToken,
                    'x-uat' => uat
                }, 
                config.Body__c.replace('{dataPagamento}', dataPagamento),
                Integer.valueof(config.Timeout__c)
            );
            
            String status = String.valueOf(objHttpResponse.getStatusCode());
            LogIntegracaoBO.InsertLog(
                'Calculadora de dívidas - Saldo Devedor', 
                config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
                config.Method__c, 
                config.Body__c.replace('{dataPagamento}', dataPagamento),
                cpf, 
                status, 
                objHttpResponse.getBody(),
                idEmpresa,
                canal.capitalize()
            );   

            if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
                retorno = (OutputCalculadoraDividas) System.JSON.deserialize(objHttpResponse.getBody(), OutputCalculadoraDividas.class);
                retorno.codigoErro = 'OK';
            } else if(status.equalsIgnoreCase('422')){
                retorno = (OutputCalculadoraDividas) System.JSON.deserialize(objHttpResponse.getBody(), OutputCalculadoraDividas.class);
            } else {
                retorno.codigoErro = 'ERROR';
            }
        }

        return retorno;
    }
        
    public class Valor {
        @AuraEnabled 
		public Double valor;
        @AuraEnabled 
		public String moeda;
    }
	
    public class OutputObterParametros {
		@AuraEnabled
		public String codigoErro;
        @AuraEnabled
		public String mensagem;
		@AuraEnabled
		public Valor pagamentoMinimo;
        @AuraEnabled
        public DateTime dataInicial;
		@AuraEnabled
        public DateTime dataFinal;
    }

    public class OutputCalculadoraDividas {
		@AuraEnabled
		public String codigoErro;
        @AuraEnabled
		public String mensagem;
        @AuraEnabled
        public DateTime dataPagamento;
        @AuraEnabled
        public Decimal valorMulta;
        @AuraEnabled
        public DateTime dataVencimentoUltimaFatura;
		@AuraEnabled
        public DateTime dataVencimentoProximaFatura;
        @AuraEnabled
        public Decimal saldoPostado;
        @AuraEnabled
        public Decimal valorParceladosFuturos;
        @AuraEnabled
        public Decimal valorDescontoAntecipacao;
        @AuraEnabled
        public Decimal valorPagamento;
        @AuraEnabled
        public Decimal saldoTotal;
        @AuraEnabled
        public Decimal valorFatura;
        @AuraEnabled
        public Decimal valorJurosEncargosCiclo;
        @AuraEnabled
        public Decimal valorJurosMora;
        @AuraEnabled
        public Decimal valorIOFAdicional;
        @AuraEnabled
        public Decimal valorIOFDiario;
        @AuraEnabled
        public Decimal valorJurosRotativo;
        @AuraEnabled
        public Decimal valorJurosRemuneratorios;
        @AuraEnabled
        public Decimal valorEncargoRotativoEmAtraso;
        @AuraEnabled
        public Decimal valorJurosRemuneratoriosParceleFacil;
        @AuraEnabled
        public Decimal valorJurosRemuneratoriosParcelaPronta;
    }
	
	
}