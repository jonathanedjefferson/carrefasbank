public class BoletoAvulso {

    public static OutputParametrosIniciais obterParametrosIniciais(String numeroConta, String cpf, String unidade, String canal, String sistema, String area, String loginOperador){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ParametrosBoletoAvulso');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        OutputParametrosIniciais retorno = new OutputParametrosIniciais();

        String endpoint = config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'cpf' => cpf,
            'Authorization' => 'Bearer ' + ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
            'id_empresa' => unidade,
            'sistema' => sistema,
            'area' => area,
            'login_operador' => loginOperador,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Parâmetros Boleto Avulso', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidade,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            retorno = (OutputParametrosIniciais) JSON.deserialize(objHttpResponse.getBody(), OutputParametrosIniciais.class);
            retorno.statusAPI = 'OK';
            retorno.saldoDevedorInsuficiente = false;
        }else if(objHttpResponse.getStatusCode() == 422 && objHttpResponse.getBody().containsIgnoreCase('Cliente não elegível para geração de boleto, valor da dívida menor que o valor mínimo.')){
            retorno.statusAPI = 'OK';
            retorno.saldoDevedorInsuficiente = true;
        }else{
            retorno.statusAPI = 'ERROR';
        }

        return retorno;
    }

    public static OutputGerarBoleto gerarBoletoAvulso(String numeroConta, String cpf, String unidade, String canal, String email, Decimal valorBoleto, Integer tipoBoleto, String sistema, String area, String loginOperador){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GerarBoletoAvulso');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        OutputGerarBoleto retorno = new OutputGerarBoleto();
        
        String endpoint = config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta);
        String emailCliente = email != null && email != '' ? '"'+email+'"' : 'null';
        String body = config.Body__c.replace('{valor}', String.valueOf(valorBoleto)).replace('{tipo}', String.valueOf(tipoBoleto)).replace('{email}', emailCliente);
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'cpf' => cpf,
            'canal' => canal,
            'sistema' => sistema,
            'area' => area,
            'login_operador' => loginOperador,
            'id_empresa' => unidade,
            'Authorization' => 'Bearer ' + ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Gerar Boleto Avulso', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getStatusCode() == 200 ? objHttpResponse.getBody().split('"boletoHtml"')[0] + '} // body encurtado' : objHttpResponse.getBody(), 
            unidade,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            retorno = (OutputGerarBoleto) JSON.deserialize(objHttpResponse.getBody(), OutputGerarBoleto.class);
            retorno.statusAPI = 'OK';
        } else{
            retorno.statusAPI = 'ERROR';
        }

        return retorno;
    }

    public static OutputEnviarBoleto enviarBoleto(String numeroConta, String cpf, String unidade, String canal, String email, List<String> idBoletos, String sistema, String area, String loginOperador){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('EnviarBoletoAvulso');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        OutputEnviarBoleto retorno = new OutputEnviarBoleto();

        String endpoint = config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta);
        String collectionIdsBoletos = String.join(idBoletos, ', ');
        String emailCliente = email != null && email != '' ? '"'+email+'"' : 'null';
        String body = config.Body__c.replace('{idBoletos}',collectionIdsBoletos).replace('{email}', emailCliente);
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'cpf' => cpf,
            'canal' => canal,
            'sistema' => sistema,
            'area' => area,
            'login_operador' => loginOperador,
            'id_empresa' => unidade,
            'Authorization' => 'Bearer ' + ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Envio Boleto Avulso', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidade,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            retorno.statusAPI = 'OK';
        } else{
            retorno.statusAPI = 'ERROR';
        }

        return retorno;
    }


    public class OutputParametrosIniciais{
        @AuraEnabled
        public Decimal valorMinimo;
        @AuraEnabled
        public Decimal valorMaximo;
        @AuraEnabled
        public List<BoletoValido> boletosValidos;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Boolean saldoDevedorInsuficiente;
    }

    public class BoletoValido{
        @AuraEnabled
        public Integer id;
        @AuraEnabled
        public String codigoBarras;
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String dataEmissao;
        @AuraEnabled
        public String dataVencimento;
        @AuraEnabled
        public Decimal valorBoleto;
    }

    public class OutputGerarBoleto{
        @AuraEnabled
        public String codigoBarras;
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String dataVencimentoBoleto;
        @AuraEnabled
        public String linhaDigitavelCarrefour;
        @AuraEnabled
        public Boolean indicadorBoletoRegistrado;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public String boletoPdf;
    }

    public class OutputEnviarBoleto{
        @AuraEnabled
        public String statusAPI;
    }

}