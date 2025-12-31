@isTest
global class BCSF_AquisicaoDeCartaoMock implements HttpCalloutMock {
    Map<String, HttpResponse> responseByEndpoint;
    
    public BCSF_AquisicaoDeCartaoMock(Map<String, HttpResponse> responseByEndpoint) {
        this.responseByEndpoint = responseByEndpoint;
    }

    global HttpResponse respond(HttpRequest req) {
       
        if (responseByEndpoint.containsKey(req.getEndpoint())) {
            return responseByEndpoint.get(req.getEndpoint());
        }

        for (String item : responseByEndpoint.keySet()) {
            if (req.getEndpoint().containsIgnoreCase(item)) {
                return responseByEndpoint.get(item);
            }
        }

        HttpResponse emptyResponse = new HttpResponse();
        emptyResponse.setStatusCode(404);
        emptyResponse.setBody('{"error":"Endpoint não encontrado no mock"}');
        return emptyResponse;
    }
}