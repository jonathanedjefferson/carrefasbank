public with sharing class JanisIdentificarReagendamento {
    public static JanisIdentificarReagendamentoTO.Retorno makeAPIRequest(String numPedido) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Janis Identificar Reagendamento');
        String apiUrl = config.endpoint__c;
        String calloutMethod = config.method__c;
        String janisApiKey = config.apiKey__c;
        String janisApiSecret = config.clientSecret__c;
        String janisClient = config.clientId__c;
        String endPoint = apiUrl + numPedido;

        HttpRequest request = new HttpRequest();
        Http http = new Http();
  
        request.setMethod(calloutMethod);
        request.setEndpoint(endPoint);
        request.setHeader('janis-api-key', janisApiKey);
        request.setHeader('janis-api-secret', janisApiSecret);
        request.setHeader('janis-client', janisClient);
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Janis identificar reagendamento', endPoint, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        List<JanisIdentificarReagendamentoTO> responseBody = (List<JanisIdentificarReagendamentoTO>) Json.deserialize(response.getBody(), List<JanisIdentificarReagendamentoTO>.class);
        JanisIdentificarReagendamentoTO.Retorno retorno = new JanisIdentificarReagendamentoTO.Retorno();
        if(response.getStatusCode() == 200 && !responseBody.isEmpty()) {
            retorno.status = responseBody[0].status;
            retorno.commerceSequentialId = responseBody[0].commerceSequentialId;
            retorno.receiverName = responseBody[0].addresses[0].receiverName;
            retorno.receiverDocument = responseBody[0].addresses[0].receiverDocument;
            if(responseBody[0].payments.size() > 0){
                retorno.paymentGroup = responseBody[0].payments[0].paymentGroup;
            }
            
            retorno.carrierId = responseBody[0].shippings[0].carrierId;
            retorno.deliveryId = responseBody[0].shippings[0].deliveryId;
            retorno.initialDate = responseBody[0].shippings[0].deliveryWindow.initialDate;
            retorno.finalDate = responseBody[0].shippings[0].deliveryWindow.finalDate;
            retorno.shippingUrl = responseBody[0].Id;
            retorno.commerceSalesChannel = responseBody[0].commerceSalesChannel;

            if(responseBody[0].items != null) {
                for(JanisIdentificarReagendamentoTO.Items item: responseBody[0].items) {
                    if(retorno.items == null) {
                        retorno.items = item.name;
                    } else {
                        retorno.items += ', ';
                        retorno.items += item.name;
                    }  
                }
            }
        }

        retorno.statusCode = response.getStatusCode();
        return retorno;
    }
}