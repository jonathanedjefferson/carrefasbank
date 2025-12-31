@isTest
global with sharing class AtualizarNovosUsuariosTest {
    
    @IsTest
    static void testFlow() {
        List<FlowAtualizarNovosUsuarios.Input> inputList = new List<FlowAtualizarNovosUsuarios.Input>();
        FlowAtualizarNovosUsuarios.Input inLst = new FlowAtualizarNovosUsuarios.Input();
        inLst.fullnumber = '123455678';
        inLst.midiachannel = 'Teste123';
        inLst.partner = 'Teste123';
        inputList.add(inLst);
        
        Test.setMock(HttpCalloutMock.class, new AtualizarNovosUsuariosTest.AtualizarUsuariosMock());        
        FlowAtualizarNovosUsuarios.callAPI(inputList);        
    }
    
    @IsTest
    static void testNullFlow() {
        List<FlowAtualizarNovosUsuarios.Input> inputList = new List<FlowAtualizarNovosUsuarios.Input>();
        FlowAtualizarNovosUsuarios.Input inLst = new FlowAtualizarNovosUsuarios.Input();
        inLst.fullnumber = '123455678';
        inLst.midiachannel = 'Teste123';
        inLst.partner = 'Teste123';
        inputList.add(inLst);
        
        Test.setMock(HttpCalloutMock.class, new AtualizarNovosUsuariosTest.AtualizarUsuariosNullMock());        
        FlowAtualizarNovosUsuarios.callAPI(inputList);   
    }
    
    
    global with sharing class AtualizarUsuariosMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setBody('{"status":0, "statusmsg":"Cadastro atualizado com sucesso.", "msnbr1":"123456576"}');
            response.setStatusCode(200);
            return response;
        }
    }
        global with sharing class AtualizarUsuariosNullMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            return response;
        }
    }
    
}