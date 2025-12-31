public with sharing class IdentificacaoPositivaCliente {
    public static IdentificacaoPositivaClienteTO.Retorno makeAPIRequest(String CPF) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Identificação positiva cliente');
        String apiUrl = config.endpoint__c + CPF;

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(config.method__c);
        request.setEndpoint(apiUrl);
        request.setHeader('Authorization', config.token__c);
        request.setHeader('x-api-key', config.apiKey__c);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Identificação postiiva cliente', apiUrl, config.method__c, CPF, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        List<IdentificacaoPositivaClienteTO.ResponseWrapper> resultado = (List<IdentificacaoPositivaClienteTO.ResponseWrapper>) JSON.deserialize(response.getBody(), List<IdentificacaoPositivaClienteTO.ResponseWrapper>.class);

        IdentificacaoPositivaClienteTO.Retorno retorno = new IdentificacaoPositivaClienteTO.Retorno();
        retorno.email = resultado[0].email;
        retorno.firstName = resultado[0].firstName;
        retorno.lastName = resultado[0].lastName;
        retorno.homePhone = resultado[0].homePhone;
        retorno.birthDate = resultado[0].birthDate;

        return retorno;
    }
}