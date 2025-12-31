public class GestaoLimite {

    public static ResponseConsultarLimite consultarLimite(RequestConsultarLimite request){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(request.canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('GestaoLimiteConsulta');

        ResponseConsultarLimite retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String body = configApi.Body__c.replace('{numeroConta}', request.numeroConta).replace('{cpf}', request.cpf).replace('{pagina}', request.pagina);
        body = body.replace('{itensPorPagina}', request.itensPorPagina).replace('{idEmpresa}', request.unidadeNegocio);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        header.put('Authorization', 'token');
        LogIntegracaoBO.InsertLogIntegracao(
            'Gestão de limite - Consulta', 
            endpoint, 
            metodo, 
            body,   
            request.cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            request.unidadeNegocio,
            request.canal?.capitalize(),
            String.valueOf(header)
        );

        retornoAPI = new ResponseConsultarLimite();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (ResponseConsultarLimite) JSON.deserialize(objHttpResponse.getBody(), ResponseConsultarLimite.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static ResponseAlterarLimite aumentarLimite(RequestAlterarLimite request){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(request.canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('GestaoLimiteAumento');

        ResponseAlterarLimite retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X') ? request.cpf : userDRT.DRT__c;

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String body = configApi.Body__c.replace('{numeroConta}', request.numeroConta).replace('{cpf}', request.cpf).replace('{valorLimiteSolicitado}', request.valorLimiteSolicitado);
        body = body.replace('{valorRendaComprovada}', request.valorRendaComprovada).replace('{idEmpresa}', request.unidadeNegocio).replace('{drtOperador}', loginOperador);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        header.put('Authorization', 'token');
        LogIntegracaoBO.InsertLogIntegracao(
            'Gestão de limite - Aumento', 
            endpoint, 
            metodo, 
            body,   
            request.cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            request.unidadeNegocio,
            request.canal?.capitalize(),
            String.valueOf(header)
        );

        retornoAPI = new ResponseAlterarLimite();

        if (objHttpResponse.getStatusCode() == 200) {
             retornoAPI = (ResponseAlterarLimite) JSON.deserialize(objHttpResponse.getBody(), ResponseAlterarLimite.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static ResponseAlterarLimite reduzirLimite(RequestAlterarLimite request){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(request.canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('GestaoLimiteReducao');

        ResponseAlterarLimite retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X') ? request.cpf : userDRT.DRT__c;

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String body = configApi.Body__c.replace('{numeroConta}', request.numeroConta).replace('{cpf}', request.cpf).replace('{valorLimiteSolicitado}', request.valorLimiteSolicitado);
        body = body.replace('{valorRendaComprovada}', request.valorRendaComprovada).replace('{idEmpresa}', request.unidadeNegocio).replace('{drtOperador}', loginOperador);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        header.put('Authorization', 'token');
        LogIntegracaoBO.InsertLogIntegracao(
            'Gestão de limite - Redução', 
            endpoint, 
            metodo, 
            body,   
            request.cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            request.unidadeNegocio,
            request.canal?.capitalize(),
            String.valueOf(header)
        );

        retornoAPI = new ResponseAlterarLimite();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (ResponseAlterarLimite) JSON.deserialize(objHttpResponse.getBody(), ResponseAlterarLimite.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }


    public class RequestConsultarLimite {
        @AuraEnabled
        public String numeroConta;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String itensPorPagina;
        @AuraEnabled
        public String pagina;
        @AuraEnabled
        public String unidadeNegocio;
        @AuraEnabled
        public String canal;
    }

    public class ResponseConsultarLimite{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Integer itensPorPagina;
        @AuraEnabled 
        public Integer paginaAtual;
        @AuraEnabled 
        public Integer totalPaginas;
        @AuraEnabled 
        public Integer totalRegistros;
        @AuraEnabled 
        public List<SolicitacaoLimite> retornoSolicitacaoAumentoLimiteCockpit;
    }

    public class SolicitacaoLimite{
        @AuraEnabled 
        public String data;
        @AuraEnabled 
        public Integer status;
        @AuraEnabled 
        public Integer limiteAtual;
        @AuraEnabled 
        public Integer limiteSolicitado;
        @AuraEnabled 
        public Integer limiteConcedido;
        @AuraEnabled 
        public String codigoLoja;
        @AuraEnabled 
        public String atendente;
    }

    public class RequestAlterarLimite {
        @AuraEnabled
        public String numeroConta;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String valorLimiteSolicitado;
        @AuraEnabled
        public String valorRendaComprovada;
        @AuraEnabled
        public String unidadeNegocio;
        @AuraEnabled
        public String canal;
    }

    public class ResponseAlterarLimite{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public String status;
        @AuraEnabled 
        public String statusDescricao;
        @AuraEnabled 
        public String protocolo;
        @AuraEnabled 
        public String dataSolicitacao;
    }
}