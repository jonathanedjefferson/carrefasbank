public class Cashback {

    public static Balance consultarSaldosNativos(String cpf, String canal, String unidadeNegocio) {

        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarSaldosNativosCashback');
        
        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Consultar Saldos Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        Balance retornoAPI = new Balance();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (Balance) JSON.deserialize(objHttpResponse.getBody(), Balance.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static Statement consultarExtrato(String cpf, String canal, String unidadeNegocio, Map<String, String> params) {
        
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('obterExtratoCashback');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId);
        String pathParams = '';
        for (String key : params.keySet()) {
            if (String.isBlank(pathParams)) {
                pathParams += '?' + key + '=' + params.get(key);
                continue;
            }

            pathParams += '&' + key + '=' + params.get(key);
        }
        endpoint += pathParams;
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);

        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Extrato Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        Statement retornoAPI = new Statement();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (Statement) JSON.deserialize(objHttpResponse.getBody().replace('"date":', '"dateReplaced":'), Statement.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static TransactionDetails consultarDetalhesTransacao(String cpf, String canal, String unidadeNegocio, String idTransacao) {
        
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('obterDetalheTransacaoCashback');
        
        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId).replace('{transactionId}',idTransacao);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Detalhes Transação Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        TransactionDetails retornoAPI = new TransactionDetails();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (TransactionDetails) JSON.deserialize(objHttpResponse.getBody().replace('"date":', '"dateReplaced":'), TransactionDetails.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static FutureTransaction consultarTransacoesFuturas(String cpf, String canal, String unidadeNegocio) {
        
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarTransacoesFuturasCashback');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Transações Futuras Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        FutureTransaction retornoAPI = new FutureTransaction();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (FutureTransaction) JSON.deserialize(objHttpResponse.getBody().replace('"date":', '"dateReplaced":'), FutureTransaction.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    public static Boolean realizarBloqueioPreventivo(String cpf, String canal, String unidadeNegocio) {
        
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BloqueioPreventivoCashback');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Bloqueio Preventivo Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            return true;
        }

        return false;
    }

    public static Boolean realizarBloqueioDefinitivo(String cpf, String canal, String unidadeNegocio) {
        
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('BloqueioDefinitivoCashback');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Bloqueio Definitivo Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            return true;
        }

        return false;
    }

    public static Boolean desbloquearConta(String cpf, String contractKey, String canal, String unidadeNegocio) {
        
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DesbloqueioCashback');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', contractKey);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.access_token,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Desbloqueio de Conta Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            return true;
        }

        return false;
    }

    public static Boolean cancelarConta(String cpf, String canal, String unidadeNegocio) {
        
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CancelamentoContaCashback');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId);
        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueof(config.Timeout__c);
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/json', 
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse objHttpResponse = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Cancelamento Conta Cashback', 
            endpoint, 
            metodo, 
            body,  
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            unidadeNegocio,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200) {
            return true;
        }

        return false;
    }

    public static ContaFinanceira__c getCashbackCustomerInfo(String cpf) {
        if (String.isBlank(cpf)) {
            return null;
        }

        List<ContaFinanceira__c> lLstFinancialAccounts = [SELECT Id, NomeCliente__r.Name, CPFBanco__c, Produto__c, 
            StatusContrato__c, NumeroContrato__c FROM ContaFinanceira__c 
            WHERE CPFBanco__c =: cpf AND RecordType.DeveloperName = 'Comprou_Voltou' LIMIT 1];

        return !lLstFinancialAccounts.isEmpty() ? lLstFinancialAccounts[0] : null;
    }

    public static Case createCase(Map<String, Object> lMapParams) {
        String event = (String) lMapParams.get('event');
        String cpf = (String) lMapParams.get('cpf');
        String customerId = (String) lMapParams.get('customerId');
        String contractStatus = (String) lMapParams.get('contractStatus');

        if ('Resgate não reconhecido'.equals(event) && !'BloqueioTemporario'.equals(contractStatus)) {
            if (!realizarBloqueioPreventivo(cpf, '', '')) {
                return null;
            }

            updateCustomer(customerId, 'BloqueioTemporario');
        }

        Case newCase = new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CAS_Atendimento').getRecordTypeId();
        newCase.ContaFinanceira__c = customerId;
        newCase.Assunto__c = (String) lMapParams.get('subject');
        newCase.Evento__c = event;
        newCase.Origin = (String) lMapParams.get('origin');
        newCase.CanalEntrada__c = (String) lMapParams.get('channel');
        newCase.Description = (String) lMapParams.get('description');
        newCase.IDTransacao__c = (String) lMapParams.get('transactionId');
        newCase.Contratos__c = (String) lMapParams.get('contractNumber');
        newCase.Produto_c__c = 'Comprou Voltou';
        newCase.CriarCasoPorComponente__c = true;

        String subjectType = (String) lMapParams.get('subjectType');
        Decimal amount = Decimal.valueOf((String) lMapParams.get('amountValue'));
        if ('refund'.equals(subjectType)) {
            newCase.AjusteEstimado__c = amount;
        }
        else {
            newCase.ValorResgate__c = amount < 0 ? (amount * -1) : amount;
        }

        AssignmentRule caseAssignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];

        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = caseAssignmentRule.Id;
        newCase.setOptions(dmlOpts);

        try {
            insert newCase;
        } catch (Exception ex) {
            System.debug('Falha ao Criar Caso Cashback.' + ex.getMessage());
            System.debug('Erros ' + ex.getStackTraceString());
            return null;
        }

        Case createdCase = [SELECT Id, CaseNumber, OwnerId FROM Case WHERE Id =: newCase.Id LIMIT 1];
        return createdCase;
    }

    private static void updateCustomer(String customerId, String lStatus) {
        try {
            update new ContaFinanceira__c(Id = customerId, StatusContrato__c = lStatus);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static ResultadoContestacaoCashback ContestarResgate(String cpf, String canal, String unidadeNegocio, String idTransacao) {
        ResultadoContestacaoCashback resultado = new ResultadoContestacaoCashback();

        if (unidadeNegocio == null) unidadeNegocio = '';

        ServerToServerCashback.ResponseToken token =
            ServerToServerCashback.GetTokenServerToServer(cpf, canal);

        CarrefourAPICallout__mdt config =
            CarrefourAPICalloutDAO.getInstance().getByLabel('ContestacaoResgateCashback');

        String endpoint = config.Endpoint__c +
            config.Path__c
                .replace('{accountId}', token.accountId)
                .replace('{transactionId}', idTransacao);

        String body = config.Body__c;
        String metodo = config.Method__c;
        Integer timeout = Integer.valueOf(config.Timeout__c);

        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };

        HttpResponse resp = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);

        LogIntegracaoBO.InsertLog(
            'Contestação de Resgate Cashback',
            endpoint,
            metodo,
            body,
            cpf,
            String.valueOf(resp.getStatusCode()),
            resp.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );

        resultado.statusCode = resp.getStatusCode();
        resultado.mensagem   = resp.getBody();
        resultado.sucesso    = (resultado.statusCode == 200 || resultado.statusCode == 204);
        return resultado;
    }

    public static ResultadoAjusteCashback ajusteCashback(String cpf, String canal, String unidadeNegocio, String idTransacao, String dueAmountBu, String dueAmountBank) {
        ResultadoAjusteCashback resultado = new ResultadoAjusteCashback();
    
        ServerToServerCashback.ResponseToken token = ServerToServerCashback.GetTokenServerToServer(cpf, canal);
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AjusteCashback');
    
        String endpoint = config.Endpoint__c + config.Path__c.replace('{accountId}', token.accountId).replace('{transactionId}', idTransacao);
        String body = config.Body__c.replace('{dueAmountBu}', dueAmountBu).replace('{dueAmountBank}', dueAmountBank);
        String metodo = config.Method__c;
        Integer timeout = Integer.valueOf(config.Timeout__c);
        
        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + token.accessToken,
            'x-apikey' => config.Authorization__c,
            'x-uat' => config.UAT__c == null ? '' : config.UAT__c
        };
    
        HttpResponse response = Util.executarHttpRequest(endpoint, metodo, header, body, timeout);
    
        LogIntegracaoBO.InsertLog(
            'Ajuste de Cashback',
            endpoint,
            metodo,
            body,
            cpf,
            String.valueOf(response.getStatusCode()),
            response.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );
    
        resultado.statusCode = response.getStatusCode();
        resultado.mensagem = response.getBody();
        resultado.sucesso = (response.getStatusCode() == 200 || response.getStatusCode() == 204);
    
        return resultado;
    }

    public static ResultadoPromocoesCashback motorCashback(String rms, String canal, String unidadeNegocio, String bu) {
        ResultadoPromocoesCashback resultado = new ResultadoPromocoesCashback();
    
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CashbackMotor');
    
        String endpoint = config.Endpoint__c + config.Path__c.replace('{{rms}}', rms);
    
        List<String> qp = new List<String>();
        if (!String.isBlank(bu)) qp.add('businessUnit=' + EncodingUtil.urlEncode(bu, 'UTF-8'));
        if (!String.isBlank(canal))          qp.add('channelType='  + EncodingUtil.urlEncode(canal,          'UTF-8'));
        if (!qp.isEmpty()) endpoint += (endpoint.contains('?') ? '&' : '?') + String.join(qp, '&');
        String metodo = config.Method__c;
        Integer timeout = Integer.valueOf(config.Timeout__c);
    
        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'x-api-key' => config.Authorization__c
        };
    
        HttpResponse response = Util.executarHttpRequest(endpoint, metodo, header, null, timeout);
        LogIntegracaoBO.InsertLog(
            'Motor Cashback',
            endpoint,
            metodo,
            null,
            '',
            String.valueOf(response.getStatusCode()),
            response.getBody(),
            unidadeNegocio,
            canal != null ? canal.capitalize() : null
        );
    
        resultado.statusCode = response.getStatusCode();
        resultado.sucesso = (response.getStatusCode() >= 200 && response.getStatusCode() < 300);
        
        if (resultado.sucesso && !String.isBlank(response.getBody())) {
            try {
                resultado.dados = (List<CashbackMotorTO>) JSON.deserialize(response.getBody(), List<CashbackMotorTO>.class);
            } catch (Exception e) {
                resultado.sucesso = false;
                resultado.dados = new List<CashbackMotorTO>();
            }
        } else {
            resultado.dados = new List<CashbackMotorTO>();
        }
    
        return resultado;
    }
    
    
    

    public class Balance {
        @AuraEnabled
        public Decimal rewardPoints;
        @AuraEnabled
        public Decimal rewardFuturePoints;
        @AuraEnabled
        public String expireDate;
        @AuraEnabled
        public Integer daysToExpire;
        @AuraEnabled
        public Integer rewardWalletStatus;
        @AuraEnabled
        public String activatedForTransactionExpiration;
        @AuraEnabled
        public String statusAPI;
    }

    public class Statement {
        @AuraEnabled
        public List<StatementItem> statements;
        @AuraEnabled
        public Integer totalItems;
        @AuraEnabled
        public Integer pageSize;
        @AuraEnabled
        public Integer page;
        @AuraEnabled
        public Integer pageCount;
        @AuraEnabled
        public String statusAPI;
    }

    public class TransactionDetails {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Integer buId;
        @AuraEnabled
        public Decimal rewardAmount;
        @AuraEnabled
        public Integer rewardTransactionType; // 1 - Accumulation / 2- Redemption  / 3 - Canceled / 4 - Reversal / 5 - Expired / 7 - Refund
        @AuraEnabled
        public String rewardTransactionTypeDescription;
        @AuraEnabled
        public Integer origin;
        @AuraEnabled
        public String originDescription;
        @AuraEnabled
        public String transactionDate;
        @AuraEnabled
        public Purchase purchase;
        @AuraEnabled
        public Integer purchaseRewardNumberItems;
        @AuraEnabled
        public String statusAPI;
    }

    public class  FutureTransaction {
        @AuraEnabled
        public List<Transactions> futureTransactions;
        @AuraEnabled
        public String statusAPI;
    }

    public class StatementItem {
        @AuraEnabled
        public String dateReplaced; // realizar o replace de date para dateReplace (date é palavra reservada do apex que retorna na API)
        @AuraEnabled
        public Decimal balance;
        @AuraEnabled
        public List<Transactions> transactions;
    }

    public class Transactions {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Integer buId;
        @AuraEnabled
        public Integer rewardTransactionType;
        @AuraEnabled
        public Decimal rewardAmount;
        @AuraEnabled
        public String transactionDate;
        @AuraEnabled
        public Integer origin;
        @AuraEnabled
        public Purchase purchase;
        @AuraEnabled
        public String rewardTransactionTypeDescription;
        @AuraEnabled
        public String originDescription;
        @AuraEnabled
        public String rewardReleaseDate;
    }

    public class Purchase {
        @AuraEnabled
        public String dateReplaced; // realizar o replace de date para dateReplace (date é palavra reservada do apex que retorna na API)
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public List<Item> items;
    }

    public class Item {
        @AuraEnabled
        public String itemDescription;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public String rewardDescription;
        @AuraEnabled
        public Decimal purchaseAmount;
        @AuraEnabled
        public Decimal rewardAmount;
        @AuraEnabled
        public String unitName;
    }

    public class ResultadoAjusteCashback {
        public Boolean sucesso;
        public String mensagem;
        public Integer statusCode;
    }

    public class ResultadoContestacaoCashback {
        public Boolean sucesso;
        public Integer statusCode;
        public String mensagem;
    }

    public class ResultadoPromocoesCashback {
        public Boolean sucesso;
        public Integer statusCode;
        public List<CashbackMotorTO> dados;
    }
}