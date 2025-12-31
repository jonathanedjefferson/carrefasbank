@isTest
public with sharing class InvocableSalvarOptInsTest {
    public static InvocableSalvarOptIns.Input input = new InvocableSalvarOptIns.Input();
    
    @TestSetup
    static void makeData(){
        input.cpf = '12332104402';
        input.bandeira = 'Sams';
        input.versao = '2.0.0';
        input.pushnotification = false;
        input.email = false;
        input.sms = false;
        input.telefone = false;
        input.thirdparty = true;
    }

    @isTest
    public static void invocableSalvarOptInsTest(){
        Varejo_Api_Callout__mdt meta = Varejo_Api_Callout__mdt.getInstance('SalvarOptins');
        Varejo_Api_Callout__mdt metaAuth = Varejo_Api_Callout__mdt.getInstance('APIGerarTokenDeAutenticaoV1');
        
        TokenWhatsAppMock mockAuth = new TokenWhatsAppMock();
        MockGeneric mock = new MockGeneric();

        mock.addMock(metaAuth.endPoint__c, mockAuth);
        test.setMock(HttpCalloutMock.class, mock);
        mock.CreateMock(meta.endPoint__c,'OK', '{indiferente:true}', 200, new Map<String,String> {'Content-Type' =>'Application/json'});

        Test.startTest();
        List<InvocableSalvarOptIns.Output> statusCodes = InvocableSalvarOptIns.invocableSalvarOptIns(New List<InvocableSalvarOptIns.Input>{input});
        Test.stopTest();
        
        System.assertEquals(statusCodes.size(), 1);
        System.assertEquals(statusCodes[0].statusCode, 200);

    }
}