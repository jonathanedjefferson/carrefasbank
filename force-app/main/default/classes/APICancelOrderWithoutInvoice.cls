public class APICancelOrderWithoutInvoice {
    public static Response cancelOrder(String brand, String orderNumber) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Cancelar pedido sem NF');
        String calloutMethod = config.method__c;
        String endPoint = config.endPoint__c + orderNumber + '/cancel';
        String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('auth-key', config.token__c); 
        request.setHeader('brand', brand);
        
        HttpResponse response = new Http().send(request);
        
        System.debug('Cancelamento:  ' + response.getBody());
        
        try {
            LogIntegracaoBO.InsertLog('Cancelar pedido sem NF ', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
            
        } catch(Exception e) {
            LogIntegracaoBO.InsertLog ('Cancelar pedido sem NF ', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(404), e.getMessage(), 'CRF');
        }
        
        If(response.getStatusCode() == 200){ 
            return (Response) JSON.deserialize(response.getbody().replace('date', 'cancelDate'), Response.class);
        } else {
            return null;
        }
    }
    
    public class Response{
        public String orderId;
        public String receipt;
        public String cancelDate;
        
        public Response(String orderId, String receipt, String cancelDate){
            this.orderId = orderId;
            this.receipt = receipt;
            this.cancelDate = cancelDate;
        }
        
    }
}