public without sharing class IntegrationAdicional {
    public static OutputSolicitarCartaoAdicional SolicitarCartaoAdicional(String cpf, String numeroConta, String canal, 
        String area, String sistema, String unidadeNegocio, String cpfAdicional, String nomeAdicional, 
        String sexoAdicional, String dataNascimentoAdicional) {

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('SolicitarCartaoAdicional');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        String body = config.Body__c.replace('{cpfAdicional}', cpfAdicional).replace('{nomeAdicional}', nomeAdicional).replace('{sexoAdicional}', sexoAdicional).replace('{dataNascimentoAdicional}', String.valueOf(dataNascimentoAdicional)).replace('{canal}', canal);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'area' => area,
                'sistema' => sistema,
                'canal' => canal,
                'Id_empresa' => unidadeNegocio,
                'Login_operador' => loginOperador,
                'x-uat' => config.UAT__c

            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );  

        String status = String.valueOf(objHttpResponse.getStatusCode());
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Solicitar Cartão Adicional', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            body,
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        OutputSolicitarCartaoAdicional retorno = new OutputSolicitarCartaoAdicional();
        if(status.equals('200') || status.equals('204')){
            retorno.statusAPI = 'OK';
        } else if(status.equals('400')){
            retorno.statusAPI = 'ERROR_400';
            retorno.mensagem = objHttpResponse.getBody();
        } else if(status.equals('422')){
            retorno.statusAPI = 'ERROR_422';
            retorno.mensagem = objHttpResponse.getBody();
        } else {
            retorno.statusAPI = 'ERROR';
        }
        
        return retorno;
    }


    public class OutputSolicitarCartaoAdicional{
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public String mensagem;
    }
}