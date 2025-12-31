@isTest
public with sharing class ObterTokenAcessoAPITest {
    @isTest(SeeAllData=true)
    public static void testEnvio(){
        String resp = '{"id":"teste","name":"test"}';
        HttpResponse tokenResponse = new HttpResponse();
        tokenResponse.setStatusCode(200);
        tokenResponse.setBody(JSON.serialize(resp));
        RESTMock.setResponse(tokenResponse);
        Test.setMock(HttpCalloutMock.class, new RESTMock());

        List<ObterTokenAcessoAPI.Input> listInputToken = new List<ObterTokenAcessoAPI.Input>();
        ObterTokenAcessoAPI.Input inputToken = new ObterTokenAcessoAPI.Input();
        inputToken.canal = 'chat';
        listInputToken.add(inputToken);

        Test.startTest();
        ObterTokenAcessoAPI.getAccessToken(listInputToken);
        Test.stopTest();
    }
}