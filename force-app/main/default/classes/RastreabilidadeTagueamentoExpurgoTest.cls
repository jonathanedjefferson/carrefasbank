@isTest
private class RastreabilidadeTagueamentoExpurgoTest {
    @testSetup
    static void setup() {
        //insert custom setting
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c();
        setting.Name = 'DiasExpurgoRastreabilidade';
        setting.DiasExpurgo__c = 1;
        insert setting;

        //insert RastreabilidadeTagueamento
        RastreabilidadeTagueamento__c rastreabilidade = new RastreabilidadeTagueamento__c();
        rastreabilidade.Tagueamento__c = 'teste';
        rastreabilidade.CanalAtendimento__c = 'Atendimento Humano';
        rastreabilidade.DataHora__c = system.now().addDays(-2);
        insert rastreabilidade;

        RastreabilidadeTagueamento__c rastreabilidade2 = new RastreabilidadeTagueamento__c();
        rastreabilidade.Tagueamento__c = 'teste2';
        rastreabilidade.CanalAtendimento__c = 'Atendimento Humano';
        rastreabilidade.DataHora__c = system.now();
        insert rastreabilidade2;

    }

    @isTest
    public static void RastreabilidadeTagueamentoScheduleTest(){

        
        Test.startTest();
        String jobId = RastreabilidadeTagueamentoSchedule.start();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();

        System.assertEquals(0, ct.TimesTriggered);
    }
    @isTest
    public static void RastreabilidadeTagueamentoScheduleTest2(){
        String pCronExp = '0 0 * * * ?';
        Test.startTest();
        String jobId = RastreabilidadeTagueamentoSchedule.start(pCronExp);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();

        System.assertEquals(0, ct.TimesTriggered);
    }
    @isTest
    public static void RastreabilidadeTagueamentoBatchTest(){
        Test.startTest();
        RastreabilidadeTagueamentoExpurgoBatch.start(50);
        Test.stopTest();

        List<RastreabilidadeTagueamento__c> lstTagueamentos = [SELECT ID FROM RastreabilidadeTagueamento__c];
            
        System.assertNotEquals(null, lstTagueamentos);
    }
 
}