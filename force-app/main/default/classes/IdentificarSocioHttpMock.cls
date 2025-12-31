@IsTest
public class IdentificarSocioHttpMock implements HttpCalloutMock {
    private HttpResponse mockResponse;

    public IdentificarSocioHttpMock(HttpResponse mockResponse) {
        this.mockResponse = mockResponse;
    }

    public HttpResponse respond(HttpRequest request) {
        return mockResponse;
    }
}