@isTest
global with sharing class NeoAssistUpdateChamadosMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String body = '{“jsonData”:{“ResponderChamado”:“on”,“Protocolo”:“462300918”,“Origin”:“8”,“Observacao”:“Operador: Whatsapp <br/>Protocolo em atraso.<br/>Registro de novo contato do cliente em 18/07/2023<br/>Novo prazo para retorno Data: 19/07/2023”,“ExpertID”:“184652”,“AguardandoComplemento”:“on”}}';

        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
}