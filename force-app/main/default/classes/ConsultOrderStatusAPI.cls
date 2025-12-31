public  class ConsultOrderStatusAPI {
    
    public static List<ConsultOrderStatusAPITO.List_Z> makeCalloutApiStatus(String cpf){
    
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Consult order status API');
        System.debug(config);
        
        String endpoint = config.endpoint__c+cpf;
        System.debug('Endpoint: '+ endpoint);
    
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(config.method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-VTEX-API-AppKey', config.apiKey__c);
        request.setHeader('X-VTEX-API-AppToken', config.appInstanceKey__c);

        HttpResponse response = new Http().send(request);
        LogIntegracaoBO.InsertLog('Consultar status dos pedidos SamsClub', endpoint, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'SAMS');

        System.debug('Response'+ response.getBody());
        
        ConsultOrderStatusAPITO.ResponseWrapper responseWrapper = (ConsultOrderStatusAPITO.ResponseWrapper) JSON.deserialize(response.getBody().replace('"list"', '"List_Z"'), ConsultOrderStatusAPITO.ResponseWrapper.class);
        List<ConsultOrderStatusAPITO.List_Z> responseTotalRecords = responseWrapper.List_Z;
        System.debug('ResponseWrapper: ' + responseWrapper);
        System.debug('Response List_Z: '+ responseWrapper.List_Z);
        
        return responseWrapper.List_Z;
    }    
}