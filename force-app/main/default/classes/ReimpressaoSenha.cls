public class ReimpressaoSenha {
    public static String ReimprimirSenha(String numeroConta, String numeroCartaoSerno, String idEmpresa, String cpf, String canal, String area, String sistema){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ReimpressaoSenha');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Reimpressão de Senha', 
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
            return 'OK';
        }else if(status == '422'){
            return 'Em andamento';
        }
        
        return 'ERROR';    
    }


    public static List<OutputListarCartoes> ListarCartoes(String numeroConta, String idEmpresa, String cpf, String canal, String area){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListarCartoesReimpressaoSenha');
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
                'cpf' => cpf,
                'canal' => canal,
                'area' => area,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Cartões - Reimpressão de Senha', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
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
            return (List<OutputListarCartoes>) JSON.deserialize(objHttpResponse.getBody(), List<OutputListarCartoes>.class);
        }

        List<OutputListarCartoes> listRetorno = new List<OutputListarCartoes>();
        OutputListarCartoes outp = new OutputListarCartoes();
        outp.StatusOK = 'ERROR';

        listRetorno.add(outp);
        return listRetorno;
    }




    // RESPONSE REFERENTE AO MÉTODO 'ListarCartoes'
    public class OutputListarCartoes {
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
        @AuraEnabled
        public String StatusOK;
    }
}