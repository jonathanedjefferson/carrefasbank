@isTest
public class ChatVisitorExpurgoTest {
    @testSetup
    static void setup() {
        //insert custom setting
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c();
        setting.Name = 'DiasExpurgoLiveChatTranscript';
        setting.DiasExpurgo__c = 365;
        insert setting;

        //insert Live Chat Transcript
        LiveChatVisitor lc = new LiveChatVisitor();
        insert lc;
        Test.setCreatedDate(lc.Id, System.now().addDays(-370));

        LiveChatVisitor lc2 = new LiveChatVisitor();
        insert lc2;
        Test.setCreatedDate(lc2.Id, System.now().addDays(-350));
    }

    @isTest 
    static void batchDeleteTest() {
        Test.startTest();
        ChatVisitorExpurgoBatch.start();  
        ChatVisitorExpurgoBatch.start(8);
        Test.stopTest();
        
        List<LiveChatVisitor> listEvent = [SELECT Id, CreatedDate FROM LiveChatVisitor];
        System.assertEquals(1, listEvent.size());
    }

    @isTest 
    static void SchedulableTest() {
        Test.startTest();
        String jobId1 = ChatVisitorExpurgoSchedule.start();
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
        
        String jobId2 = ChatVisitorExpurgoSchedule.start('0 0 3 * * ?');
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
        Test.stopTest();

        // Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct1.TimesTriggered);  
      	System.assertEquals(0, ct2.TimesTriggered);  
    }
}