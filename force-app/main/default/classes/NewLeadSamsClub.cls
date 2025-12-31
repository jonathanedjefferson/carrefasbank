public with sharing class NewLeadSamsClub {
    public static Integer createNewLead(String nome, String sobrenome, String email, String telefone, String cpf, Datetime dataNascimento) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('NewLeadSamsClub');
        String endPoint = config.endpoint__c.replace('{{apiKey}}', config.apiKey__c);
        String calloutMethod = config.method__c;

        RequestWrapper requestBody = buildRequestBody(nome, sobrenome, email, telefone, cpf, dataNascimento.format('yyyy-MM-dd'));
        String requestBodyJson = JSON.serialize(requestBody);
        String authToken = TokenWhatsApp.generateTokenWhatsAppCallout();

        Map<String, String> mapHeaders = new Map<String, String>();
        mapHeaders.put('Content-Type', 'application/json');
        // mapHeaders.put('x-api-key', config.apiKey__c);
        mapHeaders.put('Authorization', 'Bearer ' + authToken);
        HttpResponse response = Util.executarHttpRequest(endPoint, calloutMethod, mapHeaders, requestBodyJson, 2000); 

        LogIntegracaoBO.InsertLog('Cadastrar novo lead SamsClub', endPoint, calloutMethod, requestBodyJson, cpf, String.valueOf(response.getStatusCode()), response.getBody(), 'Sams');
        return response.getStatusCode();
    }

    private static RequestWrapper buildRequestBody(String nome, String sobrenome, String email, String telefone, String cpf, String dataNascimento) {
        RequestWrapper requestBody = new RequestWrapper();
        requestBody.nome = nome;
        requestBody.sobrenome = sobrenome;
        requestBody.email = email;
        requestBody.telefone = telefone; 
        requestBody.data_de_nascimento = dataNascimento;
        requestBody.cpf = cpf;
        return requestBody;
    }

    private class RequestWrapper {
        private String nome;
        private String sobrenome;
        private String email;
        private String telefone;
        private String cpf;
        private String data_de_nascimento;
    }
}