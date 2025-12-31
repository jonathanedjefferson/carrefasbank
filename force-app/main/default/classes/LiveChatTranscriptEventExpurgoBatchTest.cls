/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - LiveChatTranscriptEventExpurgoBatch                   100%        *
*    - LiveChatTranscriptEventExpurgoSchedule                100%        *
**************************************************************************/

@isTest
public class LiveChatTranscriptEventExpurgoBatchTest {
    @testSetup
    static void setup() {
        //insert custom setting
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c();
        setting.Name = 'DiasExpurgo';
        setting.DiasExpurgo__c = 90;
        insert setting;
         
        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        //insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        insert lct;
        
        system.debug('lct' + lct);
        
        //insert Live Chat Transcript Event
        LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
        le.LiveChatTranscriptId = lct.id;
        le.type = 'ChatRequest';
        le.time = system.now();
        le.CreatedDate = system.now().addDays(-80);
        insert le;

        LiveChatTranscriptEvent le2 = new LiveChatTranscriptEvent();
        le2.LiveChatTranscriptId = lct.id;
        le2.type = 'ChatRequest';
        le2.time = system.now();
        le2.CreatedDate = system.now().addDays(-95);
        insert le2;
    }
    
    @isTest 
    static void batchDeleteTest() {
        Test.startTest();
        LiveChatTranscriptEventExpurgoBatch.start();
        LiveChatTranscriptEventExpurgoBatch.start(8);       
        Test.stopTest();
        
        List<LiveChatTranscriptEvent> listEvent= [SELECT ID, CreatedDate FROM LiveChatTranscriptEvent];
        System.assertEquals(1, listEvent.size());
    }
    
    @isTest 
    static void SchedulableTest() {
        Test.startTest();
        String jobId1 = LiveChatTranscriptEventExpurgoSchedule.start();
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
        
        String jobId2 = LiveChatTranscriptEventExpurgoSchedule.start('0 0 2 * * ?');
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
        Test.stopTest();

        // Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct1.TimesTriggered);  
      	System.assertEquals(0, ct2.TimesTriggered); 
    }
}