public with sharing class APIJanisV2TOAllOrders {
    public static List<APIJanisV2TO.Retorno> makeAPIRequest(String orderCode, String email) {
        APIJanisV2TO.ResponseWrapper responseWrapper;
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('APIJanisV2');
        String apiUrl = config.endpoint__c.replace('{{viewType}}', 'PORTAL_BACKOFFICE').replace('{{origemApplication}}', 'Janis').replace('{{email}}', email);

        HttpResponse response = Util.executarHttpRequest(
            apiUrl, 
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
        
        List<APIJanisV2TO.Objects> lstObjects = new List<APIJanisV2TO.Objects>();
        try {
            responseWrapper = (APIJanisV2TO.ResponseWrapper) JSON.deserialize(response.getBody(), APIJanisV2TO.ResponseWrapper.class);
            lstObjects = responseWrapper.objects;
            LogIntegracaoBO.InsertLog('APIJanisV2', apiUrl, config.Method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        } catch (Exception ex) {
            try{
                APIJanisV2TO.responseWithNoList responseWrapperNoList;
                responseWrapperNoList = (APIJanisV2TO.responseWithNoList) JSON.deserialize(response.getBody(), APIJanisV2TO.responseWithNoList.class);
                lstObjects.add(responseWrapperNoList.objects);   
                LogIntegracaoBO.InsertLog('APIJanisV2', apiUrl, config.Method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
            }catch (Exception exError){
                LogIntegracaoBO.InsertLog('APIJanisV2', apiUrl, config.Method__c, 'vazio', 'vazio', String.valueOf(404), exError.getMessage(), 'CRF');
            }
        }
        List<APIJanisV2TO.Retorno> listReturn = new List<APIJanisV2TO.Retorno>();
        if(lstObjects !=null && lstObjects.size() > 0) {
            
            for(APIJanisV2TO.Objects currentObject: lstObjects) {
                APIJanisV2TO.Retorno result = new APIJanisV2TO.Retorno();
                result.type = currentObject.consignments[0].type;
                result.status = currentObject.consignments[0].status.status;
                result.estimateDate = currentObject.consignments[0].delivery.estimateDate;
                result.modality = currentObject.consignments[0].delivery.modality;
                result.orderCode = currentObject.orderCode;
                result.orderDate = currentObject.orderDate;
                result.statusCode = response.getStatusCode();
                result.orderFound = true;
                result.howManyOrders = lstObjects.size();
                result.carrierName = currentObject.consignments[0].delivery.carrierName;
                for(APIJanisV2TO.Items item: currentObject.consignments[0].items) {
                    result.items += item.name + ',';
                }
                
                listReturn.add(result);
            }
            return listReturn;
        }

        APIJanisV2TO.Retorno result = new APIJanisV2TO.Retorno();
        result.statusCode = response.getStatusCode();
        result.orderFound = False;
        if(lstObjects == null) {
            result.howManyOrders = 0;
        } else {
            result.howManyOrders = lstObjects.size();
        }
        return new List<APIJanisV2TO.Retorno>{result};
    }

    public class Retorno{
        List<APIJanisV2TO.Retorno> lstRetornos;
        Integer statusCode;
    }
}