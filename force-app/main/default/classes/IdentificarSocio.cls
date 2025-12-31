public with sharing class IdentificarSocio {
    public static IdentificarSocioTO.ResponseWrapper getInfoSocio(String CPF) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TecnoSolve Identificar Socio');
        
        String Token;
        if(!Test.isRunningTest()) {
            Token = TokenWhatsApp.generateTokenWhatsAppCallout();
        } else {
            Token = 'teste';
        }
    
        String url = config.endpoint__c;
        String method = config.method__c;
        String xApiKey = config.apiKey__c;

        // Headers necessários para a autenticação
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        headers.put('Accept', '*/*');
        headers.put('Authorization', 'Bearer ' + Token);
        headers.put('x-api-key', xApiKey);

        Map<String, String> bodyItens = new Map<String, String>();
        bodyItens.put('cpf', CPF);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }

        Map<String, String> requestBody = new Map<String, String>();
        requestBody.put('cpf', CPF);
        String body = JSON.serialize(requestBody);
        request.setBody(body);

        HttpResponse response = new Http().send(request);
        LogIntegracaoBO.InsertLog('Identifica sócio TecnoSolve', url, method, body, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'SAMS');
        IdentificarSocioTO.ResponseWrapper result = new IdentificarSocioTO.ResponseWrapper();
        
        if (response.getStatusCode() == 200) {
            if (response.getBody().trim() == '[]') {
                //Caso o json de retorno esteja vazio, retorna um objeto nulo.
                return new IdentificarSocioTO.ResponseWrapper();
            }
            IdentificarSocioTO.ResponseWrapper responseWrapper = (IdentificarSocioTO.ResponseWrapper) JSON.deserialize(response.getBody().replace('"number"', '"number_Z"'), IdentificarSocioTO.ResponseWrapper.class);
            result = responseWrapper;
        }
        System.debug(result);
        return result;
    }
}