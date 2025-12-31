public class CancelamentoConta {
    public static Boolean CancelarConta(String numeroConta, String novoStatus, String idEmpresa, String cpf, String sistema, String canal, String area) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CancelarConta');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'login_operador' => loginOperador,
                'id_empresa' => idEmpresa,
                'cpf' => cpf,
                'sistema' => sistema,
                'canal' => canal,
                'area' => area,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c.replace('{NovoStatus}', novoStatus), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Cancelamento de Conta', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c.replace('{NovoStatus}', novoStatus), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){

            return true;
        }
        return false;    
    }

    public static OutputStatusCancelamento ListStatusCancelamentoConta(String canal, String area) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListStatusCancelamentoConta');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'canal' => canal,
                'area' => area,
                'x-uat' => config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Status de Bloqueio de Conta', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );   
        
        return (OutputStatusCancelamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputStatusCancelamento.class);
    }


    // RESPONSE REFERENTE AO MÉTODO 'ListStatusCancelamentoConta'
    public class OutputStatusCancelamento {
        @AuraEnabled
        public List<Status> status;
	}
    public class Status {
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String descricao;
    }
}