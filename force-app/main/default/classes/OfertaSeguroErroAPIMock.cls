@isTest
    global class OfertaSeguroErroAPIMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Authorization', 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiJiOWM4MDcwZi00ZDg2LTRiZGEtOTdmZi1lODBhZmIyYmM1YTMiLCJleHAiOjE2ODYwMDMxMjgsIm5iZiI6MCwiaWF0IjoxNjg2MDAxMzI4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6OTg2OTM2NzgzNjEgIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoicHdhX2NhcnRhb19jYXJyZWZvdXIiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI2MTExZjMyMy1hNjMwLTQzOGItYjI2Ni00ZmEzMDg1MWM5ZTIiLCJhY3IiOiIxIiwic2NvcGUiOiJjc2ZfcGxhdGFmb3JtYV9kaWdpdGFpcyBwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJhY2NvdW50X25hbWUiOiIiLCJjcGYiOiI5ODY5MzY3ODM2MSAiLCJ0aXBvX2NsaWVudGUiOiIxIiwiaWRfZW1wcmVzYSI6IjEiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiI5ODY5MzY3ODM2MSAiLCJlbWFpbCI6Ijk4NjkzNjc4MzYxICJ9.HolW81I6ioVr9fIKry4FMVF8CyadOvd6OYaiYcCtUMGmLgkgy08U_ZIhjracWdubBcbmwaYVZmjvubaeIKgDVim8YXgqllwmJrcE1lkcHzQICxnwqy0NlhJtEa3S8CsFlIunVMiZdDQOle2AGFbf8StHw2rIedipbjBxFFttfpQX5ErCMkFGKdv5JEazfgcNlFMXKQp_T4gByfMfQNARwiwkOvgpgLYndJETuWcH5yQ9AFonNkkSKVejaeFaeDNYo1lvSq9W0kJ4u3BB2ITwuID33j77DX0oS1oJywsVWh9n-FygJzdmpR1_t9WW9NMVpNJUawjKRtBtMP9Qm8-CYA');
        response.setBody('{"status": 1, "nome": "Antonio Ferraz Rocha", "produtos": []}');
        response.setStatusCode(400);
        return response; 

    }
}