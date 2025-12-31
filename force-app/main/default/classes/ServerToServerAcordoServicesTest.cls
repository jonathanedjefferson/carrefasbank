/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ServerToServerAcordoServices                        100%          *
**************************************************************************/
@isTest
public class ServerToServerAcordoServicesTest {
    
    @isTest
    public static void GetTokenServerToServerAcordoTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJBNl82MkVidHNxQ2VNTjNXY1gzZnIyRkFMNTJ4MHBLRjdEckl2SExPTGRvIn0.eyJleHAiOjE2OTM5NDcxNTcsImlhdCI6MTY5Mzk0NTM1NywianRpIjoiODU4Nzg5ZDUtMjY2Ny00YmE3LTljMGEtMTY1ZjhlNDU5MzNjIiwiaXNzIjoiaHR0cHM6Ly9yZWRoYXQtc3NvLWNzZi1obWwtc3NvLmFwcHMub2NwNGhtbC5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtU2Vydmljb3MiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiMzYyZTg4MjAtNWM5Yy00ZTQ2LWIyZDUtMTg2MzliODAyNzc0IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoic3ZjLXNhbGVzZm9yY2Utd2hhdHNhcHAtYWNvcmRvLWRpdmlkYSIsInNlc3Npb25fc3RhdGUiOiI2MzZjMmIzMi0wOGRjLTRkYzAtOWM1Ni1kMmVhZGE5ZWQ5NjEiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwiZGVmYXVsdC1yb2xlcy1jc2Ytc2Vydmljb3MiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsInNpZCI6IjYzNmMyYjMyLTA4ZGMtNGRjMC05YzU2LWQyZWFkYTllZDk2MSIsImNsaWVudElkIjoic3ZjLXNhbGVzZm9yY2Utd2hhdHNhcHAtYWNvcmRvLWRpdmlkYSIsImNsaWVudEhvc3QiOiIxODkuMzcuNzYuNTEiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImNhbmFsIjoiV0hBVFNBUFAiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtc3ZjLXNhbGVzZm9yY2Utd2hhdHNhcHAtYWNvcmRvLWRpdmlkYSIsImNsaWVudEFkZHJlc3MiOiIxODkuMzcuNzYuNTEiLCJ2ZXJzaW9uIjoiNzUifQ.K9pAAqcYuEz5CT_cOfHZF_TN5DUepRLeVgjB33vhtfzgAJZFzfybpYnx9iFC6dZGs50YUAK6ATkka-uddBKq8gbUlornCo24AfsPldaxfW4WMSWuW_i2SmxJ5uOX47a9Mu4gqbs9mFugForbt7FNgMnzUhmbZyoLLkOVY3iNgMVpxWev4qaeRY49GfNsj4I4dynC4Z7mOQt1hwrP1vbHsvuMDeJyPXgQxwFPKanTl7e4cRbMQ5naKeOdlq-skaNPOjT-4PZfHvir83c8AY591MCspzKQXhaa_bFlMst5K3YV8Ob9SQWIn-rj8UWcf9NxRfqoQwjesYmZWvQEeaXeVQ", "expires_in": 1800,"refresh_expires_in": 1800, "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIzYzRmMTg5Mi01ZGQzLTQ3OTItYTEyNi02YTEzMGYyZTUwMWYifQ.eyJleHAiOjE2OTM5NDcxNTcsImlhdCI6MTY5Mzk0NTM1NywianRpIjoiMTQzZjA3OWMtOWMzZi00YjE1LTg3MjQtNTRiNzkwZWMzOTFmIiwiaXNzIjoiaHR0cHM6Ly9yZWRoYXQtc3NvLWNzZi1obWwtc3NvLmFwcHMub2NwNGhtbC5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtU2Vydmljb3MiLCJhdWQiOiJodHRwczovL3JlZGhhdC1zc28tY3NmLWhtbC1zc28uYXBwcy5vY3A0aG1sLmNzZmNwdi53Y29ycC5jYXJyZWZvdXIuY29tL2F1dGgvcmVhbG1zL0NTRi1TZXJ2aWNvcyIsInN1YiI6IjM2MmU4ODIwLTVjOWMtNGU0Ni1iMmQ1LTE4NjM5YjgwMjc3NCIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJzdmMtc2FsZXNmb3JjZS13aGF0c2FwcC1hY29yZG8tZGl2aWRhIiwic2Vzc2lvbl9zdGF0ZSI6IjYzNmMyYjMyLTA4ZGMtNGRjMC05YzU2LWQyZWFkYTllZDk2MSIsInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsInNpZCI6IjYzNmMyYjMyLTA4ZGMtNGRjMC05YzU2LWQyZWFkYTllZDk2MSJ9.XvbtYfZxTNELWe1jTP6xjmPqxEBQBuGO4SS6SMSx0PA", "token_type": "Bearer", "not-before-policy": 1667242382, "session_state": "636c2b32-08dc-4dc0-9c56-d2eada9ed961", "scope": "email profile"}');
        
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<ServerToServerAcordoServices.Input> listInput = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input input = new ServerToServerAcordoServices.Input();
        input.canal = 'chat';
        listInput.add(input);
        
