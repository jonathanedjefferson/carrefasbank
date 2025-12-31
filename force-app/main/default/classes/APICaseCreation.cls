public with sharing class APICaseCreation {

    public static CaseResponse createCase(String brand, String preferenceContact, String orderNumber, String consignmentCode, String origin, String channel, String typeorder, String subjectReasonContact, String event, String document, String emailClient, String customerName, String telephone, String description, String store) {
         Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Criar Caso');
         String calloutMethod = config.method__c;
         String endPoint = config.endPoint__c + 'brand=' + brand + '&store=' + store;
         String apiToken = config.apiKey__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('auth-key', config.token__c); 
        request.setHeader('brand', brand);
        
        CaseRequest rBody = new CaseRequest(preferenceContact, orderNumber, consignmentCode, origin, channel, typeorder, subjectReasonContact, event, document, emailClient, customerName, telephone, description);
       	String reqBody = JSON.serialize(rBody);
        request.setBody(JSON.serialize(rBody));
        HttpResponse response = new Http().send(request);

		System.debug('Criação de Casos:  ' + response.getBody());
        
        try {
   		LogIntegracaoBO.InsertLog('CaseCreation ', endPoint, calloutMethod, reqBody, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
		
        } catch(Exception e) {
            LogIntegracaoBO.InsertLog('CaseCreation ', endPoint, calloutMethod, reqBody, 'vazio', String.valueOf(404), e.getMessage(), 'CRF');
        }
        
        If(response.getStatusCode() == 201){ 
            return (CaseResponse) JSON.deserialize(response.getbody(), CaseResponse.class);
        } else {
            return null;
        }
    }
    public class CaseRequest {
        public String preferenceContact;
        public String orderNumber;
        public String consignmentCode;
        public String origin;
        public String channel;
        public String typeorder;
        public String subjectReasonContact;
        public String event;
        public String document;
        public String emailClient;
        public String customerName;
        public String telephone;
        public String description;
        public String store;
        
        public CaseRequest(String preferenceContact, String orderNumber, String consignmentCode, String origin, String channel, String typeorder, String subjectReasonContact, String event, String document, String emailClient, String customerName, String telephone, String description) {
            this.preferenceContact = preferenceContact;
            this.orderNumber = orderNumber;
            this.consignmentCode = consignmentCode;
            this.origin = origin;
            this.channel = channel;
            this.typeorder = typeorder;
            this.subjectReasonContact = subjectReasonContact;
            this.event = event;
            this.document = document;
            this.emailClient = emailClient;
            this.customerName = customerName;
            this.telephone = telephone;
            this.description = description;
        }
        
    }

    public class CaseResponse{
        public String id;
        public Boolean success;
   //     public Map<String, object> errors;
        
    }
}