public with sharing class TDCAManager {
    public static GetOrdersByCPFResponseWrapper getOrdersByCPF(String CPF, String brand) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Listar Pedidos Por CPF');
        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c + CPF;
        String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('auth-key', config.token__c); 

        //Marca do pedido a ser consultado (CARREFOUR | ATACADAO | SAMS_CLUB).
        request.setHeader('brand', brand);

        HttpResponse response = new Http().send(request);
        System.debug('TDCA Listar pedidos por CPF');
        System.debug(response.getBody());
        LogIntegracaoBO.InsertLog('TDCA Listar Pedidos Por CPF', endPoint, calloutMethod, 'vazio', CPF, String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        if(response.getStatusCode() == 200) {
            GetOrdersByCPFResponseWrapper responseWrapper = (GetOrdersByCPFResponseWrapper) JSON.deserialize((response.getBody()).replace('number', 'number_z').replace('page', 'page_z'), GetOrdersByCPFResponseWrapper.class);
            responseWrapper.statusCode = 200;
            return responseWrapper;
        } else {
            return null;
        }
    }

    public static GetOrderByOrderIdResponseWrapper getOrdersByOrderId(String orderId, String brand) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Listar Pedido Por ID');

        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c + orderId;
        String apiToken = config.apiKey__c;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('auth-key', config.token__c); 

        
        request.setHeader('Content-Type', 'application/json');
        //Marca do pedido a ser consultado (CARREFOUR | ATACADAO | SAMS_CLUB).
        request.setHeader('brand', brand);

        HttpResponse response = new Http().send(request);
        System.debug('TDCA Listar pedido por id');
        System.debug(response.getBody());
        LogIntegracaoBO.InsertLog('TDCA Obter Pedido Pelo ID do Pedido', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        if(response.getStatusCode() == 200) {
            GetOrderByOrderIdResponseWrapper responseWrapper = (GetOrderByOrderIdResponseWrapper) JSON.deserialize((response.getBody()).replace('number', 'number_z'), GetOrderByOrderIdResponseWrapper.class);
            return responseWrapper;
        } else if (response.getBody().containsIgnoreCase('not found on vtex')) {
            GetOrderByOrderIdResponseWrapper responseWrapper = new GetOrderByOrderIdResponseWrapper();
            responseWrapper.status = 'pedido invalido';
            return responseWrapper;
        }else {
            return null;
        }
    }

    public static GetInvoiceResponseWrapper getInvoice(String orderId, String consigmentCode, String brand) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Obter Nota Fiscal');
        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c + orderId + '/consignment/' + consigmentCode + '/invoice';
        String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('Accept', 'application/json');
        request.setHeader('brand', brand);
        request.setHeader('auth-key', config.token__c); 

        HttpResponse response = new Http().send(request);
        
        LogIntegracaoBO.InsertLog('TDCA Obter Nota Fiscal', endPoint, calloutMethod, null, null, String.valueOf(response.getStatusCode()), response.getBody(), '1');
        if(response.getStatusCode() == 200) {
            GetInvoiceResponseWrapper responseWrapper = (GetInvoiceResponseWrapper) JSON.deserialize((response.getBody()).replace('number', 'number_c'), GetInvoiceResponseWrapper.class);
            return responseWrapper;
        } else {
            return null;
        }
    }

    public static GetBankSlipResponseWrapper getBankSlip(String orderId, String brand) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Obter Segunda Via de Boleto');
        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c + orderId + '/bankslip';
        String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('Accept', 'application/json'); 
        request.setHeader('auth-key', config.token__c); 
        request.setHeader('Content-Type', 'application/json');
        //Marca do pedido a ser consultado (CARREFOUR | ATACADAO | SAMS_CLUB).
        request.setHeader('brand', brand);

        HttpResponse response = new Http().send(request);
        System.debug('Obter segunda via de boleto');
        System.debug(response.getBody());
        LogIntegracaoBO.InsertLog('TDCA Obter Boleto', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        if(response.getStatusCode() == 200) {
            GetBankSlipResponseWrapper responseWrapper = (GetBankSlipResponseWrapper) JSON.deserialize((response.getBody()).replace('number', 'number_c'), GetBankSlipResponseWrapper.class);
            return responseWrapper;
        } else { 
            GetBankSlipResponseWrapper ret = (GetBankSlipResponseWrapper) JSON.deserialize(response.getBody(), GetBankSlipResponseWrapper.class);
            return ret;
        }
    }

    public static ResponseGetCustomerWrapper getCustomerByDocument(String document,String brand){
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA obter Clientes por documento');
        String endpoint = config.endPoint__c + '?documentNumber=' + document;
        String method = config.method__c;
        String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('x-api-key', apiToken);
        request.setHeader('auth-key', config.token__c); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('brand', brand);
        HttpResponse response = New Http().send(request);
        System.debug('TDCA obter clientes por documento');
        System.debug(response.getBody());

        ResponseGetCustomerWrapper retorno = new ResponseGetCustomerWrapper();
        //verificar se o status code é de sucesso
        if (response.getStatusCode() == 200) {
            retorno = (ResponseGetCustomerWrapper)JSON.deserialize(response.getBody(), ResponseGetCustomerWrapper.class);
            retorno.status = 'Success';
        }else{
            retorno = null;
        }
        return retorno;
    }

    public static List<ResponseGetCaseTDCA.CaseRecord> getProtocolByDocument(String document, String brand) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Buscar Caso');
        System.debug('config');
        System.debug(config);
        String endpoint = config.endPoint__c + document;
        String method = config.method__c;
        String apiToken = config.apiKey__c;
        

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('x-api-key', apiToken);
        request.setHeader('auth-key', config.token__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('brand', brand);

        HttpResponse response = new Http().send(request);
    
        List<ResponseGetCaseTDCA.CaseRecord> caseRecords = new List<ResponseGetCaseTDCA.CaseRecord>();
        LogIntegracaoBO.InsertLog('TDCA Buscar Caso', endPoint, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        if (response.getStatusCode() == 200) {
            ResponseGetCaseTDCA wrapperResponse = (ResponseGetCaseTDCA)JSON.deserialize(response.getBody(), ResponseGetCaseTDCA.class);
            
            caseRecords = wrapperResponse.records;
        } else {
            System.debug('Erro na requisição. Status Code: ' + response.getStatusCode());
        }
        
        return caseRecords;
    }

    public static sendIncidentTdcaTO.response sendIncidenteTdca(String orderId, String consignmentId, String orderLineId, String contactReason, String brand) {
        // Endpoint da API

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Abrir Incidente');
        String calloutMethod = config.method__c; 
        String endPoint = config.endPoint__c;
        String apiToken = config.apiKey__c;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        
        request.setHeader('x-api-key', apiToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('auth-key', config.token__c);
        request.setHeader('brand', brand);
        request.setHeader('Content-Type', 'application/json');
        
        sendIncidentTdcaTO.request body = new sendIncidentTdcaTO.request();
        body.orderId = orderId;
        body.consignmentId = consignmentId;
        body.orderLineId = orderLineId;
        body.contactReason = contactReason;

        request.setBody(JSON.serialize(body));
        
        sendIncidentTdcaTO.response response = new sendIncidentTdcaTO.response();
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(request);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                response.status = res.getStatusCode();
                response.message = 'Sucesso';
            } else {
                try {
                    response = (sendIncidentTdcaTO.response) JSON.deserialize(res.getBody(), sendIncidentTdcaTO.response.class);
                } catch (Exception e) {
                    response.status = res.getStatusCode();
                    response.message = 'Erro desconhecido: ' + res.getBody();
                }
            }
        } catch (Exception ex) {
            System.debug('Erro na integração TDCA Carrefour Enviar Incidente Mirakl: ' + ex.getMessage());
        }
        

        LogIntegracaoBO.InsertLog('Enviar Incidente TDCA', endPoint, calloutMethod, JSON.serialize(body), null, String.valueOf(res.getStatusCode()),  res.getBody(), 'CRF');
        return response;
    }

    public static CancelamentoComNFEWrapper.ResponseCancelamentoComNFE solicitarCancelamentoComNFE(String canal, CancelamentoComNFEWrapper.BodyRequestCancelamentoComNFE bodyRequest){
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Cancelamento com NFE');
        String body = System.JSON.serialize(bodyRequest);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'auth-key' => config.token__c,
                'x-api-key' => config.apiKey__c,
                'originSystem' => canal
            }, 
            body,
            4000
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            bodyRequest.refund.methodBy == 'CC' ? 'Cancelamento com NFE - Crédito em Conta' : 'Cancelamento com NFE - Ordem de Pagamento', 
            config.Endpoint__c,
            config.Method__c, 
            body, 
            bodyRequest.refund.document, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            bodyRequest.brand
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '201' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            return (CancelamentoComNFEWrapper.ResponseCancelamentoComNFE) JSON.deserialize(objHttpResponse.getBody(), CancelamentoComNFEWrapper.ResponseCancelamentoComNFE.class);
        }
        return null;
    }

    public static CancelamentoSemNFEWrapper cancelamentoSemNFE(String brand, String orderNumber) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Cancelar pedido sem NF');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c.replace('{numeroPedido}', orderNumber), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'auth-key' => config.token__c,
                'x-api-key' => config.apiKey__c,
                'brand' => brand
            }, 
            null,
            4000
        );
        
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Cancelamento sem NFE', 
            config.Endpoint__c.replace('{numeroPedido}', orderNumber), 
            config.Method__c, 
            null, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            brand
        );
        
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '201' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            return (CancelamentoSemNFEWrapper) JSON.deserialize(objHttpResponse.getbody().replace('date', 'cancelDate'), CancelamentoSemNFEWrapper.class);
        }
        return null;
    }

    public static ConsultIncident.Response consultIncidentByOrder( String orderId){
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Consultar Incidente Via Pedido');
        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c + orderId;
        String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('auth-key', config.token__c); 

        HttpResponse response = new Http().send(request);
        System.debug('response:  ' + response.getBody());

        try {
            LogIntegracaoBO.InsertLog('TDCAConsultarIncidente ', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), '');
            
        } catch(Exception e) {
            LogIntegracaoBO.InsertLog('TDCAConsultarIncidente ', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(404), e.getMessage(), '');
        }

        If(response.getStatusCode() == 200){    
            if (String.isBlank(response.getBody())) return new ConsultIncident.Response();
            return (ConsultIncident.Response) JSON.deserialize(response.getbody(), ConsultIncident.Response.class);
            
        } else {
            return null;
        }
    }

    public static SaldoCartaoPresenteWrapper getSaldoCartaoPresente(String brand, String numeroCartao, String senha) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Get Saldo Catao Presente');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c.replace('{numeroCartao}', numeroCartao).replace('{senha}', senha), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'auth-key' => config.token__c,
                'x-api-key' => config.apiKey__c,
                'brand' => brand
            }, 
            null,
            40000
        );
        
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Saldo Catao Presente', 
            config.Endpoint__c.replace('{numeroCartao}', numeroCartao).replace('{senha}', senha), 
            config.Method__c, 
            null, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            brand
        );
        
        String status = String.valueOf(objHttpResponse.getStatusCode());
        SaldoCartaoPresenteWrapper retornoAPI = new SaldoCartaoPresenteWrapper();
        
        if(status == '200' || status == '201' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retornoAPI.success = (SaldoCartaoPresenteWrapper.ReturnSuccess) JSON.deserialize(objHttpResponse.getbody(), SaldoCartaoPresenteWrapper.ReturnSuccess.class);
            retornoAPI.error = null;
        }else{
            retornoAPI.error = (SaldoCartaoPresenteWrapper.ReturnError) JSON.deserialize(objHttpResponse.getbody(), SaldoCartaoPresenteWrapper.ReturnError.class);
            retornoAPI.success = null;
        }
        return retornoAPI;
    }

}