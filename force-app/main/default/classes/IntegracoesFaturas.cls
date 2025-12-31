public class IntegracoesFaturas {
    public static List<OutputUltimosVencimentosFechados> UltimosVencimentosFechados(String numeroConta, String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('UltimosVencimentosFechados');
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
                'id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Últimos Vencimentos Fechados', 
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
            return (List<OutputUltimosVencimentosFechados>) JSON.deserialize(objHttpResponse.getBody(), List<OutputUltimosVencimentosFechados>.class);
        }

        List<OutputUltimosVencimentosFechados> listRetorno = new List<OutputUltimosVencimentosFechados>();
        OutputUltimosVencimentosFechados outp = new OutputUltimosVencimentosFechados();
        outp.StatusOK = status == '422' ? 'SEM FATURAS' : 'ERROR';
        listRetorno.add(outp);
        return listRetorno;
    }

    public static OutputDadosPagamentoFaturaFechada DadosPagamentoFaturaFechada(String numeroConta, String idEmpresa, String cpf, String mesAnoVencimento, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DadosPagamentoFaturaFechada');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{mesAnoVencimentoFatura}', mesAnoVencimento), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Dados de Pagamento de Fatura Fechada', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{mesAnoVencimentoFatura}', mesAnoVencimento), 
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
            return (OutputDadosPagamentoFaturaFechada) JSON.deserialize(objHttpResponse.getBody(), OutputDadosPagamentoFaturaFechada.class);
        }

        OutputDadosPagamentoFaturaFechada outp = new OutputDadosPagamentoFaturaFechada();
        outp.StatusOK = 'ERROR';
        return outp;
    }
    
    public static Boolean EnvioFaturaPorEmail(String numeroConta, String idEmpresa, String cpf, String mesRefFatura, String emailParaEnvio, String idFatura, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('EnvioFaturaPorEmail');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{mes-ref-fatura}', mesRefFatura).replace('{email-para-envio}', emailParaEnvio), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'idempresa' => idEmpresa,
                'Idfatura' => idFatura,
                'cpf' => cpf,
                'canal' => canal,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Envio de Fatura por E-mail', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{mes-ref-fatura}', mesRefFatura).replace('{email-para-envio}', emailParaEnvio),
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
            return true;
        }
        return false;  
    }

    public static OutputGetLinkFatura GetLinkFatura(String numeroConta, String idEmpresa, String cpf, String mesRefFatura, String canal){
        OutputGetLinkFatura retorno = new OutputGetLinkFatura();
        retorno.StatusAPI = 'ERROR';

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetLinkFatura');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{numeroConta}', numeroConta).replace('{mesRefFatura}', mesRefFatura).replace('{cpf}', cpf), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Get Link Fatura', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{numeroConta}', numeroConta).replace('{mesRefFatura}', mesRefFatura).replace('{cpf}', cpf),
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (OutputGetLinkFatura) Json.deserialize(objHttpResponse.getBody(), OutputGetLinkFatura.class);
            retorno.StatusAPI = 'OK';
        }
        return retorno;
    }

    public static OutputGetFaturaFile GetFaturaFile(String numeroConta, String idEmpresa, String cpf, String mesRefFatura, String canal){
        OutputGetLinkFatura objOutputGetLinkFatura = GetLinkFatura(numeroConta, idEmpresa, cpf, mesRefFatura, canal);
        OutputGetFaturaFile retorno = new OutputGetFaturaFile();

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            objOutputGetLinkFatura.link, 
            'GET',
            new Map<String, String>(), 
            null, 
            40000
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Get Fatura File', 
            objOutputGetLinkFatura.link, 
            'GET', 
            '',
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getStatusCode() == 200 ? 'Arquivo gerado' : objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno.Arquivo = objHttpResponse.getBodyAsBlob();
            retorno.StatusAPI = 'OK';
        } else {
            retorno.StatusAPI = 'ERROR';
        }
        return retorno;
    }

    /* 
        OBS:
        O parametro "Map<String, String> MapIdDateFaturas" deve ser passado as informações da seguinte maneira: { idFatura: data }
    */
    public static Boolean EnvioMultiplasFaturasPorEmail(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String email, Map<String, String> MapIdDateFaturas){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('MultiplasFaturasPorEmail');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        // MONTANDO O BODY JSON
        String jsonIdFaturas = '';
        Integer cont = 0;
        for (String item: MapIdDateFaturas.keySet()) {
            cont++;
        
            if (cont == MapIdDateFaturas.size()) {
                jsonIdFaturas += '{"idFatura" : "' + item + '", "data" : "' + MapIdDateFaturas.get(item) + '"}';
            }else{
                jsonIdFaturas += '{"idFatura" : "' + item + '", "data" : "' + MapIdDateFaturas.get(item) + '"},';
            }        
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'IdEmpresa' => idEmpresa,
                'Sistema' => sistema,
                'Canal' => canal,
                'Area' => area,
                'LoginOperador' => loginOperador,
                'Cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{email}', email).replace('{listFaturas}', jsonIdFaturas), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Envio de Multiplas Faturas Por Email', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c.replace('{email}', email).replace('{listFaturas}', jsonIdFaturas), 
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

    public static OutputGetDataVencimentoFatura GetDataVencimentoFatura(String cpf, String numeroConta, String canal, String idEmpresa) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetDataVencimentoFatura');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Data de Vencimento de Fatura', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c,
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        OutputGetDataVencimentoFatura retorno = new OutputGetDataVencimentoFatura();
        retorno.StatusAPI = 'ERROR';
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204') || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (OutputGetDataVencimentoFatura) Json.deserialize(objHttpResponse.getBody(), OutputGetDataVencimentoFatura.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('422')) {
            retorno.StatusAPI = 'CLIENTE SEM PERMISSÃO';
        }
                
        return retorno;  
    }

    public static OutputGetDataVencimentoFatura GetDataVencimentoAtualizadaFatura(String cpf, String numeroConta, String canal, String idEmpresa) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetDataVencimentoFaturaTsys');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = UserDAO.getInstance().getUserDRT(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Data de Vencimento Atualizada Fatura', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c,
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        OutputGetDataVencimentoFatura retorno = new OutputGetDataVencimentoFatura();
        retorno.StatusAPI = 'ERROR';
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputGetDataVencimentoFatura) Json.deserialize(objHttpResponse.getBody(), OutputGetDataVencimentoFatura.class);
            retorno.StatusAPI = 'OK';
        } else {
            retorno.StatusAPI = 'ERRO';
        }
                
        return retorno;  
    }

    public static OutputAlterarVencimento AlterarVencimento(String cpf, String numeroConta, String canal, String area, String sistema, String idEmpresa, String novoDiaVencimento) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AlterarVencimento');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{DataVencimentoAlterado}', novoDiaVencimento)
                .replace('{Cpf}', cpf)
                .replace('{Canal}', canal)
                .replace('{Sistema}', sistema)
                .replace('{Area}', area)
                .replace('{LoginOperador}', loginOperador)
                .replace('{IdEmpresa}', idEmpresa)
                .replace('{NumeroConta}', numeroConta), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Alteração de Vencimento', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c.replace('{DataVencimentoAlterado}', novoDiaVencimento)
                .replace('{Cpf}', cpf)
                .replace('{Canal}', canal)
                .replace('{Sistema}', sistema)
                .replace('{Area}', area)
                .replace('{LoginOperador}', loginOperador)
                .replace('{IdEmpresa}', idEmpresa)
                .replace('{NumeroConta}', numeroConta), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        OutputAlterarVencimento retorno = new OutputAlterarVencimento();
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            // retorno = (OutputAlterarVencimento) Json.deserialize(objHttpResponse.getBody(), OutputAlterarVencimento.class);
            retorno.StatusAPI = 'OK';
            return retorno;
        }
        
        retorno.StatusAPI = 'ERROR';
        return retorno;  
    }

    public static OutputObterResumo ObterResumoFaturaFechada(String cpf, String numeroConta, String canal, String idEmpresa) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterResumoFaturaFechada');
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
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Resumo Fatura Fechada', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c,
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
        
        OutputObterResumo retorno = new OutputObterResumo();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        
        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputObterResumo) Json.deserialize(objHttpResponse.getBody(), OutputObterResumo.class);
            retorno.StatusAPI = 'OK';
        } else {
            retorno.StatusAPI = 'ERROR';
        }
                
        return retorno;  
    }

    public static OutputFaturasResumidas faturasResumidas(String numeroConta, String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('FaturasResumidas');
            
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c.replace('{numeroConta}', numeroConta), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Faturas Resumidas', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{numeroConta}', numeroConta), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        OutputFaturasResumidas output = new OutputFaturasResumidas();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputFaturasResumidas) JSON.deserialize(objHttpResponse.getBody(), OutputFaturasResumidas.class);
            output.statusReponse =  'OK';
            return output;
        }
        output.statusReponse =  'ERROR';
        return output;
    }
    // RESPONSE REFERENTE AO MÉTODO 'UltimosVencimentosFechados'
    public class OutputUltimosVencimentosFechados {
        @InvocableVariable
        public Integer idFatura;
        @InvocableVariable
        public String data;
        @InvocableVariable
        public String dataFormatado;
        @InvocableVariable 
        public String StatusOK;
    }
    
    // RESPONSE REFERENTE AO MÉTODO 'DadosPagamentoFaturaFechada'
    public class OutputDadosPagamentoFaturaFechada {
        @InvocableVariable
        public String codigoBarras;
        @InvocableVariable
        public String linhaDigitavel;
        @InvocableVariable
        public String StatusOK;
    }

    // RESPONSE REFERENTE AO MÉTODO 'DadosPagamentoFaturaFechada'
    public class OutputGetLinkFatura {
        @InvocableVariable
        public String link;
        @InvocableVariable
        public String StatusAPI;
    }

        // RESPONSE REFERENTE AO MÉTODO 'GetFaturaFile'
        public class OutputGetFaturaFile {
            @InvocableVariable
            public Blob Arquivo;
            @InvocableVariable
            public String StatusAPI;
        }

    // RESPONSE REFERENTE AO MÉTODO 'GetDataVencimentoFatura'
    public class OutputGetDataVencimentoFatura {
        @InvocableVariable
        public List<Integer> listaDiasVencimento;
        @InvocableVariable
        public Boolean alteracaoPermitida;
        @InvocableVariable
        public String dataUltimaAlteracao;
        @InvocableVariable
        public String dataVencimento;
        @InvocableVariable
        public String dataFechamento; 
        @InvocableVariable
        public String StatusAPI;
    }

    // RESPONSE REFERENTE AO MÉTODO 'AlterarVencimento'
    public class OutputAlterarVencimento {
        @InvocableVariable
        public String StatusAPI;
    }

    public class OutputObterResumo {
        @InvocableVariable
        public String dataVencimento;
        @InvocableVariable
        public String codigoBarras;
        @InvocableVariable
        public OutputValor valorFatura;
        @InvocableVariable
        public String StatusAPI;
    }

    public class OutputValor {
        @InvocableVariable
        public String valor;
        @InvocableVariable
        public String moeda;
    }
    
    // RESPONSE REFERENTE AO MÉTODO 'resumoFaturas'

    // Classe para mapear a estrutura do objeto "faturas"
    public class OutputFaturasResumidas {
        @InvocableVariable
        public String numeroConta;
        @InvocableVariable
        public String statusReponse;
        @InvocableVariable
        public List<OutputFaturaResumida> faturas;
    }

    public class OutputFaturaResumida {
        @InvocableVariable
        public Boolean ultimaFechada;
        @InvocableVariable
        public String dataVencimento;
        @InvocableVariable
        public String dataVencFormatada;
        @InvocableVariable
        public String tipoFatura;
        @InvocableVariable
        public Integer idTipoFatura;
        @InvocableVariable
        public String dataFechamento;
        @InvocableVariable
        public String statusReponse;
        @InvocableVariable
        public String linhaDigitavel;
        @InvocableVariable
        public String codigoBarras;
    }
}