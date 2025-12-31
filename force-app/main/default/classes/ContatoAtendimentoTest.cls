/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ContatoAtendimentoBO                       100%                   *
*    - ContatoAtendimentoDAO                      100%                   *
*    - ContatoAtendimentoBatch                    100%                   *
*    - ContatoAtendimentoSchedule                 100%                   *
**************************************************************************/
@isTest
public class ContatoAtendimentoTest {
    @TestSetup
    static void setup(){
        PontoContato__c pt = new PontoContato__c(
            Name = 'PontoContato',
            TodosRegistros__c = true
        );
        insert pt;

        ContaFinanceira__c ct1 = new ContaFinanceira__c(
            NumeroConta__c = '000001'
        );
        
        insert ct1;

        ContatoAtendimento__C cA1 = new ContatoAtendimento__c(
            ContaFinanceira__c = ct1.Id,
            Name = 'Jane Doe',
            Telefone__c = '11992978739',
            Email__c = 'janedoe@carrefour.com',
            NewValue__c = true
        );
        
        insert cA1;

        List<ContaFinanceira__c> listCt = new List<ContaFinanceira__c>();
        ContaFinanceira__c cf1 = new ContaFinanceira__c(
            NumeroConta__c = '000001',
            Email__c = 'conta01@gmail.com',
            Telefone__c = '000001'
        );
        ContaFinanceira__c cf2 = new ContaFinanceira__c(
            NumeroConta__c = '000002',
            Email__c = 'conta02@gmail.com',
            Telefone__c = '000002'
        );
        ContaFinanceira__c cf3 = new ContaFinanceira__c(
            NumeroConta__c = '000003',
            Email__c = 'conta03@gmail.com',
            Telefone__c = '000003'
        );
        
        listCt.add(cf1);
        listCt.add(cf2);
        listCt.add(cf3);
        insert listCt;
    }

    @isTest
    public static void ContatoAtendimentoScheduleTest(){
        String pCronExp = '0 0 2 * * ?';

        Test.startTest();
        ContatoAtendimentoSchedule.start(pCronExp);
        String jobId = ContatoAtendimentoSchedule.start();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();
        
        System.assertEquals(0, ct.TimesTriggered);
    }

    @isTest
    public static void ContatoAtendimentoBatchTestCom55(){
        String RecTypeId= [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND (Name = 'Conta pessoal' OR Name='Person Account')].Id;
        Account acc1 = new Account(
            RecordTypeID = RecTypeId,
            CPF__c = '99999999901',
            LastName = 'x1'
        );
        insert acc1;

        ContaFinanceira__c ct1 = new ContaFinanceira__c(
            NumeroConta__c = '000001',
            NomeCliente__c = acc1.Id,
            IdConta__c = '123'
        );
        insert ct1;

        ContatoAtendimento__C cA2 = new ContatoAtendimento__c(
            ContaFinanceira__c = ct1.Id,
            Name = 'Jhon Doe',
            Telefone__c = '5511992978739',
            Email__c = 'jhondoe@carrefour.com',
            NumeroConta__c = '123'
        );
        insert cA2;

        Test.StartTest();
        ContatoAtendimentoBatch.start();
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM ContaFinanceira__c WHERE Email__c = NULL AND Telefone__c = NULL]);
    }

    @isTest
    public static void ContatoAtendimentoBatchTestSem55(){

        Test.StartTest();
        ContatoAtendimentoBatch.start();
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM ContaFinanceira__c WHERE Email__c = NULL AND Telefone__c = NULL]);
    }

   @isTest
    public static void ContatoAtendimentoFallBack(){    
        
        Test.StartTest();
        ContatoAtendimentoBO.FallBackTotal();
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM ContaFinanceira__c WHERE Email__c != NULL OR Telefone__c != NULL]);
    }
}