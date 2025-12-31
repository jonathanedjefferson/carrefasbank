/*
    @responsavel: Guilherme Brito
    @contato: guilgomes@deloitte.com
    @descricao: Classe responsável para chamada genérica às APIs do Banco Carrefour. Classe estará disponível para utilização no fluxo 'BCSF FL Obter token de acesso'.
*/

public with sharing class RealizarChamadaApiGenerica {
    
    public class Request {
        @InvocableVariable(label='Method (GET, POST, PATCH, PUT, DELETE, TRACE, CONNECT, HEAD, OPTIONS)' 
                           required=True description='HTTP Method')
        public String Method;

        @InvocableVariable(label='Endpoint (and Query String)'
                           required=True description='Endpoint (and Query String)')
        public String Endpoint;

        @InvocableVariable(label='Body'description='request Body')
        public String Body;

        @InvocableVariable(label='Timeout in millisecods, default is 10000ms'
                           description='Timeout in milliseconds, default is 10000ms/10s')
        public Integer Timeout;

        @InvocableVariable(label='Params e.g => [{“key”:”queryObject”,”value”:”Account”},{“key”:”queryField”,”value”:”Rating”}]'
                           description='e.g => [{“key”:”queryObject”,”value”:”Account”},{“key”:”queryField”,”value”:”Rating”}]')
        public String Params;

        @InvocableVariable(label='Headers e.g => [{"key":"Content-Type","value":"application/json"},{"key":"Accept","value":"*/*"}]'
                           description='e.g => [{"key":"Content-Type","value":"application/json"},{"key":"Accept","value":"*/*"}]')
        public String Headers;

        @InvocableVariable(label='Body as Blob?'
                           description='Convert Body to Blob if True')
        public Boolean BodyAsBlob;
        
        @InvocableVariable(label='Compress Body to gzip?'
                           description='If true, the data in the Body is delivered to the Endpoint in the gzip compressed format. If false, no compression format is used.')
        public Boolean Compressed_gzip;
    }
    
    public class Response {
        @InvocableVariable(label='Status')
        public String Status;

        @InvocableVariable(label='Status Code')
        public Integer Status_code;

        @InvocableVariable(label='Body')
        public String Body;

        @InvocableVariable(label='Collection of Headers')
        public List<String> CollectionOfHeaders;
        
        @InvocableVariable(label='Error Message')
        public String Error_message;
    }
    
    @InvocableMethod(label='Realizar chamada HTTP genérica' configurationEditor='c:RealizarChamadaHttpGenerica')
    public static List<Response> Invoke (List<Request> requests) {
        system.debug('requests: ' + requests);
        List<Response> responseList = new List<Response>();
        String[] AllowedMethods = new String[]{'GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'TRACE', 'CONNECT', 'HEAD', 'OPTIONS'};

        for (Request curRequest : requests) {
            Response response = new Response();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(60000);
            
            if (AllowedMethods.contains(curRequest.Method.toUpperCase())) {
                req.setMethod(curRequest.Method.toUpperCase());
            } else {
                response.error_message = 'Method Not Allowed';
                responseList.add(response);
                continue;
            }
            
            String url = curRequest.Endpoint;
            if(String.isNotEmpty(curRequest.Params)) {
                List<QueryParams> listParams = (List<QueryParams>) System.JSON.deserialize(curRequest.Params, List<QueryParams>.class);
                List<String> paramsList = new List<string>();
                for (QueryParams param:listParams) {
                    if(String.isNotBlank( param.key) && String.isNotBlank( param.key)) {
                        paramsList.add(param.key+'='+EncodingUtil.urlEncode(param.value, 'UTF-8'));
                    }

                    Boolean containsParams = url.contains('{' + param.key + '}');

                    if(containsParams) {
                        url = url.replace('{' + param.key + '}', param.value);
                    }
                }
                system.debug('Parametros: ' + paramsList);
                system.debug('url: ' + url);
            }
            req.setEndpoint(url);
            
            if(curRequest.Headers != null && curRequest.Headers != '') {
                req = setRequestHeaders(curRequest.Headers,req);
                system.debug('Headers: ' + curRequest.Headers);
            }
            
            if(curRequest.Body != null && curRequest.Body != '') {
                req.setBody(curRequest.Body);
            }
            
            try {
                HttpResponse res = http.send(req);
                system.debug('RES: ' + res);
                response.Status = res.getStatus();
                response.Status_code = res.getStatusCode();
                response.Body = res.getBody();
                response.CollectionOfHeaders = getResponseHeaders(res);
            } catch (CalloutException e) {
                system.debug('erro: ');
                response.error_message = e.getMessage();
            }
            responseList.add(response);
        }
        return responseList;
    }
    
    private class HeaderKeyValue{
        private String key;
        private String value;
    }

    private static HTTPRequest setRequestHeaders(String Headers, HTTPRequest req){
        List<HeaderKeyValue> ListHeaders = (List<HeaderKeyValue>) System.JSON.deserialize(Headers, List<HeaderKeyValue>.class);
        for (HeaderKeyValue Header:ListHeaders){
            if(String.isNotEmpty(Header.key)) {
                req.setHeader(Header.key, Header.value);
            }
        }
        return req;
    }
    
    private static String[] getResponseHeaders(HTTPResponse res){
        List<String> responseHeaderKeys = res.getHeaderKeys();
        String[] ListHeaders = new String[]{};
        for (String responseHeaderKey:responseHeaderKeys){
            String responseHeaderValue = res.getHeader(responseHeaderKey);
            String singleHeader = '{"key": "'+responseHeaderKey+'","value": "'+responseHeaderValue+'"}';
            ListHeaders.add(singleHeader);
        }
        return ListHeaders;
    }
    private class QueryParams{
        private String key;
        private String value;
    }
}