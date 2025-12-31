public with sharing class NewMembershipCallout {
    public static NewMembershipTO.ResponseWrapper makeAPIRequest(String store, String aka, String firstname,
                                                                 String lastname, Date birthdate, String zipcode,
                                                                 String number_z, String complement , String phone ,
                                                                 String email, String cpf , Integer promoter, 
                                                                 String partner, String cupom, Boolean optin, String salesChannel,
                                                                 String midiaChannel, String promoName, NewMembershipTO.Additional aditional){
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('New membership');
        String endpoint = config.endpoint__c;
        String calloutMethod = config.method__c;
        String authToken = TokenWhatsApp.generateTokenWhatsAppCallout();

        //Criação do body da request.
        System.debug('entrou na integração');
        NewMembershipTO.RequestWrapper bodyData = new NewMembershipTO.RequestWrapper();
        bodyData.store = store;
        bodyData.aka = aka;
        bodyData.firstname = firstName;
        bodyData.lastname = lastName;
        bodyData.birthdate = birthDate;
        bodyData.zipcode = String.isNotBlank(zipcode) ? zipcode.replace('-','') : '';
        bodyData.number_Z = number_z;
        bodyData.complement = complement;
        bodyData.phone = phone;
        bodyData.email = email;
        bodyData.cpf = String.isNotBlank(cpf) ? cpf.replace('-', '').replace('.', '') : '';
        bodyData.promoter = promoter;
        bodyData.partner = partner;
        bodyData.cupom = cupom;
        bodyData.optin = optin;
        bodyData.saleschannel = salesChannel;
        bodyData.midiachannel = midiaChannel;
        bodyData.promoname = promoName;
        if (aditional == null) {
            bodyData.Additional = new NewMembershipTO.Additional() ;
        }else {
            bodyData.Additional = aditional;
        }
        
        String body = JSON.serialize(bodyData,true);
        String replacedBody = body.replace('number_Z', 'number');
        System.debug('replacedBody:: ' + replacedBody);
        HttpRequest request = new HttpRequest();
        request.setMethod(calloutMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', config.apiKey__c);
        request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setEndpoint(endpoint);
        request.setBody(replacedBody);
        request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('New membership', endpoint, calloutMethod, replacedBody, cpf, String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        if (response.getStatusCode() == 200) {
            //Sucesso.
            try {
                NewMembershipTO.ResponseWrapper responseBody = (NewMembershipTO.ResponseWrapper) Json.deserialize(response.getBody(), NewMembershipTO.ResponseWrapper.class);
                responseBody.status = '200';
                return responseBody;
            } catch(Exception e) {
                return null;
            }
        } else {
            //Erro.
            System.debug(response);
            return null;
        }
    }
}