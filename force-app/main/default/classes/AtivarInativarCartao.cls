public class AtivarInativarCartao {
    public static Boolean AtivarCartao(String numeroCartaoSerno, String idEmpresa, String cpf, String numeroConta, String sistema, String canal, String area) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AtivarCartao');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
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
                'x-uat' => config.UAT__c
            }, 
            null,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Ativar Cartao', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
            config.Method__c, 
            null,
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    

        System.debug(objHttpResponse.getStatus());
        System.debug(objHttpResponse.getStatusCode());
        
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){

            return true;
        }
        return false;    
    }

    public static Boolean InativarCartao(String numeroCartaoSerno, String idEmpresa, String cpf, String numeroConta, String sistema, String canal, String area) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('InativarCartao');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
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
                'x-uat' => config.UAT__c
            }, 
            null,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Inativar Cartao', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
            config.Method__c, 
            null,
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
}