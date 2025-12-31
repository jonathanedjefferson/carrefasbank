@isTest
global with sharing class CadastrarUsuarioHSMTest{
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new CadastrarUsuarioHSMMock());
        CadastrarUsuarioHSM.makeAPIRequest('12-99205-6397', 'teste', 'teste');
    }

    global with sharing class CadastrarUsuarioHSMMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{"data":{"id":175574,"name":"Marcel Benette","phone":"12-99205-6397","acronymLoja":"SON, EXC_SP_SOR, TBH_SOR, FDS_SOR, LF_DP, RH_INT, DES_C","createdAt":"2023-08-09T13:58:13.493Z","updatedAt":"2023-08-09T13:58:13.493Z","deletedAt":null}}';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }
}