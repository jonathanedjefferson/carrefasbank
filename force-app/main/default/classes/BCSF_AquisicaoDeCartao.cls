public class BCSF_AquisicaoDeCartao {
    //#region   Iniciar Chat
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper iniciarChat(Integer idEmpresa, String numeroTelefone, String canal, String cpf) {
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IniciarchatBuscaProposta');
        String endpoint = config.Endpoint__c + config.Path__c;
        
        String body = config.Body__c.replace('{telefone}', numeroTelefone);
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            body,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Iniciar Chat',
            endpoint,
            config.Method__c,
            body,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            resp.message = 'Busca realizada';
            resp.statusCode = objHttpResponse.getStatusCode();
            
            BCSF_AquisicaoDeCartaoTO.iniciarChatResponseWrapper bodyObj =
                (BCSF_AquisicaoDeCartaoTO.iniciarChatResponseWrapper) JSON.deserialize(
                objHttpResponse.getBody(),
                BCSF_AquisicaoDeCartaoTO.iniciarChatResponseWrapper.class
            );
            
            resp.body = bodyObj;
        } else {
            resp.message = 'Falha ao buscar dados';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        
        return resp;
    }
    //#endregion
    // #region  Atualizar Dados Contato
    public static  BCSF_AquisicaoDeCartaoTO.responseWrapper atualizarDadosContato(
        String idProposta,
        Integer idEmpresa,
        Boolean optinWhatsapp,
        String email,
        String canal,
        String cpf
    ) {
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AtualizarDadosDeContato');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        BCSF_AquisicaoDeCartaoTO.atualizarDadosContatoBody requestBody = new BCSF_AquisicaoDeCartaoTO.atualizarDadosContatoBody();
        requestBody.email = String.valueOf(email);
        requestBody.optinWhatsapp = optinWhatsapp;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Atualizar Dados Contato',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Contato atualizado';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Falha ao atualizar dados de contato';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
    //#endregion
    // #region  Atualizar Dados Pessoais
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper atualizarDadosPessoais(
        String nome,
        String genero,
        String dataNascimento,
        String nomeMae,
        Boolean pep,
        String idProposta,
        Integer idEmpresa,
        String canal,
        String cpf
    ) {
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AtualizarDadosPessoais');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        BCSF_AquisicaoDeCartaoTO.atualizarDadosPessoaisBody requestBody = new BCSF_AquisicaoDeCartaoTO.atualizarDadosPessoaisBody();
        requestBody.nome = nome;
        requestBody.genero = genero;
        requestBody.dataNascimento = dataNascimento;
        requestBody.nomeMae = nomeMae;
        requestBody.pep = pep;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Atualizar Dados Pessoais',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Dados pessoais atualizados';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Falha ao atualizar dados pessoais';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        return resp;
    }
    //#endregion
    // #region  Buscar modelos contratação
    public static BCSF_AquisicaoDeCartaoTO.listResponseWrapper buscarModelosContratacao(Integer idEmpresa, String canal, String cpf) {
        
        List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper> respList = new List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper>();
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BuscarModelosDeContratacao');
        String endpoint = config.Endpoint__c + config.Path__c;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Busca modelos contratação',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        BCSF_AquisicaoDeCartaoTO.listResponseWrapper resp = new BCSF_AquisicaoDeCartaoTO.listResponseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            respList = (List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper>)
                JSON.deserialize(
                objHttpResponse.getBody(),
                List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper>.class
            );
            resp.message = 'Busca realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = respList;
        } else {
            resp.message = 'Falha ao buscar modelos de contratação';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = respList;
        }
        
        return resp;
    }
    //#endregion
    //#region  Buscar Profissoes
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper buscarProfissoes(
        String canal,
        Integer idEmpresa,
        Integer idOcupacao,
        Integer idCategoria,
        Integer pagina,
        Integer quantidade,
        String cpf
    ) {
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BuscarProfissao');
        
        String endpoint = config.Endpoint__c + config.Path__c +
            '?idOcupacao=' + String.valueOf(idOcupacao) +
            '&pagina=' + String.valueOf(pagina) +
            (quantidade != null ? '&quantidade=' + String.valueOf(quantidade) : '') +
            (idCategoria != null ? '&idCategoria=' + String.valueOf(idCategoria) : '');
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Buscar profissoes',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper profissaoResp =
                (BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper.class);
            resp.message = 'Busca realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = profissaoResp;
        } else {
            resp.message = 'Falha ao buscar Profissao';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }
        
        return resp;
    }
    //#endregion
    //#region  Buscar Categorias
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper buscarCategorias(
        String canal,
        Integer idEmpresa,
        Integer idOcupacao,
        Integer pagina,
        Integer quantidade,
        String cpf
    ) {
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BuscarCategorias');
        
        String endpoint = config.Endpoint__c + config.Path__c +
            '?idOcupacao=' + idOcupacao +
            '&pagina=' + pagina +
            (quantidade != null ? '&quantidade=' + quantidade : '');
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Buscar Categorias',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            BCSF_AquisicaoDeCartaoTO.buscarCategoriasResponseWrapper categoriaResp =
                (BCSF_AquisicaoDeCartaoTO.buscarCategoriasResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.buscarCategoriasResponseWrapper.class);
            
            resp.message = 'Busca realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = categoriaResp;
        } else {
            resp.message = 'Falha ao buscar categorias';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }
        
        return resp;
    }
    //#endregion
    //#region  Atualizar dados profissionais
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper atualizarDadosProfissionais(
        Decimal idProfissao,
        Decimal idOcupacao,
        String cnpjEmpresa,
        String idProposta,
        Integer idEmpresa,
        String canal,
        String cpf
    ) {
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AtualizarDadosProfissionais');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        
        Integer idOcupacaoInt = idOcupacao.intValue();
        Integer idProfissaoInt = idProfissao.intValue();

        BCSF_AquisicaoDeCartaoTO.atualizarDadosProfissionaisBody requestBody = new BCSF_AquisicaoDeCartaoTO.atualizarDadosProfissionaisBody();
        if(String.isNotBlank(cnpjEmpresa)){
            requestBody.cnpjEmpresa = cnpjEmpresa;
        }
        requestBody.idOcupacao = idOcupacaoInt;
        requestBody.idProfissao = idProfissaoInt;
        
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Atualizar Dados Profissionais',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Dados profissionais atualizados com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Falha ao atualizar dados profissionais';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
    
    //#endregion
    //#region  Buscar endereco por CEP
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper buscarEnderecoPorCEP(Integer idEmpresa,String cep, String canal, String cpf){
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BuscarEnderecoPorCEP');
        
        String endpoint = config.Endpoint__c + config.Path__c +(cep != null ? '?cep=' + cep : '');
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Buscar endereço por CEP',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            BCSF_AquisicaoDeCartaoTO.buscarEnderecoPorCEPResponseWrapper profissaoResp =
                (BCSF_AquisicaoDeCartaoTO.buscarEnderecoPorCEPResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.buscarEnderecoPorCEPResponseWrapper.class);
            
            resp.message = 'Busca realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = profissaoResp;
        } else {
            resp.message = 'Falha ao buscar cep';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
    //#endregion
    //#region  Buscar endereco por CEP
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper atualizarDadosDeEndereco(
        String cep,
        String logradouro,
        String bairro,
        String cidade,
        String estado,
        String numero,
        String complemento,
        Integer idEmpresa,
        String idProposta,
        String canal, 
        String cpf
    ){
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AtualizarDadosDeEndereco');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        BCSF_AquisicaoDeCartaoTO.Endereco requestBody = new BCSF_AquisicaoDeCartaoTO.Endereco();
        
        requestBody.cep = cep;
        requestBody.logradouro = logradouro;
        requestBody.bairro = bairro;
        requestBody.cidade = cidade;
        requestBody.estado = estado;
        requestBody.numero = numero;
        requestBody.complemento = complemento;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
        endpoint,
        config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Atualizar Dados Endereço',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Endereço atualizado';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Falha ao atualizar dados de endereço';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
        
    }
    //#endregion
    //#region  Iniciar Autenticacao Por Biometria
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper iniciarAutenticacaoPorBiometria(String idProposta, Integer idEmpresa, String canal, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IniciarAutenticacaoPorBiometria');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        String response ;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Iniciar autenticação Por Biometria',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            
            BCSF_AquisicaoDeCartaoTO.iniciarAutenticacaoPorBiometriaResponseWrapper autenticacaoResp =
                (BCSF_AquisicaoDeCartaoTO.iniciarAutenticacaoPorBiometriaResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.iniciarAutenticacaoPorBiometriaResponseWrapper.class);
            
            resp.message = 'biometria iniciada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = autenticacaoResp;
        } else if(objHttpResponse.getStatusCode() == 204) {
            resp.message = 'biometria iniciada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }else {
            resp.message = 'Falha na biometria';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }
        
        return resp;
    }
    //#endregion
    //#region  Validar Autenticacao Por Biometria
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper validarAutenticacaoPorBiometria(String idProposta, Integer idEmpresa, String canal, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ValidarAutenticacaoPorBiometria');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Validar biometria',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            BCSF_AquisicaoDeCartaoTO.validarAutenticacaoPorBiometriaResponseWrapper autenticacaoResp =
                (BCSF_AquisicaoDeCartaoTO.validarAutenticacaoPorBiometriaResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.validarAutenticacaoPorBiometriaResponseWrapper.class);
            resp.message = 'biometria validada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = autenticacaoResp;
        } else if(objHttpResponse.getStatusCode() == 204) {
            resp.message = 'biometria validada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }else {
            resp.message = 'Falha na validação da biometria';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }
        
        return resp;
    }
    //#endregion
    //#region  Buscar dias de vencimento
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper buscarDiasDeVencimento(Integer idEmpresa, String canal, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BuscarDiasDeVencimento');
        String endpoint = config.Endpoint__c + config.Path__c;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Buscar Dias De Vencimento',
            endpoint,
            config.Method__c,
            null,
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            BCSF_AquisicaoDeCartaoTO.buscarDiasDeVencimentoResponseWrapper respList =
                (BCSF_AquisicaoDeCartaoTO.buscarDiasDeVencimentoResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.buscarDiasDeVencimentoResponseWrapper.class);
            
            resp.message = 'Busca realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = respList;
        } else {
            resp.message = 'Falha ao buscar modelos de contratação';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = '';
        }
        
        return resp;
    }
    //#endregion
    //#region  Efetuar configuração Do Cartão
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper efetuarConfiguracaoDoCartao(
        String idProposta,
        Integer idEmpresa,
        String canal,
        Boolean optinAumentoLimite,
        Boolean optinOverlimit,
        String diaVencimento,
        String cpf
    ){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('EfetuarConfiguracaoDoCartao');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoBody requestBody = new BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoBody();
        requestBody.optinAumentoLimite = optinAumentoLimite;
        requestBody.optinOverlimit = optinOverlimit;
        requestBody.diaVencimento = Integer.valueOf(diaVencimento);
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );

        String returnBody =  String.valueOf(objHttpResponse.getBody());
        if(String.isNotBlank(returnBody)){
            Integer indexTermoAdesao = returnBody.indexOf('"termo"');
            if(indexTermoAdesao > 0){
                returnBody = returnBody.substring(0, indexTermoAdesao);
                returnBody += '"termo": "base64…"}';
            }
        }

        LogIntegracaoBO.InsertLog(
            'Efetuar Configuração Do Cartão',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            returnBody,
            null,
            canal.capitalize()
        );

        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 200) {
            BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoResponseWrapper respConfiguracao =
                (BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoResponseWrapper)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoResponseWrapper.class);
            resp.message = 'Configuração realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = respConfiguracao;
        } else {
            resp.message = 'Falha na configuração';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
    //#endregion
    //#region  Aceite da oferta
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper aceiteDaOferta(String idProposta, Integer idEmpresa, String canal, Boolean aceita, String cpf){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AceiteDaOferta');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        BCSF_AquisicaoDeCartaoTO.aceiteDaOfertaBody requestBody = new BCSF_AquisicaoDeCartaoTO.aceiteDaOfertaBody();
        requestBody.aceita = aceita;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Aceite Da Oferta',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Operação realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Problema ao realizar operação';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
    //#endregion
    //#region  Abandono de proposta
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper abandonoDeProposta(String idProposta, Integer idEmpresa, String canal, String motivo, String cpf){
        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AbandonoDeProposta');
        String path = config.Path__c.replace('{idProposta}', idProposta);
        String endpoint = config.Endpoint__c + path;
        
        BCSF_AquisicaoDeCartaoTO.abandonoDePropostaBody requestBody = new BCSF_AquisicaoDeCartaoTO.abandonoDePropostaBody();
        requestBody.motivo = motivo;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Abandono De Proposta',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Operação realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Problema ao realizar operação';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
    //#endregion
    //#region  Desistencia de cadastro de proposta
    public static BCSF_AquisicaoDeCartaoTO.responseWrapper desistenciaDeCadastroDeProposta(Integer idEmpresa, String canal, String motivo, String cpf){
        String response;
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DesistenciaDeCadastroDeProposta');
        String endpoint = config.Endpoint__c + config.Path__c;
        
        BCSF_AquisicaoDeCartaoTO.desistenciaDeCadastroDePropostaBody requestBody = new BCSF_AquisicaoDeCartaoTO.desistenciaDeCadastroDePropostaBody();
        requestBody.motivo = motivo;
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenAquisicao(canal, cpf).access_token,
                'idEmpresa' => String.valueOf(idEmpresa)
            },
            JSON.serialize(requestBody),
            Integer.valueOf(config.Timeout__c)
        );
        
        LogIntegracaoBO.InsertLog(
            'Desistencia De Cadastro De Proposta',
            endpoint,
            config.Method__c,
            JSON.serialize(requestBody),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        BCSF_AquisicaoDeCartaoTO.responseWrapper resp = new BCSF_AquisicaoDeCartaoTO.responseWrapper();
        
        if (objHttpResponse.getStatusCode() == 204) {
            resp.message = 'Operação realizada com sucesso';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        } else {
            resp.message = 'Problema ao realizar operação';
            resp.statusCode = objHttpResponse.getStatusCode();
            resp.body = objHttpResponse.getBody();
        }
        
        return resp;
    }
}