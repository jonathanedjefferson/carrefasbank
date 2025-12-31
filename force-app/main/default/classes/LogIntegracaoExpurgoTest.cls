/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - LogIntegracaoExpurgoBatch                             100%        *
*    - LogIntegracaoExpurgoSchedule                          100%        *
**************************************************************************/

@isTest
public class LogIntegracaoExpurgoTest {
    @testSetup
    static void setup() {
        //insert custom setting
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c();
        setting.Name = 'DiasExpurgoLogIntegracao';
        setting.DiasExpurgo__c = 90;
        insert setting;

        //insert Live Chat Transcript Event
        LogIntegracao__c le = new LogIntegracao__c();
        le.CPF__c = '12345678901';
        le.Metodo__c = 'GET';
        le.NomeServico__c = 'Teste';
        le.CreatedDate = system.now().addDays(-80);
        insert le;

        LogIntegracao__c le2 = new LogIntegracao__c();
        le2.CPF__c = '12345678901';
        le2.Metodo__c = 'GET';
        le2.NomeServico__c = 'Teste';
        le2.CreatedDate = system.now().addDays(-95);
        insert le2;
    }

    @isTest 
    static void batchDeleteTest() {
        Test.startTest();
        LogIntegracaoExpurgoBatch.start();  
        LogIntegracaoExpurgoBatch.start(8);
        Test.stopTest();
        
        List<LogIntegracao__c> listEvent = [SELECT Id, CreatedDate FROM LogIntegracao__c];
        System.assertEquals(1, listEvent.size());
    }

    @isTest 
    static void SchedulableTest() {
        Test.startTest();
        String jobId1 = LogIntegracaoExpurgoSchedule.start();
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
        
        String jobId2 = LogIntegracaoExpurgoSchedule.start('0 0 2 * * ?');
        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
        Test.stopTest();

        // Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct1.TimesTriggered);  
      	System.assertEquals(0, ct2.TimesTriggered);  
    }
}