/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - MensagensEnhancedController                      100%             *
*    - MensagensEnhanced                                100%             *
*    - ConversationEntries                              98%              *
*    - MessagingSessionDAO                              100%             *
**************************************************************************/

@isTest
public without sharing class MensagensEnhancedTest {
    @TestSetup
    static void makeData(){

        // MessagingChannel 
        MessagingChannel msgChannel = new MessagingChannel();
        msgChannel.MasterLabel = 'Test Channel';
        msgChannel.DeveloperName = 'Test_Channel';
        msgChannel.IsActive = true;
        msgChannel.MessageType = 'Text'; 
        msgChannel.MessagingPlatformKey = '279492398577777';
        insert msgChannel;
        
    }

    @IsTest
    public static void criarMesagensTest(){

        MessagingChannel msgChannel = [SELECT Id FROM MessagingChannel LIMIT 1];

        MessagingEndUser user = new MessagingEndUser();
        user.Name = 'Messaging User';
        user.MessagingChannelId = msgChannel.Id;
        user.MessageType = 'EmbeddedMessaging';
        user.MessagingPlatformKey = '279492398577777';
        insert user;

        MessagingSession  msgSession = new MessagingSession();
        msgSession.StartTime = Datetime.newInstance(Long.valueOf('1721227418000'));
        msgSession.EndTime = Datetime.newInstance(Long.valueOf('1721256539000'));
        msgSession.Status = 'Ended';
        msgSession.MessagingChannelId = msgChannel.Id;
        msgSession.MessagingEndUserId = user.Id; 
        insert msgSession;

        HttpResponse responseAuthSalesforce = new HttpResponse();
        responseAuthSalesforce.setStatusCode(200);
        responseAuthSalesforce.setBody('{ "access_token": "00D8B00000MwAs8M0TXPocLnewhIZlv6IdVCFZLjXyorY5RQ2GeQI0SowTP.LH3.l813j7sz3KoQ8WYO4POZUUxtq", "signature": "rZ+wGG+WuoIXMWM0hcaXl2qhtE2xmAzSjjD5YNm0DU0=", "scope": "lightning visualforce sfap_api cdp_query_api custom_permissions openid cdp_segment_api cdp_api content chatbot_api interaction_api wave_api einstein_gpt_api pwdless_login_api user_registration_api chatter_api id api eclair_api forgot_password", "instance_url": "https://bancocarrefour--homolog.sandbox.my.salesforce.com", "id": "https://test.salesforce.com/id/00D8B000001Atq0UAC/0058c00000DDlYuAAL", "token_type": "Bearer", "issued_at": "1724952042950", "api_instance_url": "https://api.salesforce.com" }');

        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{ "conversationEntries": [ { "clientDuration": 0, "clientTimestamp": 1721227410, "identifier": "6fd4f77d-b183-4128-a36f-7d35be11c041", "messageText": "Oi", "relatedRecords": [ "0Mw8B0000004Hn9" ], "sender": { "appType": "live_message", "role": "EndUser", "subject": "5511988055107" }, "serverReceivedTimestamp": 1721227418808 }, { "clientDuration": 0, "clientTimestamp": 1721227452944, "identifier": "b212656d-373e-4b54-a285-9e15cefcba82", "messageText": "Seja bem vido ao WhatsApp Suporte Picker.", "relatedRecords": [], "sender": { "appType": "chatbot", "role": "Chatbot", "subject": "0Xx8B000000Gt1M" }, "serverReceivedTimestamp": 1721227453045 }, { "clientDuration": 0, "clientTimestamp": 1721227454411, "identifier": "af62bb27-e21c-4abd-89ae-9c44ed276f8f", "messageText": "Para iniciar o atendimento, preciso que me informe a sigla ou numeração para Sams e Atacadão*", "relatedRecords": [], "sender": { "appType": "chatbot", "role": "Chatbot", "subject": "0Xx8B000000Gt1M" }, "serverReceivedTimestamp": 1721227454553 } ] }');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/services/oauth2/token' => responseAuthSalesforce, 
            '/services/data/v58.0/connect/conversation' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        MensagensEnhanced.criarMesagens(msgSession.Id, 'dfd65c73-7e09-4039-b835', msgSession.StartTime, msgSession.EndTime);
        Test.stopTest();

        Assert.areEqual([SELECT COUNT() FROM MensagensEnhanced__c Where SessaoMessaging__c = :msgSession.Id], 3);
    }

    @IsTest
    public static void assyncCriarMensagensTest(){

        MessagingChannel msgChannel = [SELECT Id FROM MessagingChannel LIMIT 1];

        MessagingEndUser user = new MessagingEndUser();
        user.Name = 'Messaging User';
        user.MessagingChannelId = msgChannel.Id;
        user.MessageType = 'EmbeddedMessaging';
        user.MessagingPlatformKey = 'cf9bf7db-1111-2222-3333-49af3c5a037b';
        insert user;

        MessagingSession  msgSession = new MessagingSession();
        msgSession.StartTime = Datetime.newInstance(Long.valueOf('1721227418000'));
        msgSession.EndTime = Datetime.newInstance(Long.valueOf('1721256539000'));
        msgSession.Status = 'Ended';
        msgSession.MessagingChannelId = msgChannel.Id;
        msgSession.MessagingEndUserId = user.Id; 
        insert msgSession;

        HttpResponse responseAuthSalesforce = new HttpResponse();
        responseAuthSalesforce.setStatusCode(200);
        responseAuthSalesforce.setBody('{ "access_token": "00D8B00000MwAs8M0TXPocLnewhIZlv6IdVCFZLjXyorY5RQ2GeQI0SowTP.LH3.l813j7sz3KoQ8WYO4POZUUxtq", "signature": "rZ+wGG+WuoIXMWM0hcaXl2qhtE2xmAzSjjD5YNm0DU0=", "scope": "lightning visualforce sfap_api cdp_query_api custom_permissions openid cdp_segment_api cdp_api content chatbot_api interaction_api wave_api einstein_gpt_api pwdless_login_api user_registration_api chatter_api id api eclair_api forgot_password", "instance_url": "https://bancocarrefour--homolog.sandbox.my.salesforce.com", "id": "https://test.salesforce.com/id/00D8B000001Atq0UAC/0058c00000DDlYuAAL", "token_type": "Bearer", "issued_at": "1724952042950", "api_instance_url": "https://api.salesforce.com" }');

        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{ "conversationEntries": [ { "clientDuration": 0, "clientTimestamp": 1721227410, "identifier": "6fd4f77d-b183-4128-a36f-7d35be11c041", "messageText": "Oi", "relatedRecords": [ "0Mw8B0000004Hn9" ], "sender": { "appType": "live_message", "role": "EndUser", "subject": "5511988055107" }, "serverReceivedTimestamp": 1721227418808 }, { "clientDuration": 0, "clientTimestamp": 1721227452944, "identifier": "b212656d-373e-4b54-a285-9e15cefcba82", "messageText": "Seja bem vido ao WhatsApp Suporte Picker.", "relatedRecords": [], "sender": { "appType": "chatbot", "role": "Chatbot", "subject": "0Xx8B000000Gt1M" }, "serverReceivedTimestamp": 1721227453045 }, { "clientDuration": 0, "clientTimestamp": 1721227454411, "identifier": "af62bb27-e21c-4abd-89ae-9c44ed276f8f", "messageText": "Para iniciar o atendimento, preciso que me informe a sigla ou numeração para Sams e Atacadão*", "relatedRecords": [], "sender": { "appType": "chatbot", "role": "Chatbot", "subject": "0Xx8B000000Gt1M" }, "serverReceivedTimestamp": 1721227454553 } ] }');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/services/oauth2/token' => responseAuthSalesforce, 
            '/services/data/v58.0/connect/conversation' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        MensagensEnhanced.assyncCriarMensagens(msgSession.Id, 'dfd65c73-7e09-4039-b835', msgSession.StartTime, msgSession.EndTime);
        Test.stopTest();

        Assert.areEqual([SELECT COUNT() FROM MensagensEnhanced__c Where SessaoMessaging__c = :msgSession.Id], 3);
    }
}