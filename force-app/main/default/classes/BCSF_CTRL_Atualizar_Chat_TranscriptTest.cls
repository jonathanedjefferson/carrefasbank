@isTest
public class BCSF_CTRL_Atualizar_Chat_TranscriptTest {
     
    @TestSetup static void makeData1(){
            Account acc1 = new Account();
            acc1.CPF__c = '99999999901';
            acc1.Name = 'x';
            Account acc2 = new Account();
            acc2.Name = 'y';
            acc2.CPF__c = '99999999902';

            try{
                Database.insert(acc1);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            try{
                Database.insert(acc2);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            LiveChatVisitor visitor1 = new LiveChatVisitor();

            try{
                Database.insert(visitor1);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            LiveChatVisitor visitor2 = new LiveChatVisitor();

            try{
                Database.insert(visitor2);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            LiveChatVisitor visitor3 = new LiveChatVisitor();

            try{
                Database.insert(visitor3);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            LiveChatTranscript transcript1 = new LiveChatTranscript();
            transcript1.ChaveContaFinanceira__c = '1fdfd';
            transcript1.ChaveCartao__c = '2fdfd';
            transcript1.LiveChatVisitorId = visitor1.Id;

            LiveChatTranscript transcript2 = new LiveChatTranscript();
            transcript2.ChaveContaFinanceira__c = '3fdfd';
            transcript2.ChaveCartao__c = '4fdfd';
            transcript2.CPF__c = '99999999900';
            transcript2.LiveChatVisitorId = visitor2.Id;

            LiveChatTranscript transcript3 = new LiveChatTranscript();
            transcript3.ChaveContaFinanceira__c = '5555500071';
            transcript3.ChaveCartao__c = '12345';
            transcript3.CPF__c = '99999999988';
            transcript3.PrimeiroNome__c = 'Billy';
            transcript3.Sobrenome__c = 'Paul Jhones';
            transcript3.LiveChatVisitorId = visitor3.Id;

            ContaFinanceira__c contaf1 = new ContaFinanceira__c();
            contaf1.NumeroConta__c = transcript1.ChaveContaFinanceira__c;
            contaf1.AutorizaContatoAcoesPromocionais__c  = TRUE;
            contaf1.NomeCliente__c = acc1.Id;
        
            Asset ativo1 = new Asset();
            ativo1.NumeroCartao__c = transcript1.ChaveCartao__c;
            ativo1.Name = 'xs';
            ativo1.AccountId = acc1.Id;

            Asset ativo2 = new Asset();
            ativo2.NumeroCartao__c = transcript2.ChaveCartao__c;
            ativo2.Name = 'xy';
            ativo2.AccountId = acc1.Id;

            contaf1.NomeCliente__c = acc1.Id;
 
            try{
                Database.insert(transcript1);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            try{
                Database.insert(transcript2);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            try{
                Database.insert(transcript3);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            try{
                Database.insert(contaf1);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            try{
                Database.insert(ativo1);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

            try{
                Database.insert(ativo2);
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

        }
    

    @isTest static void testContaFExists() {

        LiveChatTranscript transcript_1 = [SELECT Id, ChaveContaFinanceira__c, ChaveCartao__c, AccountId, Cartao__c FROM LiveChatTranscript WHERE ChaveContaFinanceira__c = '1fdfd'];
        ContaFinanceira__c contaf1 = [SELECT Id, NumeroConta__c, NomeCliente__r.Id FROM ContaFinanceira__c WHERE NumeroConta__c = '1fdfd'];
        Asset ativo1 = [SELECT Id, NumeroCartao__c FROM Asset WHERE NumeroCartao__c = '2fdfd'];

        transcript_1.CPF__c = '99999999901';
        string result1 = contaf1.NomeCliente__r.Id;
        string result2 = contaf1.Id;
        string result3 = ativo1.Id;

        Test.startTest();
        try{
            System.enqueueJob(new BCSF_CTRL_Atualizar_Chat_Transcript(transcript_1.Id));
            Database.update(transcript_1);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();

        LiveChatTranscript transcript_after = [SELECT Id, ContaFinanceira__c, ChaveContaFinanceira__c, ChaveCartao__c, AccountId, Cartao__c FROM LiveChatTranscript WHERE ChaveContaFinanceira__c = '1fdfd'];

        System.assertEquals(transcript_after.AccountId, result1);
        System.assertEquals(transcript_after.ContaFinanceira__c, result2);
        System.assertEquals(transcript_after.Cartao__c, result3);

    }

  @isTest static void testContaFDontExists() {

        LiveChatTranscript transcript_2 = [SELECT Id, ChaveContaFinanceira__c, ChaveCartao__c, Cartao__c, AccountId FROM LiveChatTranscript WHERE ChaveContaFinanceira__c = '3fdfd'];
        Account acc_2 = [SELECT Id, CPF__c FROM Account WHERE CPF__c = '99999999901'];
        Asset ativo_2 = [SELECT Id, NumeroCartao__c FROM Asset WHERE NumeroCartao__c = '4fdfd'];

        transcript_2.CPF__c = '99999999901';
        Test.startTest();
        try{
            System.enqueueJob(new BCSF_CTRL_Atualizar_Chat_Transcript(transcript_2.Id));
            Database.update(transcript_2);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();

        LiveChatTranscript transcript_after = [SELECT Id, ChaveContaFinanceira__c, ChaveCartao__c, Cartao__c, AccountId FROM LiveChatTranscript WHERE ChaveContaFinanceira__c = '3fdfd'];

        string result1 = acc_2.Id;
        string result2 = ativo_2.Id;
        System.assertEquals(transcript_after.AccountId, result1);
        System.assertEquals(transcript_after.Cartao__c, result2);
        
    }

    @isTest static void testContaFAndCpfDontExists() {

        LiveChatTranscript transcript_3 = [SELECT Id, CPF__c, PrimeiroNome__c, Sobrenome__c, AccountId FROM LiveChatTranscript WHERE ChaveContaFinanceira__c = '5555500071'];


        transcript_3.CPF__c = '99999999977';
        Test.startTest();
        try{
            Database.update(transcript_3);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();

        LiveChatTranscript transcript_after = [SELECT Id, CPF__c, PrimeiroNome__c, Sobrenome__c, AccountId FROM LiveChatTranscript WHERE ChaveContaFinanceira__c = '5555500071'];
        string result1 = 'Billy';
        string result2 = 'Paul Jhones';
        string result3 = '99999999977';
        string result4 = null;

        System.assertEquals(result1, transcript_after.PrimeiroNome__c);
        System.assertEquals(result2, transcript_after.Sobrenome__c);
        System.assertEquals(result3, transcript_after.CPF__c);
 
    }

}