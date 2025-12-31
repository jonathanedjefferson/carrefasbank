@isTest
private class ReportsSchedulerTest {
    
    @isTest
    static void testScheduleJob() {
        // Criação de uma instância da classe ReportsScheduler
        ReportsScheduler scheduler = new ReportsScheduler();
        
        scheduler.cron = '0 0 6 * * ?'; // Exemplo: Todos os dias às 6h da manhã
        scheduler.jobName = 'Daily Reports Scheduler';
     
        
        Test.startTest();
        Id jobId = scheduler.scheduleJob();
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE id =: jobId LIMIT 1];
        
        
        System.assertEquals(scheduler.cron, ct.CronExpression, 'A expressão cron deve coincidir.');
        System.assertNotEquals(null, ct.NextFireTime, 'O próximo horário de execução não deve ser nulo.');
    }
    
    @isTest
    static void testExecute() {
        // Criação de um mock para a classe ReportController
        Test.startTest();
        ReportsScheduler scheduler = new ReportsScheduler();
        scheduler.execute(null);
        Test.stopTest();
    }
}