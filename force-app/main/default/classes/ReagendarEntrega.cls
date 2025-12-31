public with sharing class ReagendarEntrega {
    public static Integer makeAPIRequest(String shippingUrl, String shippingId, String carrierId, String initialDate, String finalDate, String name, String document) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Reagendar entrega');
        String apiUrl = config.endpoint__c + shippingUrl + '/reschedule-delivery';
        String calloutMethod = config.method__c;
        String apiToken = config.token__c;
        String janisApiKey = config.apiKey__c;
        String janisApiSecret = config.password__c;
        String janisClient = config.username__c;

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setTimeout(120000);
        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('janis-api-key', janisApiKey);
        request.setHeader('janis-api-secret', janisApiSecret);
        request.setHeader('janis-client', janisClient);

        ReagendarEntregaTO body = new ReagendarEntregaTO();
        body.shippingId = shippingId;
        body.useSameWarehouseAndLocation = 'true';
        body.currentCarrier = carrierId;
        body.carrierId = carrierId;
        body.deliveryWindowRange = new ReagendarEntregaTO.DeliveryWindowRange();
        body.deliveryWindowRange.from_z = initialDate;
        body.deliveryWindowRange.to = finalDate;
        body.deliveryWindow = new ReagendarEntregaTO.DeliveryWindow();
        body.deliveryWindow.initialDate = initialDate;
        body.deliveryWindow.finalDate = finalDate;
        body.useLastAddress = 'true';
        body.addressReceiver = new ReagendarEntregaTO.AddressReceiver();
        body.addressReceiver.name = name;
        
        body.comment = 'Reagendamento realizado por API';

        //substituir from_z na TO para from 
        String jsonBody = JSON.serialize(body);
        jsonBody = jsonBody.replace('from_z', 'from');
        request.setBody(jsonBody);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Reagendar entrega', apiUrl, calloutMethod, jsonBody, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        return response.getStatusCode();
    
    }
}