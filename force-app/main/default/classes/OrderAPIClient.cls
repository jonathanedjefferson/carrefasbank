public class OrderAPIClient {

    public static OrderAPIClientTO.ResponseWrapper getResponsePedido1P(String email) {
        List<OrderAPIClientTO.Objects> resultCalloutList = makeCalloutApiOrder(email);
        OrderAPIClientTO.ResponseWrapper responseWrapper = new OrderAPIClientTO.ResponseWrapper();
        if (resultCalloutList != null) {
            if (!resultCalloutList.isEmpty()) {
                responseWrapper.objects = new List<OrderAPIClientTO.Objects>();
                for (OrderAPIClientTO.Objects obj : resultCalloutList) {
                    
                    OrderAPIClientTO.Consignments consignment = obj.consignments[0];
                    String sellersName = obj.sellersName;
                    String orderCode = obj.orderCode;
                    String orderDate = obj.orderDate;
                    
                    OrderAPIClientTO.Objects orderObj = new OrderAPIClientTO.Objects();
                    orderObj.consignments = new List<OrderAPIClientTO.Consignments>();
                    orderObj.consignments.add(consignment);
                    orderObj.sellersName = sellersName;
                    orderObj.orderCode = orderCode;
                    orderObj.orderDate = orderDate;
                    responseWrapper.objects.add(orderObj);
                }
            }
        }
        
        return responseWrapper;
    }

    public static List<OrderAPIClientTO.Objects> makeCalloutApiOrder(String email){
    
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Pedidos Carrefour 1P');
        String endpoint = config.endpoint__c.replace('{{viewType}}', 'PORTAL_BACKOFFICE').replace('{{origemApplication}}', 'CustomerServices').replace('{{email}}', email);

        HttpResponse response = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'api-key' => config.apiKey__c,
                'x-api-key' => config.token__c
            }, 
            null,
            40000
        );

        if (response.getStatusCode() == 200){
            OrderAPIClientTO.ResponseWrapper responseWrapper;
            List<OrderAPIClientTO.Objects> lstObjects = new List<OrderAPIClientTO.Objects>();
            try {
                responseWrapper = (OrderAPIClientTO.ResponseWrapper) JSON.deserialize(response.getBody(), OrderAPIClientTO.ResponseWrapper.class);
                lstObjects = responseWrapper.objects;
                LogIntegracaoBO.InsertLog('Api order', endpoint, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
            } catch (Exception ex) {
                try{
                    OrderAPIClientTO.responseWithNoList responseWrapperNoList;
                    responseWrapperNoList = (OrderAPIClientTO.responseWithNoList) JSON.deserialize(response.getBody(), OrderAPIClientTO.responseWithNoList.class);
                    lstObjects.add(responseWrapperNoList.objects);   
                    LogIntegracaoBO.InsertLog('Api order', endpoint, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
                }catch (Exception exError){
                    LogIntegracaoBO.InsertLog('Api order', endpoint, config.method__c, 'vazio', 'vazio', String.valueOf(404), exError.getMessage(), 'CRF');
                    return new List<OrderAPIClientTO.Objects>(); 
                }
            }

            return lstObjects;
        }
    
        return new List<OrderAPIClientTO.Objects>();
    }    
}