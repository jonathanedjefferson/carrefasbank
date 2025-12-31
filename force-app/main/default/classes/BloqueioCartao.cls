public class BloqueioCartao {
    public static Boolean BloquearCartao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno, String novoStatus){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BloquearCartao');
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
                'id_empresa' => idEmpresa,
                'sistema' => sistema,
                'canal' => canal,
                'area' => area,
                'login_operador' => loginOperador,
                'cpf' => cpf,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c.replace('{NovoStatus}', novoStatus), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Bloquear Cartão', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
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

    public static String BloquearCartaoContestacao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno, String novoStatus){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BloquearCartaoContestacao');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        //PEGANDO METADADO CUSTOM organizationType
        organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');
        
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
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
            config.Body__c.replace('{NovoStatus}', novoStatus), 
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Bloquear Cartão Contestação', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
            config.Method__c, 
            config.Body__c.replace('{NovoStatus}', novoStatus), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        String toReturn;
         if(status == '200' || status == '204'){
            toReturn = 'OK';
        } else if(status == '403'){
            toReturn = 'ERRO_PERFILIZACAO';
        } else {
            toReturn = 'ERRO';
        }

        return toReturn;
    }

    public static List<OutputListCartoesParaBloqueio> ListCartoesParaBloqueio(String canal, String area, String cpf, String numeroConta){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListCartoesParaBloqueio');
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
            'Listar Cartões para Bloqueio', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );   

        return (List<OutputListCartoesParaBloqueio>) System.JSON.deserialize(objHttpResponse.getBody(), List<OutputListCartoesParaBloqueio>.class);       
    }

    
    public static OutputStatusBloqueio ListStatusBloqueioCartao(String canal, String area){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListStatusBloqueioCartao');
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
            'Listar Status de Bloqueio de Cartão', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );   
        
        return (OutputStatusBloqueio) System.JSON.deserialize(objHttpResponse.getBody(), OutputStatusBloqueio.class);
    }



    // RESPONSE REFERENTE AO MÉTODO 'ListStatusBloqueioCartao'
    public class OutputStatusBloqueio {
        @AuraEnabled
        public List<Status> status;
    }
    public class Status {
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String descricao;
    }
    
        
    // RESPONSE REFERENTE AO MÉTODO 'ListCartoesParaBloqueio'
    public class OutputListCartoesParaBloqueio {
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