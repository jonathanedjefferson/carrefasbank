@isTest
public class FecharCasoExecucaoTeste {
    @isTest
    public static void FecharCasoExecucaoTeste01(){
        LiveChatVisitor visitor1 = new LiveChatVisitor();
        String recordTypeCase = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'BCSF_RT_CAS_CasoChat' LIMIT 1].Id;
        
        Case c1 = new Case();
        c1.CampoControle__c = true;
        c1.Description = 'Teste';
        c1.NomeContato__c = 'Teste'; 
        c1.CPFContato__c = '42104961033';
        c1.Evento__c = 'Falecimento';
        c1.Assunto__c = 'Bloqueio';
        c1.Type = 'Execução';
        c1.Status = 'New';
        c1.RecordTypeId = recordTypeCase;
        
        Case c2 = new Case();
        c2.CampoControle__c = true;
        c2.Description = 'Teste';
        c2.NomeContato__c = 'Teste';
        c2.CPFContato__c = '42104961033';
        c2.Type = 'Execução';
        c2.Evento__c = 'Falecimento';
        c2.Assunto__c = 'Bloqueio';
        c2.Status = 'New';
        c2.RecordTypeId = recordTypeCase;
        
        Case c3 = new Case();
        c3.CampoControle__c = true;
        c3.Description = 'Teste';
        c3.NomeContato__c = 'Teste';
        c3.CPFContato__c = '42104961033';
        c3.Type = 'Execução';
        c3.Evento__c = 'Falecimento';
        c3.Assunto__c = 'Bloqueio';
        c3.Status = 'New';
        c3.RecordTypeId = recordTypeCase;
        
        List<sObject> listObject = new List<sObject>();
        listObject.add(visitor1);
        listObject.add(c1);
        listObject.add(c2);
        listObject.add(c3);
        insert listObject;
        
        LiveChatTranscript transcript1 = new LiveChatTranscript();
        transcript1.ChaveContaFinanceira__c = '1fdfd';
        transcript1.ChaveCartao__c = '2fdfd';
        transcript1.CaseId = c1.Id;
        transcript1.LiveChatVisitorId = visitor1.Id;
        transcript1.Status = 'Completed';
        
        LiveChatTranscript transcript2 = new LiveChatTranscript();
        transcript2.ChaveContaFinanceira__c = '3fdfd';
        transcript2.ChaveCartao__c = '4fdfd';
        transcript2.CPF__c = '99999999900';
        transcript2.CaseId = c2.Id;
        transcript2.LiveChatVisitorId = visitor1.Id;
        transcript2.Status = 'Completed';
        
        LiveChatTranscript transcript3 = new LiveChatTranscript();
        transcript3.ChaveContaFinanceira__c = '5555500071';
        transcript3.ChaveCartao__c = '12345';
        transcript3.CPF__c = '99999999988';
        transcript3.CaseId = c3.Id;
        transcript3.LiveChatVisitorId = visitor1.Id;
        transcript3.Status = 'Completed';
        
        List<LiveChatTranscript> listTranscript = new List<LiveChatTranscript>();
        listTranscript.add(transcript1); 
        listTranscript.add(transcript2);
        listTranscript.add(transcript3);
        insert listTranscript;

        Test.startTest();
        String jobId = FecharCasoExecucaoScheduler.start();
        FecharCasoExecucaoBatch.start(50);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();

        System.assertEquals(0, ct.TimesTriggered);
    }

    /* @isTest(SeeAllData=true) 
    public static void FecharCasoExecucaoTeste02(){
        String recordTypeCase = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'BCSF_RT_CAS_CasoChat' LIMIT 1].Id;
        
        Case c1 = new Case();
        c1.CampoControle__c = true;
        c1.Description = 'Teste';
        c1.NomeContato__c = 'Teste'; 
        c1.CPFContato__c = '42104961033';
        c1.Type = 'Execução';
        c1.Status = 'New';
        c1.Evento__c = 'Falecimento';
        c1.Assunto__c = 'Bloqueio';
        c1.RecordTypeId = recordTypeCase;
        
        Case c2 = new Case();
        c2.CampoControle__c = true;
        c2.Description = 'Teste';
        c2.NomeContato__c = 'Teste';
        c2.CPFContato__c = '42104961033';
        c2.Type = 'Execução';
        c2.Status = 'New';
        c2.Evento__c = 'Falecimento';
        c2.Assunto__c = 'Bloqueio';
        c2.RecordTypeId = recordTypeCase;
        
        Case c3 = new Case();
        c3.CampoControle__c = true;
        c3.Description = 'Teste';
        c3.NomeContato__c = 'Teste';
        c3.CPFContato__c = '42104961033';
        c3.Type = 'Execução';
        c3.Status = 'New';
        c3.Evento__c = 'Falecimento';
        c3.Assunto__c = 'Bloqueio';
        c3.RecordTypeId = recordTypeCase;
        
        List<sObject> listObject = new List<sObject>();
        listObject.add(c1);
        listObject.add(c2);
        listObject.add(c3);
        insert listObject;

        List<MessagingSession> listMessaging = [
            SELECT Id, Status, CaseId
            FROM MessagingSession 
            WHERE Status = 'Ended'
            LIMIT 3
        ];
        listMessaging[0].CaseId = c1.Id;
        listMessaging[1].CaseId = c2.Id;
        listMessaging[2].CaseId = c3.Id;
        update listMessaging;

        // Define data de execução
        String CRON_EXP = '0 0 0 19 5 ? ***';       
        
		Test.startTest();
        // FecharCasoExecucaoScheduler.start(CRON_EXP);
        String jobId = System.schedule('FecharCasoExecucaoSchedulerTest', CRON_EXP, new FecharCasoExecucaoScheduler());     
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 

		Test.stopTest();
        
      	// Verifica se o trabalho não foi executado 
      	System.assertEquals(0, ct.TimesTriggered);     
    } */
}