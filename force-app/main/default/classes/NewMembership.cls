public with sharing class NewMembership {
    // public static NewMembershipTO.ResponseWrapper makeAPIRequest(String store, String aka, String firstName, String lastName, String birthDate, String zipcode, String number_z, String complement, String phone, String email, String cpf, Integer promoter, String partner, String cupom, String option, String salesChannel, String midiaChannel, String promoName) {
    //     //Dados da api pelo metadado.
    //     Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('New membership');
    //     String endpoint = config.endpoint__c;
    //     String calloutMethod = config.method__c;
    //     String authToken = TokenWhatsApp.generateTokenWhatsAppCallout();
    //     System.debug(authToken);

    //     //Criação do body da request.
    //     NewMembershipTO.RequestWrapper bodyData = new NewMembershipTO.RequestWrapper();
    //     bodyData.store = store;
    //     bodyData.aka = aka;
    //     bodyData.firstname = firstName;
    //     bodyData.lastname = lastName;
    //     bodyData.birthdate = birthDate;
    //     bodyData.zipcode = zipcode;
    //     bodyData.number_Z = number_z;
    //     bodyData.complement = complement;
    //     bodyData.phone = phone;
    //     bodyData.email = email;
    //     bodyData.cpf = cpf;
    //     bodyData.promoter = promoter;
    //     bodyData.partner = partner;
    //     bodyData.cupom = cupom;
    //     bodyData.optin = option;
    //     bodyData.salechannel = salesChannel;
    //     bodyData.midiachannel = midiaChannel;
    //     bodyData.promoname = promoName;

    //     String body = JSON.serialize(bodyData);
    //     String replacedBody = body.replace('number_Z', 'number');

    //     HttpRequest request = new HttpRequest();
    //     request.setMethod(calloutMethod);
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Authorization', 'Bearer ' + authToken);
    //     request.setEndpoint(endpoint);
    //     request.setBody(replacedBody);

    //     Http http = new Http();
    //     HttpResponse response = http.send(request);
    //     LogIntegracaoBO.InsertLog('New membership', endpoint, calloutMethod, replacedBody, cpf, String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

    //     if (response.getStatusCode() == 200) {
    //         //Sucesso.
    //         try {
    //             NewMembershipTO.ResponseWrapper responseBody = (NewMembershipTO.ResponseWrapper) Json.deserialize(response.getBody(), NewMembershipTO.ResponseWrapper.class);
    //             return responseBody;
    //         } catch(Exception e) {
    //             return null;
    //         }
    //     } else {
    //         //Erro.
    //         return null;
    //     }
    // }
}