public class AntecipacaoParcelas {

    public static AntecipacaoParcelasTO.RetornoListarParcelamentos listarParcelamentos(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, Boolean incluirParcelas, String categoria, String periodoInicial, String periodoFinal){

        TokenAntecipacao.ResponseToken token = TokenAntecipacao.obterToken(canal, cpf, cpfDrtOperador, perfilOperador);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('ListarParcelamentos');

        List<String> parametros = new List<String>();

        if (incluirParcelas != null) parametros.add('incluirParcelas=' + String.valueOf(incluirParcelas));
        if (String.isNotEmpty(categoria)) parametros.add('categoria=' + categoria);
        if (String.isNotEmpty(periodoInicial)) parametros.add('periodoInicial=' + periodoInicial);
        if (String.isNotEmpty(periodoFinal)) parametros.add('periodoFinal=' + periodoFinal);

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        if(!parametros.isEmpty()) endpoint += '?' + String.join(parametros, '&');
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Listar Parcelamentos', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        AntecipacaoParcelasTO.RetornoListarParcelamentos retornoAPI = new AntecipacaoParcelasTO.RetornoListarParcelamentos();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (AntecipacaoParcelasTO.RetornoListarParcelamentos) JSON.deserialize(objHttpResponse.getBody(), AntecipacaoParcelasTO.RetornoListarParcelamentos.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static AntecipacaoParcelasTO.RetornoObterParcelamento obterParcelamento(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String idParcelamento){

        TokenAntecipacao.ResponseToken token = TokenAntecipacao.obterToken(canal, cpf, cpfDrtOperador, perfilOperador);
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterParcelamento');

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta).replace('{idParcelamento}', idParcelamento);
        String body = configApi.Body__c;
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Obter Parcelamentos', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        AntecipacaoParcelasTO.RetornoObterParcelamento retornoAPI = new AntecipacaoParcelasTO.RetornoObterParcelamento();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (AntecipacaoParcelasTO.RetornoObterParcelamento) JSON.deserialize(objHttpResponse.getBody(), AntecipacaoParcelasTO.RetornoObterParcelamento.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;

    }

    public static AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla simularAntecipacoes(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, List<AntecipacaoParcelasTO.SimulacaoParcelamentoBody> parcelamentos){
        TokenAntecipacao.ResponseToken token = TokenAntecipacao.obterToken(canal, cpf, cpfDrtOperador, perfilOperador);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('SimularAntecipacaoParcelas');


        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{listaParcelamentos}', JSON.serialize(parcelamentos));
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Simular Antecipação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla retornoAPI = new AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla();

        if(objHttpResponse.getBody() != null && objHttpResponse.getBody().trim().length() > 0){
            retornoAPI = (AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla) JSON.deserialize(objHttpResponse.getBody(), AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla.class);
        }

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI.statusAPI = 'OK';
        }else if(objHttpResponse.getStatusCode() == 422){
            retornoAPI.statusAPI = 'ERRO_TRATADO';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static AntecipacaoParcelasTO.RetornoAntecipacao anteciparParcelas(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, List<AntecipacaoParcelasTO.AntecipacaoParcelamentoBody> parcelamentos, String tipoPagamento, Boolean incluirPdfBoleto){
        TokenAntecipacao.ResponseToken token = TokenAntecipacao.obterToken(canal, cpf, cpfDrtOperador, perfilOperador);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('AnteciparParcelas');

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{tipoPagamento}', tipoPagamento).replace('{incluirPdfBoleto}', String.valueOf(incluirPdfBoleto)).replace('{listaParcelamentos}', JSON.serialize(parcelamentos));
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        String responseBody =  objHttpResponse.getBody();

        try {
            responseBody =  responseBody != null && responseBody.trim().length() > 0 ? responseBody.replaceAll('"pdf"\\s*:\\s*".*?"', '"pdf": "**base64 do pdf removido do log**"') : '';
        } catch (Exception e) {
            System.debug('Erro ao remover o campo pdf: ' + e.getMessage());
        }

        LogIntegracaoBO.InsertLog(
            'Antecipar Parcelas', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            responseBody, 
            unidadeNegocio,
            canal.capitalize()
        );

        AntecipacaoParcelasTO.RetornoAntecipacao retornoAPI = new AntecipacaoParcelasTO.RetornoAntecipacao();
        

        if(objHttpResponse.getBody() != null && objHttpResponse.getBody().trim().length() > 0){
            retornoAPI = (AntecipacaoParcelasTO.RetornoAntecipacao) JSON.deserialize(objHttpResponse.getBody(), AntecipacaoParcelasTO.RetornoAntecipacao.class);
        }

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI.statusAPI = 'OK';
        }else if(objHttpResponse.getStatusCode() == 422){
            retornoAPI.statusAPI = 'ERRO_TRATADO';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static AntecipacaoParcelasTO.RetornoPagamentoAvulso obterDadosPagamentoAvulso(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String antecipacaoId, String tipoPagamento, Decimal valor, Boolean incluirPdfBoleto){
        TokenAntecipacao.ResponseToken token = TokenAntecipacao.obterToken(canal, cpf, cpfDrtOperador, perfilOperador);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('PagamentoAvulsoAntecipacao');

        

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{valor}', String.valueOf(valor)).replace('{tipoPagamento}', tipoPagamento).replace('{antecipacaoId}', antecipacaoId).replace('{incluirPdfBoleto}', String.valueOf(incluirPdfBoleto));
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        String responseBody =  objHttpResponse.getBody();

        try {
            responseBody =  responseBody != null && responseBody.trim().length() > 0 ? responseBody.replaceAll('"pdf"\\s*:\\s*".*?"', '"pdf": "**base64 do pdf removido do log**"') : '';
        } catch (Exception e) {
            System.debug('Erro ao remover o campo pdf: ' + e.getMessage());
        }

        LogIntegracaoBO.InsertLog(
            'Pagamento Avulso Antecipação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            responseBody, 
            unidadeNegocio,
            canal.capitalize()
        );

        AntecipacaoParcelasTO.RetornoPagamentoAvulso retornoAPI = new AntecipacaoParcelasTO.RetornoPagamentoAvulso();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (AntecipacaoParcelasTO.RetornoPagamentoAvulso) JSON.deserialize(objHttpResponse.getBody(), AntecipacaoParcelasTO.RetornoPagamentoAvulso.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static AntecipacaoParcelasTO.RetornoEnvioEmail enviarEmailAlternativo(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String antecipacaoMultiplaId, String  emailDestinatario, String tipoPagamento){
        TokenAntecipacao.ResponseToken token = TokenAntecipacao.obterToken(canal, cpf, cpfDrtOperador, perfilOperador);

        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('SegundaViaAntecipacaoEmail');

        
        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{numeroConta}', numeroConta);
        String body = configApi.Body__c.replace('{antecipacaoMultiplaId}', antecipacaoMultiplaId).replace('{email}', emailDestinatario).replace('{tipoPagamento}', tipoPagamento);
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Envio de Email Antecipação', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        AntecipacaoParcelasTO.RetornoEnvioEmail retornoAPI = new AntecipacaoParcelasTO.RetornoEnvioEmail();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

}