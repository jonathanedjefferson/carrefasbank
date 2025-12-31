@isTest
global class MelhorDiaComprasHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setBody('{"melhorDiaCompra": 17}');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
}