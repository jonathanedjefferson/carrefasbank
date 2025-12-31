public class CartaoPrimario {

    public static Boolean DefinirCartaoPrimario(String numeroConta, String numeroCartaoSerno, String cpf, String idEmpresa, String area, String canal, String sistema){

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DefinirCartaoPrimario');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        //PEGANDO METADADO CUSTOM organizationType
        organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');

        user userDRT = UserDAO.getInstance().getUserDRT(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        String path = config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + path, 
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
                'x-uat' => UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : ''

            }, 
            '', 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Definir Cartão Primário', 
            config.Endpoint__c + path, 
            config.Method__c, 
            '', 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if('200'.equals(status) || '204'.equals(status)){
            return true;
        }
        return false;   
    }

    public static OutputListaCartoes ObterDataEmissaoCartoes(String numeroConta, String listaCartaoSerno, String cpf, String idEmpresa, String area, String canal, String sistema){

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarDataEmissaoCartao');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        //PEGANDO METADADO CUSTOM organizationType
        organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');

        user userDRT = UserDAO.getInstance().getUserDRT(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        String path = config.Path__c.replace('{numeroConta}', numeroConta);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + path, 
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
                'x-uat' => UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : ''
            }, 
            config.Body__c.replace('{listaCartaoSerno}', listaCartaoSerno), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar data de emissão cartão', 
            config.Endpoint__c + path, 
            config.Method__c, 
            config.Body__c.replace('{listaCartaoSerno}', listaCartaoSerno),
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        String status = String.valueOf(objHttpResponse.getStatusCode());

        OutputListaCartoes output;
        if('200'.equals(status)){
            output = new OutputListaCartoes();
            output.statusAPI = 'OK';
            output.cartoes = (List<Cartao>) System.JSON.deserialize(objHttpResponse.getBody(), List<Cartao>.class);
        } else {
            output = new OutputListaCartoes();
            output.statusAPI = 'ERRO';
        }

        return output;
    }

    public class OutputListaCartoes {
        @AuraEnabled
        public List<Cartao> cartoes;
        @AuraEnabled
        public String statusAPI;
    }

    public class Cartao {
        @AuraEnabled
        public String idSerno;
        @AuraEnabled
        public DateTime dataCriacao;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Boolean ehPrimario;
    }

}