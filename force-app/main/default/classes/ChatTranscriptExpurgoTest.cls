@isTest
public class ChatTranscriptExpurgoTest {
    @testSetup
    static void setup() {
        //insert custom setting
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c();
        setting.Name = 'DiasExpurgoLiveChatTranscript';
        setting.DiasExpurgo__c = 365;
        insert setting;

        //insert Live Chat Transcript
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript lc = new LiveChatTranscript();
        lc.LiveChatVisitorId = visitor.Id;
        insert lc;
        Test.setCreatedDate(lc.Id, System.now().addDays(-370));

        LiveChatTranscript lc2 = new LiveChatTranscript();
        lc2.LiveChatVisitorId = visitor.Id;
        insert lc2;
        Test.setCreatedDate(lc2.Id, System.now().addDays(-350));
        
    }

    @isTest 
    static void batchDeleteTest() {
        Test.startTest();
        ChatTranscriptExpurgoBatch.start();  
        ChatTranscriptExpurgoBatch.start(8);
        Test.stopTest();
        
        List<LiveChatTranscript> listEvent = [SELECT Id, CreatedDate FROM LiveChatTranscript];
        System.assertEquals(1, listEvent.size());
    }

    @isTest 
    static void SchedulableTest() {
        Test.startTest();
        String jobId1 = ChatTranscriptExpurgoSchedule.start();
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
        
        String jobId2 = ChatTranscriptExpurgoSchedule.start('0 0 2 * * ?');
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
        Test.stopTest();

        // Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct1.TimesTriggered);  
      	System.assertEquals(0, ct2.TimesTriggered);  
    }
}