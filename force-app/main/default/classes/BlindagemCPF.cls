public with sharing class BlindagemCPF {

     public static BlindagemTO.RetornoListarClientesBlindados listarClientesBlindados(BlindagemTO.InputFiltroListarCLientes filtro, Integer tamanhoPagina, Integer pagina, String canal){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('BlindagemCPFListarClientesBlindados');

        String endpoint = configApi.Endpoint__c + configApi.Path__c.replace('{tamanhoPagina}', String.valueOf(tamanhoPagina)).replace('{pagina}', String.valueOf(pagina));
        String metodo = configApi.Method__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);

             
        String body = configApi.Body__c 
                        .replace('{tipoFiltro}', String.valueOf(filtro.tipoFiltro))
                        .replace('{valor}', String.valueOf(filtro.valor) );

        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);
        System.debug('response++' + objHttpResponse);
        System.debug('response++' + objHttpResponse.getBody());
        LogIntegracaoBO.InsertLog(
            'Blindagem - Listar Clientes Blindados', 
            endpoint, 
            metodo, 
            body,  
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            null,
            canal.capitalize()
        );

        BlindagemTO.RetornoListarClientesBlindados retornoAPI = new BlindagemTO.RetornoListarClientesBlindados();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (BlindagemTO.RetornoListarClientesBlindados) JSON.deserialize(objHttpResponse.getBody(), BlindagemTO.RetornoListarClientesBlindados.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static BlindagemTO.RetornoClienteBlindado obterClienteBlindado(String cpfCliente, String canal){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('BlindagemCPFObterClienteBlindado');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String metodo = configApi.Method__c;
        String body = configApi.Body__c;
        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
            'Cpf' => cpfCliente,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Blindagem - Obter Cliente Blindado', 
            endpoint, 
            metodo, 
            body,  
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            null,
            canal.capitalize()
        );

        BlindagemTO.RetornoClienteBlindado retornoAPI = new BlindagemTO.RetornoClienteBlindado();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (BlindagemTO.RetornoClienteBlindado) JSON.deserialize(objHttpResponse.getBody(), BlindagemTO.RetornoClienteBlindado.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static BlindagemTO.RetornoCriarClienteBlindado criarClienteBlindado(BlindagemTO.InputCriarClienteBlindado clienteBlindado, String canal){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('BlindagemCPFCriarClienteBlindado');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String metodo = configApi.Method__c;
        String siglaUnidadeNegocio = String.valueOf(clienteBlindado.siglaUnidadeNegocio);

        String body = configApi.Body__c 
                        .replace('{cpf}', clienteBlindado.cpf)
                        .replace('{nome}', clienteBlindado.nome)
                        .replace('{usuario}', clienteBlindado.usuario)
                        .replace('{descricao}', clienteBlindado.descricao)
                        .replace('{fullBlindagem}', String.valueOf(clienteBlindado.fullBlindagem))
                        .replace('{siglaUnidadeNegocio}', String.isBlank(siglaUnidadeNegocio) ? '1' : siglaUnidadeNegocio);

        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Blindagem - Criar Cliente Blindado', 
            endpoint, 
            metodo, 
            body,  
            clienteBlindado.cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            null,
            canal.capitalize()
        );

        BlindagemTO.RetornoCriarClienteBlindado retornoAPI = new BlindagemTO.RetornoCriarClienteBlindado();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (BlindagemTO.RetornoCriarClienteBlindado) JSON.deserialize(objHttpResponse.getBody(), BlindagemTO.RetornoCriarClienteBlindado.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static BlindagemTO.RetornoOperacaoEmMassa criarClientesBlindadosEmMassa(List<BlindagemTO.InputCriarClienteBlindado> clientesBlindados, String canal) {
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('BlindagemCPFCriarClienteBlindadoEmMassa');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String metodo = configApi.Method__c;

        String requestJson = JSON.serialize(clientesBlindados);
        String body = configApi.Body__c.replace('{request}', requestJson);

        Integer timeout = Integer.valueOf(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Blindagem - Criar Clientes Blindados em Massa', 
            endpoint, 
            metodo, 
            body,  
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            null,
            canal.capitalize()
        );

        BlindagemTO.RetornoOperacaoEmMassa retornoAPI = new BlindagemTO.RetornoOperacaoEmMassa();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (BlindagemTO.RetornoOperacaoEmMassa) JSON.deserialize(objHttpResponse.getBody(), BlindagemTO.RetornoOperacaoEmMassa.class);
            retornoAPI.statusAPI = 'OK';
        } else {
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static BlindagemTO.RetornoRemoverBlindagem removerClienteBlindado(BlindagemTO.InputRemoverClienteBlindado clienteBlindado, String canal){
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('BlindagemCPFRemoverClienteBlindado');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String metodo = configApi.Method__c;
        String siglaUnidadeNegocio = String.valueOf(clienteBlindado.siglaUnidadeNegocio);
        
        String body = configApi.Body__c 
                        .replace('{cpf}', clienteBlindado.cpf)
                        .replace('{usuario}', clienteBlindado.usuario)
                        .replace('{siglaUnidadeNegocio}', String.isBlank(siglaUnidadeNegocio) ? '1' : siglaUnidadeNegocio);

        Integer timeout = Integer.valueof(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Blindagem - Remover Cliente Blindado', 
            endpoint, 
            metodo, 
            body,  
            clienteBlindado.cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            null,
            canal.capitalize()
        );

        BlindagemTO.RetornoRemoverBlindagem retornoAPI = new BlindagemTO.RetornoRemoverBlindagem();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (BlindagemTO.RetornoRemoverBlindagem) JSON.deserialize(objHttpResponse.getBody(), BlindagemTO.RetornoRemoverBlindagem.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static BlindagemTO.RetornoOperacaoEmMassa removerClientesBlindadosEmMassa(List<BlindagemTO.InputRemoverClienteBlindado> clientesBlindados, String canal) {
        CarrefourAPICallout__mdt configApi = CarrefourAPICalloutDAO.getInstance().getByLabel('BlindagemCPFRemoverBlindagemEmMassa');

        String endpoint = configApi.Endpoint__c + configApi.Path__c;
        String metodo = configApi.Method__c;

        String requestJson = JSON.serialize(clientesBlindados);
        String body = configApi.Body__c.replace('{request}', requestJson);

        Integer timeout = Integer.valueOf(configApi.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
            'x-uat' => configApi.UAT__c == null ? '' : configApi.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Blindagem - Remover Clientes Blindados em Massa', 
            endpoint, 
            metodo, 
            body,  
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            null,
            canal.capitalize()
        );

        BlindagemTO.RetornoOperacaoEmMassa retornoAPI = new BlindagemTO.RetornoOperacaoEmMassa();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (BlindagemTO.RetornoOperacaoEmMassa) JSON.deserialize(objHttpResponse.getBody(), BlindagemTO.RetornoOperacaoEmMassa.class);
            retornoAPI.statusAPI = 'OK';
        } else {
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }


}