public class MultiHttpCalloutMock implements HttpCalloutMock {
    private List<HttpResponse> Responses { get; set; }

    public MultiHttpCalloutMock(){
        Responses = new List<HttpResponse>();
    }

    public void addResponse(HttpResponse objHttpResponse) {
        Responses.add(objHttpResponse);
    }

    public void addResponse(Integer intStatusCode) {
        HttpResponse objHttpResponse = new HttpResponse();

        objHttpResponse.setStatusCode(intStatusCode);

        Responses.add(objHttpResponse);
    }

    public void addResponse(Integer intStatusCode, String strStaticResourceName) {
        HttpResponse objHttpResponse = new HttpResponse();

        objHttpResponse.setStatusCode(intStatusCode);
        objHttpResponse.setBody(StaticResourceDAO.getInstance().getByName(strStaticResourceName).Body.toString());

        Responses.add(objHttpResponse);
    }

    public HttpResponse respond(HttpRequest objHttpResponse) {
        if (Responses.size() == 0) {
            return null;
        }
        return Responses.remove(0);
    }
}