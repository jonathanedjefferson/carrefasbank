@isTest
public with sharing class FlowConsultaCepTest {
    static FlowConsultaCep.Input  input = new FlowConsultaCep.Input();

    @TestSetup
    static void makeData(){
        input.cep = '58705070';
    }
   @isTest
   public static void consultarCepTest(){
        Varejo_Api_Callout__mdt meta = Varejo_Api_Callout__mdt.getInstance('ConsultaCep');
        Varejo_Api_Callout__mdt metaAuth = Varejo_Api_Callout__mdt.getInstance('APIGerarTokenDeAutenticaoV1');
        
        TokenWhatsAppMock mockAuth = new TokenWhatsAppMock();
        MockGeneric mock = new MockGeneric();

        mock.addMock(metaAuth.endPoint__c, mockAuth);
        test.setMock(HttpCalloutMock.class, mock);
        mock.CreateMock(meta.endPoint__c,'OK', '{"success":true,"payload":{"uf":"SP","cidade":"Osasco","bairro":"Presidente Altino","logradouro":"Ana Zozi Toni"},"error":null}', 200, new Map<String,String> {'Content-Type' =>'Application/json'});
        System.debug(mock);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
            List<FlowConsultaCep.Output> results = FlowConsultaCep.consultarCep(new List<FlowConsultaCep.Input>{input});
        Test.stopTest();

        System.assertEquals(results.size(), 1);
        System.assertEquals(results[0].success, true);
   }
}