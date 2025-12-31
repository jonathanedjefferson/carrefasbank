@isTest
global class BCSF_AvaliacaoEmergencialMock implements HttpCalloutMock{
	Map<String, HttpResponse> responseByEndpoint;   
	
    public BCSF_AvaliacaoEmergencialMock(Map<String, HttpResponse> responseByEndpoint) {
        this.responseByEndpoint = responseByEndpoint;
    }

    public HttpResponse respond(HttpRequest req) {
        if (responseByEndpoint.containsKey(req.getEndpoint())) {
            return responseByEndpoint.get(req.getEndpoint());
        }

        for (String item: responseByEndpoint.keySet()) {
            if (req.getEndpoint().containsIgnoreCase(item)) {
                return responseByEndpoint.get(item);
            }
        }

        return new HttpResponse();
    }
}