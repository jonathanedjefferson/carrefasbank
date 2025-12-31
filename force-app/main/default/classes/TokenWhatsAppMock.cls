public class TokenWhatsAppMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        response.setStatusCode(200);
        response.setBody('{"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyX2lkIjoiY29yZWJpeiIsImV4cCI6MTcwMDU5MzYxMH0.SwANyPKswrIPEdJyb2atK9KkpojAQWeN0q9X0kYTu53Ukufvi8SvWYubGy8TfXs8qGgBBAzRuahte2g2fjU6AQ"}');
        return response;
    }
}