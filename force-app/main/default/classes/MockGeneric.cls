public with sharing class MockGeneric implements HttpCalloutMock{
    private Map<String,HttpResponse> mapResponseByEndpoint = new Map<String,HttpResponse>();

    public void CreateMock(String endPoint,String status, String bodyResponse, Integer StatusCode, Map<String,String> responseHeaders) {
        HttpResponse response = New HttpResponse();
        if (!String.isBlank(status)) response.setStatus(status);
        if (!String.isBlank(bodyResponse)) response.setBody(bodyResponse);
        if (StatusCode != null) response.setStatusCode(statusCode);
        if (!responseHeaders.isEmpty()) {
            for (String header : responseHeaders.keySet()) {
                response.setHeader(header,responseHeaders.get(header));
            }
       }
       mapResponseByEndpoint.put(endPoint,response);
    }

    public void addMock(String endpoint, HttpCalloutMock mock){
        mapResponseByEndpoint.put(endpoint, mock.respond(new HttpRequest()));
    }

    public HttpResponse respond(HttpRequest request) {
        return this.mapResponseByEndpoint.get(request.getEndpoint());
    }

}