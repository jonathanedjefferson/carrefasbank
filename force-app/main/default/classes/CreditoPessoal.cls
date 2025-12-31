public with sharing class CreditoPessoal {

    public static CreditoPessoalTO.ConsultaContratos consultarContratos(String canal, String cpf, String unidadeNegocio, String numeroConta){

        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalConsultaContratos');

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Consultar Contratos', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        CreditoPessoalTO.ConsultaContratos retornoAPI = new CreditoPessoalTO.ConsultaContratos();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.ConsultaContratos) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.ConsultaContratos.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static CreditoPessoalTO.ConsultaProposta consultarProposta(String canal, String cpf, String unidadeNegocio, Long idProposta){

        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalConsultaProposta');

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{idProposta}', String.valueOf(idProposta));
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Detalhes Proposta', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        CreditoPessoalTO.ConsultaProposta retornoAPI = new CreditoPessoalTO.ConsultaProposta();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.ConsultaProposta) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.ConsultaProposta.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static CreditoPessoalTO.EnvioTermo enviarTermoAdesao(String canal, String cpf, String unidadeNegocio, Long idProposta, String emailCliente){

        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalEnvioTermoAdesao');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String body = configApi.Body__c.replace('{idProposta}', String.valueOf(idProposta)).replace('{email}', emailCliente);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Enviar Termo', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        CreditoPessoalTO.EnvioTermo retornoAPI = new CreditoPessoalTO.EnvioTermo();

        if (objHttpResponse.getStatusCode() == 200 || objHttpResponse.getStatusCode() == 204) {
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static CreditoPessoalTO.ConsultaBancos obterBancos(String canal, String cpf, String unidadeNegocio){

        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalObterBancos');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Obter Bancos', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        CreditoPessoalTO.ConsultaBancos retornoAPI = new CreditoPessoalTO.ConsultaBancos();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.ConsultaBancos) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.ConsultaBancos.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static CreditoPessoalTO.AlteracaoDadosBancarios alterarDadosBancarios(String canal, String cpf, String unidadeNegocio, String numeroConta, Long idProposta, CreditoPessoalTO.DadosBancarios dadosBancarios, CreditoPessoalTO.ContratoRejeitado contratoRejeitado){

        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalAlterarDadosBancarios');

        String dadosBancariosJson = JSON.Serialize(dadosBancarios);
        String contratoRejeitadoJson = JSON.Serialize(contratoRejeitado);

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{numeroConta}', numeroConta).replace('{cpf}', cpf).replace('{idProposta}', String.valueOf(idProposta)).replace('{dadosBancarios}', dadosBancariosJson).replace('{contratoRejeitado}', contratoRejeitadoJson);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Revisar Dados Bancários', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        CreditoPessoalTO.AlteracaoDadosBancarios retornoAPI = new CreditoPessoalTO.AlteracaoDadosBancarios();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.AlteracaoDadosBancarios) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.AlteracaoDadosBancarios.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static CreditoPessoalTO.ConsultaCliente consultarCliente(String canal, String cpf, String unidadeNegocio, String numeroConta){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalConsultaCliente');

        CreditoPessoalTO.ConsultaCliente retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);
        
        LogIntegracaoBO.InsertLog(
            'CP - Consultar Cliente', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.ConsultaCliente();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.ConsultaCliente) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.ConsultaCliente.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.IniciarProposta iniciarProposta(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String valorPreAprovado, String valorSolicitado, String origem, TokenCSFServicos.ResponseToken token){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalIniciarProposta');

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X') ? cpf : userDRT.DRT__c;

        CreditoPessoalTO.IniciarProposta retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{codOperador}', loginOperador)
            .replace('{usuarioOperacao}', loginOperador)
            .replace('{cpf}', cpf)
            .replace('{valorPreAprovado}', valorPreAprovado)
            .replace('{valorSolicitado}', valorSolicitado)
            .replace('{empresa}', unidadeNegocio)
            .replace('{origem}', origem);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Iniciar Proposta', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.IniciarProposta();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.IniciarProposta) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.IniciarProposta.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.ConsultaElegibilidadeCliente consultarElegibilidadeCliente(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String idProposta, TokenCSFServicos.ResponseToken token){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalConsultaElegibilidade');

        CreditoPessoalTO.ConsultaElegibilidadeCliente retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta).replace('{idProposta}', idProposta);
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        String statusCode = String.valueOf(objHttpResponse.getStatusCode());
        

        LogIntegracaoBO.InsertLog(
            'CP - Consulta Elegibilidade', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            statusCode, 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.ConsultaElegibilidadeCliente();

        if (statusCode == '200') {
            retornoAPI = (CreditoPessoalTO.ConsultaElegibilidadeCliente) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.ConsultaElegibilidadeCliente.class);
            retornoAPI.statusAPI = 'OK';
        } else if (statusCode == '412'){
            retornoAPI.statusAPI = 'OK';
            retornoAPI.resultado = false;
        }else {
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.EfetuarSimulacao efetuarSimulacaoInicial(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String idProposta, String valorSolicitado, TokenCSFServicos.ResponseToken token){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalEfetuarSimulacao');

        CreditoPessoalTO.EfetuarSimulacao retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{idProposta}', idProposta).replace('{valorSolicitado}', valorSolicitado);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Efetuar Simulação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.EfetuarSimulacao();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.EfetuarSimulacao) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.EfetuarSimulacao.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.EfetuarSimulacao efetuarSimulacao(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String idProposta, String valorSolicitado){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalEfetuarSimulacao');

        CreditoPessoalTO.EfetuarSimulacao retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{idProposta}', idProposta).replace('{valorSolicitado}', valorSolicitado);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Efetuar Simulação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.EfetuarSimulacao();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.EfetuarSimulacao) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.EfetuarSimulacao.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.SalvarSimulacao salvarSimulacao(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String idProposta, String valorSolicitado, String plano){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalSalvarSimulacao');

        CreditoPessoalTO.SalvarSimulacao retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X') ? cpf : userDRT.DRT__c;

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta).replace('{idProposta}', idProposta);
        String body = configApi.Body__c.replace('{idProposta}', idProposta).replace('{valorSolicitado}', valorSolicitado).replace('{usuarioOperacao}', loginOperador).replace('{plano}', plano);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Salvar Simulação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.SalvarSimulacao();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.SalvarSimulacao) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.SalvarSimulacao.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.ValidarDadosBancarios validarDadosBancarios(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String dadosBancarios, TokenCSFServicos.ResponseToken token){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalValidarDadosBancarios');

        CreditoPessoalTO.ValidarDadosBancarios retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{dadosBancarios}', dadosBancarios);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Validar Dados Bancários', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.ValidarDadosBancarios();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.ValidarDadosBancarios) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.ValidarDadosBancarios.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.SalvarDadosBancarios salvarDadosBancarios(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String idProposta, String dadosBancarios, TokenCSFServicos.ResponseToken token){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalSalvarDadosBancarios');

        CreditoPessoalTO.SalvarDadosBancarios retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X') ? cpf : userDRT.DRT__c;

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta).replace('{idProposta}', idProposta);
        String body = configApi.Body__c.replace('{idProposta}', idProposta)
            .replace('{dadosBancarios}', dadosBancarios)
            .replace('{usuarioOperacao}', loginOperador);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Salvar Dados Bancários', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.SalvarDadosBancarios();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.SalvarDadosBancarios) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.SalvarDadosBancarios.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.Contratacao contratacao(String canal, String cpf, String unidadeNegocio, String numeroConta,
        String idProposta, String plano, String dadosBancarios, String origemAdesao){
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('CreditoPessoalContratacao');

        CreditoPessoalTO.Contratacao retornoAPI = null;
        if(configApi == null){
            return retornoAPI;
        }

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{idProposta}', idProposta)
            .replace('{origemAdesao}', origemAdesao)
            .replace('{plano}', plano).replace('{dadosBancarios}', dadosBancarios);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'id_empresa' => unidadeNegocio,
            'channel' => canal
        };

        if (configApi.UAT__c != null) {
            header.put('x-uat', configApi.UAT__c);
        }

        HttpResponse objHttpResponse =  Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'CP - Contratação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        retornoAPI = new CreditoPessoalTO.Contratacao();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (CreditoPessoalTO.Contratacao) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.Contratacao.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static CreditoPessoalTO.Cancelamento cancelamento(String idProposta, String cpf, String unidadeNegocio, String canal) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CancelarCreditoPessoal');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{idProposta}', idProposta), 
            config.Method__c,
            new Map<String, String> {
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'id_empresa' => unidadeNegocio,
                'channel' => canal,
                'Authorization' => 'Bearer '+ TokenCSFServicos.getToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'CP - Cancelamento', 
            config.Endpoint__c + config.Path__c.replace('{idProposta}', idProposta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal
        );   

        CreditoPessoalTO.Cancelamento output = new CreditoPessoalTO.Cancelamento();
        output = (CreditoPessoalTO.Cancelamento) JSON.deserialize(objHttpResponse.getBody(), CreditoPessoalTO.Cancelamento.class);
        output.statusAPI =  String.valueOf(objHttpResponse.getStatusCode());
        return output;
    }

}