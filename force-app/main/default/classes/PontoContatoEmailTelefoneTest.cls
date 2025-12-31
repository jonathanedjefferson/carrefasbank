@isTest
public class PontoContatoEmailTelefoneTest {
    @isTest
    public static void PontoContatoEmailTelefoneSchedulerAgendadoTest(){
        PontoContato__c pt = new PontoContato__c(
            Name = 'PontoContato',
            TodosRegistros__c = true
        );
        insert pt;
        
        Test.startTest();
        String jobId = PontoContatoEmailTelefoneScheduler.start();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();

        System.assertEquals(0, ct.TimesTriggered);
    }


    @isTest
    public static void PontoContatoEmailTelefoneSchedulerTest(){
        PontoContato__c pt = new PontoContato__c(
            Name = 'PontoContato',
            TodosRegistros__c = true
        );
        insert pt;

        // Define data de execução
        String CRON_EXP = '0 0 0 19 5 ? ***';       
        
		Test.startTest();
        String jobId = System.schedule('PontoContatoEmailTelefoneSchedulerTest', CRON_EXP, new PontoContatoEmailTelefoneScheduler());     
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 

        PontoContatoEmailTelefoneScheduler.start(CRON_EXP);
		Test.stopTest();
        
      	// Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct.TimesTriggered);     
    }

    @isTest
    public static void PontoContatoEmailTelefoneBatchTest(){
        List<ContaFinanceira__c> listCt = new List<ContaFinanceira__c>();
        List<sObject> listGeral = new List<sObject>();

        ContaFinanceira__c ct1 = new ContaFinanceira__c(
            NumeroConta__c = '000001'
        );
        ContaFinanceira__c ct2 = new ContaFinanceira__c(
            NumeroConta__c = '000002'
        );
        ContaFinanceira__c ct3 = new ContaFinanceira__c(
            NumeroConta__c = '000003'
        );
        
        listCt.add(ct1);
        listCt.add(ct2);
        listCt.add(ct3);
        insert listCt;
            


        PontoContatoEmail__c ctEm1 = new PontoContatoEmail__c(
            ContaFinanceira__c = ct1.Id,
            Email__c = 'conta01@gmail.com'
        );
        PontoContatoEmail__c ctEm2 = new PontoContatoEmail__c(
            ContaFinanceira__c = ct2.Id,
            Email__c = 'conta02@gmail.com'
        );
        PontoContatoEmail__c ctEm3 = new PontoContatoEmail__c(
            ContaFinanceira__c = ct3.Id,
            Email__c = 'conta03@gmail.com'
        );
        
        PontoContatoTelefone__c ctTe1 = new PontoContatoTelefone__c(
            ContaFinanceira__c = ct1.Id,
            Telefone__c = '11998015975'
        );
        PontoContatoTelefone__c ctTe2 = new PontoContatoTelefone__c(
            ContaFinanceira__c = ct2.Id,
            Telefone__c = '5511998015975'
        );
        PontoContatoTelefone__c ctTe3 = new PontoContatoTelefone__c(
            ContaFinanceira__c = ct3.Id,
            Telefone__c = '+55 (11) 9 9801-5975'
        );

        listGeral.add(ctEm1);
        listGeral.add(ctEm2);
        listGeral.add(ctEm3);
        listGeral.add(ctTe1);
        listGeral.add(ctTe2);
        listGeral.add(ctTe3);
        insert listGeral;

        PontoContato__c pt = new PontoContato__c(
            Name = 'PontoContato',
            TodosRegistros__c = true
        );
        insert pt;

        Test.StartTest();
        PontoContatoTelefoneBatch.start(5);
        PontoContatoEmailBatch.start(5);
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM ContaFinanceira__c WHERE Telefone__c != NULL]);
        System.assertEquals(0, [SELECT COUNT() FROM ContaFinanceira__c WHERE Email__c = NULL AND Telefone__c = NULL]);
    }

    @isTest
    public static void PontoContatoEmailFallBack(){
        List<ContaFinanceira__c> listCt = new List<ContaFinanceira__c>();
        List<sObject> listGeral = new List<sObject>();

        ContaFinanceira__c ct1 = new ContaFinanceira__c(
            NumeroConta__c = '000001',
            Email__c = 'conta01@gmail.com',
            Telefone__c = '000001'
        );
        ContaFinanceira__c ct2 = new ContaFinanceira__c(
            NumeroConta__c = '000002',
            Email__c = 'conta02@gmail.com',
            Telefone__c = '000002'
        );
        ContaFinanceira__c ct3 = new ContaFinanceira__c(
            NumeroConta__c = '000003',
            Email__c = 'conta03@gmail.com',
            Telefone__c = '000003'
        );
        
        listCt.add(ct1);
        listCt.add(ct2);
        listCt.add(ct3);
        insert listCt;
            
        
        Test.StartTest();
        PontoContatoEmailTelefoneBO.FallBackTotal();
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM ContaFinanceira__c WHERE Email__c != NULL OR Telefone__c != NULL]);
    }
}