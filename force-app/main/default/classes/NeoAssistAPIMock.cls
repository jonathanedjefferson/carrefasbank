@isTest
global with sharing class NeoAssistAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String body = 
        '{"success":true,"msg":"Registro armazenado.  Protocolo #463236934","Protocolo":{"success":true,"Status":1,"Info":"Protocolo Criado","Protocolo":463236934,"DadosComplementaresAlterados":true},"workflow":{"success":true,"msg":"WorkFlow enviado com sucesso!","WF":{"Status":1,"Info":"Workflow criado com sucesso","WorkflowID":"1005147846"}},"Observacao":null,"RegistrouTempo":true,"TempoAberto":0}';

        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
}