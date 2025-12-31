public class DebitoAutomatico {
    public static OutputDebitoAutomatico ConsultarDebitoAutomatico(String cpf, String numeroConta, String nomeCorrentista, String idEmpresa, String canal) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarDebitoAutomatico');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        
        String body =  config.Body__c.replace('{numeroConta}', numeroConta).replace('{cpf}', cpf).replace('{nomeCorrentista}', nomeCorrentista);
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar Débito Automático', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200'){
             return (OutputDebitoAutomatico) System.JSON.deserialize(objHttpResponse.getBody(), OutputDebitoAutomatico.class);
        } else {
            return null;
        }
    }
        
    public static boolean CadastrarDebitoAutomatico(String cpf, String numeroConta, String nomeCorrentista, String codigoBanco,  String numeroAgencia, String numeroContaBancaria, String tipoPagamento, String idEmpresa, String canal) {  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CadastrarDebitoAutomatico');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String body = config.Body__c.replace('{numeroConta}', numeroConta).replace('{cpf}', cpf).replace('{nomeCorrentista}', nomeCorrentista);
        body = body.replace('{codigoBanco}', codigoBanco).replace('{numeroAgencia}', numeroAgencia).replace('{numeroContaBancaria}', numeroContaBancaria);
        body = body.replace('{tipoPagamento}', tipoPagamento).replace('{idEmpresa}', idEmpresa).replace('{canal}', canal);
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Cadastrar Débito Automático', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200'){
             return true;
        } else {
            return false;
        }
    }
            
    public static boolean RemoverDebitoAutomatico(String cpf, String numeroConta, String nomeCorrentista, String codigoBanco, String numeroAgencia, String numeroContaBancaria, String tipoPagamento, String idEmpresa, String canal) {  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('RemoverDebitoAutomatico');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String body = config.Body__c.replace('{numeroConta}', numeroConta).replace('{cpf}', cpf).replace('{nomeCorrentista}', nomeCorrentista);
        body = body.replace('{codigoBanco}', codigoBanco).replace('{numeroAgencia}', numeroAgencia).replace('{numeroContaBancaria}', numeroContaBancaria);
        body = body.replace('{tipoPagamento}', tipoPagamento).replace('{idEmpresa}', idEmpresa).replace('{canal}', canal);
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Remover Débito Automático', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200'){
             return true;
        } else {
            return false;
        }
    }
    
    
    // OUTPUT
    public class OutputDebitoAutomatico {
        @AuraEnabled
        public String nrBancoAgencia;
        @AuraEnabled
        public String numeroContaBancaria;
        @AuraEnabled
        public String numeroConta;
        @AuraEnabled
        public String tipoDebito;
        @AuraEnabled
        public String tipoPagamento;
    }
     
}