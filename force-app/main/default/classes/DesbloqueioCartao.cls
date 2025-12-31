public class DesbloqueioCartao {
    public static Boolean DesbloquearCartao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DesbloquearCartao');
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
                'sistema' => sistema,
                'canal' => canal,
                'area' => area,
                'cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Desbloquear Cartão', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
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
            return true;
        }
        return false;
    }


    public static List<OutputListCartoesParaDesbloqueio> ListCartoesParaDesbloqueio(String canal, String area, String cpf, String numeroConta){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListCartoesParaDesbloqueio');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'canal' => canal,
                'area' => area,
                'cpf' => cpf,
                'x-uat' => config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Cartões para Desbloqueio', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );   

        return (List<OutputListCartoesParaDesbloqueio>) JSON.deserialize(objHttpResponse.getBody(), List<OutputListCartoesParaDesbloqueio>.class);
    }


    // RESPONSE REFERENTE AO MÉTODO 'ListCartoesParaDesbloqueio'
    public class OutputListCartoesParaDesbloqueio {
        @AuraEnabled
        public String numeroCartaoOfuscado;
        @AuraEnabled
        public String numeroCartaoSerno;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Boolean ehPrimario;
        @AuraEnabled
        public String nomeCartao;
        @AuraEnabled
        public String nomePortador;
    }
}