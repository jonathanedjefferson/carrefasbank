public with sharing class VerificarStatusTransacao {
    public static ResponseWrapper verifyStatus(String codigoMembership) {
        //Procura os dados do metadado.
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('VerificarStatusTransacao');
        String endPoint = config.endpoint__c;
        String calloutMethod = config.method__c;

        RequestWrapper requestBody = buildRequestBody(codigoMembership);
        String requestBodyJson = JSON.serialize(requestBody);
        String authToken = TokenWhatsApp.generateTokenWhatsAppCallout();

        Map<String, String> headers = new Map<String, String>{
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + authToken,
            'x-api-key' => config.apiKey__c
        };

        HttpResponse response = Util.executarHttpRequest(endPoint, calloutMethod, headers, requestBodyJson, 60000);

        LogIntegracaoBO.InsertLog('Verificar status da transação Sams Club', endPoint, calloutMethod, requestBodyJson, '', String.valueOf(response.getStatusCode()), response.getBody(), 'Sams');
        return processResult(response);
    }

    private static ResponseWrapper processResult(HttpResponse response) {
        System.debug(response.getBody());
        ResponseWrapper result = new ResponseWrapper();
        result.statusCode = response.getStatusCode();

        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        //Verifica se o payload recebido da API está nulo, caso sim, retorna um status de erro.
        if(responseBody.get('payload') == null) {
            result.statusCode = 500;
            return result;
        }

        String payload = String.valueOf(responseBody.get('payload'));

        //Verifica se o payload recebido é um objeto ou uma string individual.
        if(payload.startsWith('{')) {
            ResponseWrapperObject responseBodyObject = (ResponseWrapperObject) Json.deserialize(response.getBody(), ResponseWrapperObject.class);
            result.nome = responseBodyObject.payload.nome;
            result.codigo = responseBodyObject.payload.codigo;
        } else {
            result.payload = payload;
        }

        return result;
    }

    private static RequestWrapper buildRequestBody(String codigoMembership) {
        RequestWrapper requestBody = new RequestWrapper();
        requestBody.codigoMembership = codigoMembership;
        return requestBody;
    }

    private class RequestWrapper {
        private String codigoMembership;
    }

    private class ResponseWrapperObject {
        private String success;
        private Payload payload;
        private String error;
    }

    public class ResponseWrapper {
        public String payload;
        public String nome;
        public Integer codigo;
        public Integer statusCode;
    }

    private class ResponseWrapperString {
        private String success;
        private String payload;
        private String error;
    }

    private class Payload {
        public String nome;
        public Integer codigo;
    }
}