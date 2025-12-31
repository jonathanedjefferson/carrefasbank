public class DesbloqueioConta {
       
    public static Output DesbloquearConta(String cpf, String numeroConta, String idEmpresa, String canal, String area, String sistema) {  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DesbloquearConta');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = UserDAO.getInstance().getUserDRT(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
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
            '', 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Desbloquear Conta', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            '', 
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
        } else if(statusAPI == '403'){
            toReturn.statusAPI = 'ERRO_PERFILIZACAO';
        } else {
            toReturn.statusAPI = 'ERRO';
        }

        return toReturn;
    }

    public class Output{
        @AuraEnabled
        public String statusAPI;
    }
     
}