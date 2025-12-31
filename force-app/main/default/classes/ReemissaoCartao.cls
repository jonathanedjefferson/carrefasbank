public class ReemissaoCartao {
    public static ReemitirCartaoOutput ReemitirCartao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno, String novoStatus){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ReemitirCartao');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.split(',')[0].replace('{NovoStatus}', novoStatus) + '\n}', 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Reemitir Cartão', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
            config.Method__c, 
            config.Body__c.split(',')[0].replace('{NovoStatus}', novoStatus) + '\n}', 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        System.debug(objHttpResponse.getBody());
        String status = String.valueOf(objHttpResponse.getStatusCode());
        ReemitirCartaoOutput retorno = new ReemitirCartaoOutput();
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusCode = status;
            retorno.StatusAPI = true;
            return retorno;
        }else if(status == '403' || status == '422'){
            retorno = (ReemitirCartaoOutput) System.JSON.deserialize(objHttpResponse.getBody(), ReemitirCartaoOutput.class);
        }        
        retorno.StatusAPI = false;
        retorno.statusCode = status;
        retorno.message = retorno.message != null ? retorno.message : retorno.mensagem;
        
        return retorno;
    }
 
    public static ReemitirCartaoOutput ReemitirCartaoComAlteracaoNomeReduzido(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno, String novoStatus, String nomeReduzido){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ReemitirCartao');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{NovoStatus}', novoStatus).replace('{nomeReduzido}', nomeReduzido), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Reemitir Cartão Com Alteração de Nome Reduzido', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{numeroCartaoSerno}', numeroCartaoSerno), 
            config.Method__c, 
            config.Body__c.replace('{NovoStatus}', novoStatus).replace('{nomeReduzido}', nomeReduzido), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        System.debug(objHttpResponse.getBody());
        String status = String.valueOf(objHttpResponse.getStatusCode());
        ReemitirCartaoOutput retorno = new ReemitirCartaoOutput();
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusCode = status;
            retorno.StatusAPI = true;
            return retorno;
        }else if(status == '403' || status == '422'){
            retorno = (ReemitirCartaoOutput) System.JSON.deserialize(objHttpResponse.getBody(), ReemitirCartaoOutput.class);
        }        
        retorno.StatusAPI = false;
        retorno.statusCode = status;
        retorno.message = retorno.message != null ? retorno.message : retorno.mensagem;
        
        return retorno;
    }

    public static OutputListCartoesParaReemissao ListCartoesParaReemissao(String canal, String area, String cpf, String numeroConta, String idEmpresa) {
        OutputListCartoesParaReemissao output = new OutputListCartoesParaReemissao();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListCartoesParaReemissao');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Cartões para Reemissao', 
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
            output = (OutputListCartoesParaReemissao) System.JSON.deserialize(objHttpResponse.getBody(), OutputListCartoesParaReemissao.class); 
            output.StatusAPI = 'OK';
        return output;
        }
        output.StatusAPI = 'ERROR';
        return output;
    }

    
    public static OutputStatusReemissaoRastreio ListRastreioCartaoReemitido(String canal, String area, String cpf , String idEmpresa, String numeroConta){
        OutputStatusReemissaoRastreio output = new OutputStatusReemissaoRastreio();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListRastreioCartaoReemitido');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}',numeroConta),
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
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
            'Listar Rastreio Reemissao de Cartão', 
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
        if(status == '200' || status == '204'){
            output = (OutputStatusReemissaoRastreio) System.JSON.deserialize(objHttpResponse.getBody(), OutputStatusReemissaoRastreio.class); 
            output.StatusAPI = 'OK';
        } else {
            output.StatusAPI = 'ERROR';
        }
        
        return output;
    }
   
    // RESPONSE REFERENTE AO MÉTODO 'ReemitirCartao'
    public class ReemitirCartaoOutput {
        @AuraEnabled
        public String statusCode;  
        @AuraEnabled
        public String message;  // Mensagens de ERRO
        @AuraEnabled
        public String mensagem;  
        @AuraEnabled  
        public Boolean StatusAPI;
    }

    // RESPONSE REFERENTE AO MÉTODO 'ListStatusReemissaoCartao'
    public class OutputListCartoesParaReemissao {
        @AuraEnabled
        public List<CartoesElegiveis> cartoesElegiveis;
        @AuraEnabled
        public List<Status> status;   
        @AuraEnabled  
        public String StatusAPI;
    }
   
    public class Status {
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String descricao;
    }

    public class CartoesElegiveis {
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
        public String numeroCartaoCompleto;
        @AuraEnabled 
        public Boolean precisaAlterarStatus;
    }
    
    // RESPONSE REFERENTE AO MÉTODO 'ListRastreioCartaoReemitido'
    public class OutputStatusReemissaoRastreio {
        @AuraEnabled
        public List<PostagemResponse> postagemResponse;
        @AuraEnabled  
        public String StatusAPI;
    }

	public class PostagemResponse {
        @AuraEnabled
		public String numeroCartao;
        @AuraEnabled
		public String codigoRastreio;
        @AuraEnabled
		public String urlRastreio;
        @AuraEnabled
		public String nomeTitular;
        @AuraEnabled
		public String dataCriacaoCartao;
	}
}