@isTest
global class ServerToServerHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        response.setHeader('Cookie', 'incap_ses_1218_2400284=NWlwBv01iErhbWmFazXnEI0zhWIAAAAAaNqNnManGXUp6inBuasQoQ==;4');
        response.setBody('{"access_token": "Tw6Ec4c2EKlOGSbP5IdTvQ9c4477yamofNFl1PiW_qX0sBBqiANalJTvh8107sSyCRgfpFr_5YNqWj_HGjY5Jl5h7ayl7tuBSdpWdr0IaJL7dvqj0zvuN8jOhafAWoVyW_rtsf_Iucnz4ymyrGEtW5_N3jYGm5t44qpzJymu2UzLH72zPTVjq0jJjaNdRh2ORvfvnLRMB7kwFSUlJe36y8R5nUES32057yxarPh6cKkXEuIK3F5Bx34TtWQvagxDFiaFl_GMsmDfslIqHbM8d3Hca8JBqII2GE1e231XySCy8Eic68u8cs4hhp96mKUptwHRqkl1nnmKp39ySqpP5Q","expires_in": 3600,"refresh_expires_in": 1800,"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIyMTdlODc3ZS0xNjQ4LTRjYzMtOWFjMi1jYzliNjM5MDNjYzcifQ.eyJqdGkiOiJhODNmZGFkOC1jOGNkLTQwMmMtYjI1Zi1mOGNiNzBlNzRkNzgiLCJleHAiOjE2NzYzMTE2MzgsIm5iZiI6MCwiaWF0IjoxNjc2MzA5ODM4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9jc2Ytc2VydmVyLXRvLXNlcnZlciIsImF1ZCI6Imh0dHBzOi8va2V5Y2xvYWstaG9tLmNzZmNwdi53Y29ycC5jYXJyZWZvdXIuY29tL2F1dGgvcmVhbG1zL2NzZi1zZXJ2ZXItdG8tc2VydmVyIiwic3ViIjoiODg5YWFhNjctODJiNC00NGI0LWIyMjYtZDU4ZmZmYzUxYzZlIiwidHlwIjoiUmVmcmVzaCIsImF6cCI6InNhbGVzZm9yY2Utc2VydmljZXNjbG91ZCIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6ImU0MWI2MjJjLWJmOGYtNGU4Yi1hODkwLThiNTRkMTA5NWNiNCIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIn0.8VopYZfZF7fazR-oO0czqDEBzfd_JK0jLJm5YMboQns","token_type": "bearer","not-before-policy": 0,"session_state": "e41b622c-bf8f-4e8b-a890-8b54d1095cb4","scope": "profile"}');
        response.setStatusCode(200);
        return response; 
    }
}