public class DesbloqueioSenhaCartao {

    public static OutputListarCartaoDesbloqueioSenha ListarCartaoDesbloqueioSenha(String cpf, String numeroConta, String idEmpresa, String canal, String area, String sistema) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListarCartaoDesbloqueioSenha');
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
                'cpf' => cpf,
                'canal' => canal,
                'area' => area,
                'sistema' => sistema,
                'login_operador' => loginOperador,
               'x-uat' => config.UAT__c == null ? ' ' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO ACORDO
        LogIntegracaoBO.InsertLog(
            'Listar Cartão Desbloqueio de Senha', 
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
        OutputListarCartaoDesbloqueioSenha toReturn = new OutputListarCartaoDesbloqueioSenha();
        if(status == '200' || status == '204'){
            toReturn.statusAPI = 'OK';
            toReturn.cartoesDesbloqueioSenha = (List<CartoesDesbloqueioSenha>) System.JSON.deserialize(objHttpResponse.getBody(), List<CartoesDesbloqueioSenha>.class);
        } else {
            toReturn.statusAPI = 'ERRO';
        }

        return  toReturn;
    }
        
    public static OutputDesbloquearSenhaCartao DesbloquearSenhaCartao(String cpf, String numeroConta, String idEmpresa, String canal, String area, String sistema, List<String> listaCartoesSerno) {  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DesbloquearSenhaCartao');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String sernoCartoes = '';
        Integer index = 0;
        for(String id : listaCartoesSerno){
            sernoCartoes +=  '"' + id + '"';
            index++;
            if(listaCartoesSerno.size() > index){
                sernoCartoes +=  ',';
            }
        }
        
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'id_empresa' => idEmpresa,
                'cpf' => cpf,
                'canal' => canal,
                'area' => area,
                'sistema' => sistema,
                'login_operador' => loginOperador,
                'x-uat' => config.UAT__c == null ? ' ' : config.UAT__c
            }, 
            config.Body__c.replace('{listaCartoesSerno}', sernoCartoes), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO ACORDO
        LogIntegracaoBO.InsertLog(
            'Desbloquear Senha Cartão', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c.replace('{listaCartoesSerno}', sernoCartoes), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());
        OutputDesbloquearSenhaCartao toReturn = new OutputDesbloquearSenhaCartao();
        if(status == '200' || status == '204'){
            toReturn.statusAPI = 'OK';
            toReturn.senhaCartaoDesbloqueada = (List<SenhaCartaoDesbloqueada>) System.JSON.deserialize(objHttpResponse.getBody(), List<SenhaCartaoDesbloqueada>.class);
        } else {
            toReturn.statusAPI = 'Erro';
        }

        return toReturn;
    }

    public class OutputListarCartaoDesbloqueioSenha {
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public List<CartoesDesbloqueioSenha> cartoesDesbloqueioSenha;
    }

    public class CartoesDesbloqueioSenha {
        @AuraEnabled
        public String numeroCartaoSerno;
        @AuraEnabled
        public String numeroCartaoOfuscado;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Boolean ehPrimario;
        @AuraEnabled
        public Integer wrongPinRetries;
    }

    public class OutputDesbloquearSenhaCartao {
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public List<SenhaCartaoDesbloqueada> senhaCartaoDesbloqueada;
    }

    public class SenhaCartaoDesbloqueada {
        @AuraEnabled
        public String idSerno;
        @AuraEnabled
        public Boolean sucesso;
    }
      
}