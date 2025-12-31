/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ContentDocumentExpurgoBatch                             100%      *
*    - ContentDocumentExpurgoSchedule                          100%      *
*    - ExpurgoFileVarejoBatch                                  100%      *
**************************************************************************/

@isTest
public class ContentDocumentExpurgoTest {

    @testSetup
    static void makeData() {
        //insert custom setting
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c();
        setting.Name = 'DiasExpurgoContentDocument';
        setting.DiasExpurgo__c = 0;
        insert setting;

        Blob bodyBlob=Blob.valueOf('arquivo'); 
            
        ContentVersion ctVersion1 = new ContentVersion(
                Title='Fatura - Teste', 
                PathOnClient ='Fatura - Teste.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
        );
        insert ctVersion1;

              
        ContentVersion ctVersion2= new ContentVersion(
                Title='Fatura - Teste', 
                PathOnClient ='Fatura - Teste.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                CreatedDate = System.now().addDays(-1)
        );
        insert ctVersion2;


        ContentVersion ctVersion3 = new ContentVersion(
                Title='VAREJONF.pdf', 
                PathOnClient ='VAREJONF.pdf',
                VersionData = bodyBlob, 
                origin = 'H'
        );
        insert ctVersion3;

              
        ContentVersion ctVersion4= new ContentVersion(
                Title='VAREJONF.pdf', 
                PathOnClient ='VAREJONF.pdf',
                VersionData = bodyBlob, 
                origin = 'H',
                CreatedDate = System.now().addDays(-1)
        );
        insert ctVersion4;
    }

    @isTest 
    static void batchDeleteTest() {
        Test.startTest();
        ContentDocumentExpurgoBatch.start();  
        ContentDocumentExpurgoBatch.start(8);
        
        ExpurgoFileVarejoBatch.start();  
        ExpurgoFileVarejoBatch.start(8);
        Test.stopTest();
        
        List<ContentDocument> lstDocuments = [SELECT Id FROM ContentDocument];
        System.assertEquals(2, lstDocuments.size());
    }

    @isTest 
    static void SchedulableTest() {
        Test.startTest();
        String jobId1 = ContentDocumentExpurgoSchedule.start();
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
        
        String jobId2 = ContentDocumentExpurgoSchedule.start('0 0 2 * * ?');
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
        Test.stopTest();

        // Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct1.TimesTriggered);  
      	System.assertEquals(0, ct2.TimesTriggered);  
    }
}