        Test.StartTest();
        List<ServerToServerAcordoServices.ResponseToken> output = ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInput);
        Test.StopTest();
        System.AssertEquals('eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJBNl82MkVidHNxQ2VNTjNXY1gzZnIyRkFMNTJ4MHBLRjdEckl2SExPTGRvIn0.eyJleHAiOjE2OTM5NDcxNTcsImlhdCI6MTY5Mzk0NTM1NywianRpIjoiODU4Nzg5ZDUtMjY2Ny00YmE3LTljMGEtMTY1ZjhlNDU5MzNjIiwiaXNzIjoiaHR0cHM6Ly9yZWRoYXQtc3NvLWNzZi1obWwtc3NvLmFwcHMub2NwNGhtbC5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtU2Vydmljb3MiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiMzYyZTg4MjAtNWM5Yy00ZTQ2LWIyZDUtMTg2MzliODAyNzc0IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoic3ZjLXNhbGVzZm9yY2Utd2hhdHNhcHAtYWNvcmRvLWRpdmlkYSIsInNlc3Npb25fc3RhdGUiOiI2MzZjMmIzMi0wOGRjLTRkYzAtOWM1Ni1kMmVhZGE5ZWQ5NjEiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwiZGVmYXVsdC1yb2xlcy1jc2Ytc2Vydmljb3MiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsInNpZCI6IjYzNmMyYjMyLTA4ZGMtNGRjMC05YzU2LWQyZWFkYTllZDk2MSIsImNsaWVudElkIjoic3ZjLXNhbGVzZm9yY2Utd2hhdHNhcHAtYWNvcmRvLWRpdmlkYSIsImNsaWVudEhvc3QiOiIxODkuMzcuNzYuNTEiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImNhbmFsIjoiV0hBVFNBUFAiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtc3ZjLXNhbGVzZm9yY2Utd2hhdHNhcHAtYWNvcmRvLWRpdmlkYSIsImNsaWVudEFkZHJlc3MiOiIxODkuMzcuNzYuNTEiLCJ2ZXJzaW9uIjoiNzUifQ.K9pAAqcYuEz5CT_cOfHZF_TN5DUepRLeVgjB33vhtfzgAJZFzfybpYnx9iFC6dZGs50YUAK6ATkka-uddBKq8gbUlornCo24AfsPldaxfW4WMSWuW_i2SmxJ5uOX47a9Mu4gqbs9mFugForbt7FNgMnzUhmbZyoLLkOVY3iNgMVpxWev4qaeRY49GfNsj4I4dynC4Z7mOQt1hwrP1vbHsvuMDeJyPXgQxwFPKanTl7e4cRbMQ5naKeOdlq-skaNPOjT-4PZfHvir83c8AY591MCspzKQXhaa_bFlMst5K3YV8Ob9SQWIn-rj8UWcf9NxRfqoQwjesYmZWvQEeaXeVQ', output[0].access_token);
    }
    
    
    @isTest
    public static void GetTokenServerToServerAcordoErrorTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(400);
        responseServerToServer.setBody('{"error": "invalid_client", "error_description": "Invalid client credentials"}');
        
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        List<ServerToServerAcordoServices.Input> listInput = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input input = new ServerToServerAcordoServices.Input();
        input.canal = 'chat';
        listInput.add(input);

        Test.StartTest();
        List<ServerToServerAcordoServices.ResponseToken> output = ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInput);
        Test.StopTest();
        System.AssertEquals(null, output[0].access_token);
    }
}