public class Contactless {

    public static Output ContactlessBuscarStatus(String cpf, String numeroConta, String idCartao, String idEmpresa, String canal, String area, String sistema) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ContactlessBuscarStatus');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        
        user userDRT = UserDAO.getInstance().getUserDRT(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'canal' => canal,
                'area' => area,
                'sistema' => sistema,
                'login_operador' => loginOperador,
				'Id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c

            }, 
            config.Body__c.replace('{numeroConta}', numeroConta).replace('{idCartao}', idCartao), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Contactless Buscar Status', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{numeroConta}', numeroConta).replace('{idCartao}', idCartao),
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String statusAPI = String.valueOf(objHttpResponse.getStatusCode());
        Output toReturn = new Output();
        if(statusAPI == '200' || statusAPI == '204'){
            toReturn.statusAPI = 'OK';
            toReturn.outputAPI = (OutputAPI) System.JSON.deserialize(objHttpResponse.getBody(), OutputAPI.class);
        } else if(statusAPI == '400' || statusAPI == '403' || statusAPI == '422'){
            toReturn.statusAPI = 'ERRO';
            toReturn.outputAPI = (OutputAPI) System.JSON.deserialize(objHttpResponse.getBody(), OutputAPI.class);
        } else {
            toReturn.statusAPI = 'ERRO';
        }

        return  toReturn;
    }
        
    public static Output ContactlessAlterarStatus(String cpf, String numeroConta, String idCartao, String primeirosDigitosCartao, String ultimosDigitosCartao, String status, String idEmpresa, String canal, String area, String sistema) {  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ContactlessAlterarStatus');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = UserDAO.getInstance().getUserDRT(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
		
		String body = config.Body__c.replace('{numeroConta}', numeroConta).replace('{idCartao}', idCartao).replace('{primeirosDigitosCartao}', primeirosDigitosCartao);
        body = body.replace('{ultimosDigitosCartao}', ultimosDigitosCartao).replace('{status}', status);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'canal' => canal,
                'area' => area,
                'sistema' => sistema,
                'login_operador' => loginOperador,
				'Id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c

            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Contactless Alterar Status', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String statusAPI = String.valueOf(objHttpResponse.getStatusCode());
        Output toReturn = new Output();
        if(statusAPI == '200' || statusAPI == '204'){
            toReturn.statusAPI = 'OK';
            toReturn.outputAPI = (OutputAPI) System.JSON.deserialize(objHttpResponse.getBody(), OutputAPI.class);
        } else if(statusAPI == '400' || statusAPI == '403' || statusAPI == '422'){
            toReturn.statusAPI = 'ERRO';
            toReturn.outputAPI = (OutputAPI) System.JSON.deserialize(objHttpResponse.getBody(), OutputAPI.class);
        } else {
            toReturn.statusAPI = 'ERRO';
        }

        return toReturn;
    }

    public class Output{
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public OutputAPI outputAPI;
    }
	
	public class OutputAPI{
        @AuraEnabled
        public Boolean success;
		@AuraEnabled
        public String mensagem;
    }
     
}