public class AlterarModoEnvioFatura {
    public static OutputTiposEnvioFatura GetTiposEnvioFatura(String canal, String cpf, String idEmpresa){
        OutputTiposEnvioFatura retorno = new OutputTiposEnvioFatura();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetTiposEnvioFatura');
        
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{canal}', canal), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Get Tipos de Envio Fatura', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (OutputTiposEnvioFatura) JSON.deserialize(objHttpResponse.getBody(), OutputTiposEnvioFatura.class);
            retorno.StatusAPI = 'OK';
            return retorno;
        }
        
        retorno.StatusAPI = 'ERROR';
        return retorno;
    }

    public static OutputUpdateModoEnvioFatura UpdateTipoEnvioFatura(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String tipoEnvioFatura, Boolean alteracaoCadastral){
        OutputUpdateModoEnvioFatura retorno = new OutputUpdateModoEnvioFatura();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('UpdateTipoEnvioFatura');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{tipoEnvioFatura}', tipoEnvioFatura), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'id_empresa' => idEmpresa,
                'sistema' => sistema,
                'canal' => canal,
                'area' => area,
                'login_operador' => loginOperador,
                'cpf' => cpf,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c.replace('{alteracaoCadastral}', (alteracaoCadastral) ? 'true' : 'false'), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Alterar Modo de Envio de Fatura', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{tipoEnvioFatura}', tipoEnvioFatura), 
            config.Method__c, 
            config.Body__c.replace('{alteracaoCadastral}', (alteracaoCadastral) ? 'true' : 'false'), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno =  (OutputUpdateModoEnvioFatura) JSON.deserialize(objHttpResponse.getBody(), OutputUpdateModoEnvioFatura.class);
            retorno.StatusAPI = 'OK';
            return retorno; 
        }
        
        retorno.StatusAPI = 'ERROR';
        return retorno; 
    }

    public static OutputUpdateEmailEnvioFatura UpdateEmailEnvioFatura(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String emailToUpdate){
        OutputUpdateEmailEnvioFatura retorno = new OutputUpdateEmailEnvioFatura();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('UpdateEmailEnvioFatura');
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
                'id_empresa' => idEmpresa,
                'sistema' => sistema,
                'canal' => canal,
                'area' => area,
                'login_operador' => loginOperador,
                'cpf' => cpf,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c.replace('{emailToUpdate}', emailToUpdate), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Update Email Para Envio de Fatura', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c.replace('{emailToUpdate}', emailToUpdate), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno =  (OutputUpdateEmailEnvioFatura) JSON.deserialize(objHttpResponse.getBody(), OutputUpdateEmailEnvioFatura.class);
            retorno.StatusAPI = 'OK';
            return retorno; 
        }
        retorno.StatusAPI = 'ERROR';
        return retorno; 
    }

    
    // RETORNO DO MÉTODO GetTiposEnvioFatura
    public class OutputTiposEnvioFatura {
        @AuraEnabled
        public List<Integer> tiposEnvioFatura;
        @AuraEnabled
        public String StatusAPI;
    }
    
    // RETORNO DO MÉTODO UpdateTipoEnvioFatura
    public class OutputUpdateModoEnvioFatura {
        @AuraEnabled
        public Integer valor;
        @AuraEnabled
        public String descricao;
        @AuraEnabled
        public String StatusAPI;
    }
    
    // RETORNO DO MÉTODO UpdateEmailEnvioFatura
    public class OutputUpdateEmailEnvioFatura {
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String StatusAPI;
    }
}