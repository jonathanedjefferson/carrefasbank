public with sharing class AbrirIncidenteMiraki {
    public static Integer makeAPIRequest(String orderCode, String reasonCode) {
        //api pede o orderCode com -A no final e orderLineCode com -A-1
        orderCode += '-A';
        String orderLineId = orderCode + '-1';

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Abrir Incidente Miraki');
        String apiUrl = config.endpoint__c + orderCode +'/lines/' + orderLineID + '/open_incident';
        System.debug(apiUrl);
        String calloutMethod = config.method__c;
        String apiToken = config.token__c;
        String cookie = config.cookie__c;

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', apiToken);

        AbrirIncidenteMirakiTO body = new AbrirIncidenteMirakiTO();
        body.reason_code = reasonCode;

        String jsonBody = json.serialize(body);
        request.setBody(jsonBody);

        HttpResponse response = http.send(request);
        System.debug('response');
        System.debug(response);
        LogIntegracaoBO.InsertLog('Abrir incidente Miraki', apiUrl, calloutMethod, jsonBody, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        return response.getStatusCode();
    }
}