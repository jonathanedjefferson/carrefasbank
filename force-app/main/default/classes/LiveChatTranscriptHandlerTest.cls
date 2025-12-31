/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - LiveChatTranscriptTrigger (Trigger)        100%                   *
*    - LiveChatTranscriptHandler                  100%                   *
**************************************************************************/
@isTest
public class LiveChatTranscriptHandlerTest {
    @isTest
    public static void beforeUpdateTest(){
        // Insert Account
        Id rtAcc = [
            SELECT ID
            FROM RecordType
            WHERE Name = 'Cliente Carrefour'
        ].Id;

        Account acc = new Account(
            RecordTypeId = rtAcc,
            Name = 'Teste Account',
            CPF__c = '12345678910'
        );
        insert acc;

        // Insert ContaFinanceira__c
        ContaFinanceira__c ctfi = new ContaFinanceira__c(
            NomeCliente__c = acc.Id
        );
        insert ctfi;

        // Insert Case
        Id rtCs = [
            SELECT 
                Id
            FROM 
                RecordType 
            WHERE 
                DeveloperName = 'BCSF_PosVenda' AND SObjectType = 'Case'
        ].Id;

        Case cs = new Case(
            RecordTypeId = rtCs,
            Priority = 'Medium',
            Status = 'New',
            CanalEntrada__c = 'Chat',
            CPFContato__c = '42104961033',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            Evento__c = 'Anuidade',
            Origin = 'Pós Vendas',
            AccountId = acc.Id,
            NomeCliente__c = acc.Id
        );
        insert cs;


        // Insert Live Chat Visitor       
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        // Insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.AccountId = acc.Id;
        lct.ContaFinanceira__c = ctfi.Id;
        lct.caseId = cs.Id;
        insert lct;

        LiveChatTranscript lct02 = new LiveChatTranscript();
        lct02.LiveChatVisitorid = lcv.id;
        lct02.AccountId = acc.Id;
        lct02.ContaFinanceira__c = ctfi.Id;
        insert lct02;
        
        // Insert Live Chat Transcript Event
        LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
        le.LiveChatTranscriptId = lct.id;
        le.type = 'ChatRequest';
        le.time = system.now();
        insert le;


        Test.startTest();
        try {
            lct02.caseId = cs.Id;
            update lct02;
        } catch (Exception error) {
            Boolean expectedExceptionThrown =  error.getMessage().contains('Não é possível vincular o Caso a esta Transcrição!') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }


    @isTest
    public static void beforeUpdateTest02(){
        // Insert Account
        Id rtAcc = [
            SELECT ID
            FROM RecordType
            WHERE Name = 'Cliente Carrefour'
        ].Id;

        Account acc = new Account(
            RecordTypeId = rtAcc,
            Name = 'Teste Account',
            CPF__c = '12345678910'
        );
        insert acc;

        // Insert ContaFinanceira__c
        ContaFinanceira__c ctfi = new ContaFinanceira__c(
            NomeCliente__c = acc.Id
        );
        insert ctfi;

        // Insert Case
        Id rtCs = [
            SELECT 
                Id
            FROM 
                RecordType 
            WHERE 
                DeveloperName = 'BCSF_PosVenda' AND SObjectType = 'Case'
        ].Id;

        Case cs = new Case(
            RecordTypeId = rtCs,
            Priority = 'Medium',
            Status = 'New',
            CanalEntrada__c = 'Chat',
            CPFContato__c = '42104961033',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            Evento__c = 'Anuidade',
            Origin = 'Pós Vendas',
            AccountId = acc.Id,
            NomeCliente__c = acc.Id
        );
        insert cs;


        // Insert Live Chat Visitor       
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        // Insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.AccountId = acc.Id;
        lct.ContaFinanceira__c = ctfi.Id;
        insert lct;
        
        // Insert Live Chat Transcript Event
        LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
        le.LiveChatTranscriptId = lct.id;
        le.type = 'ChatRequest';
        le.time = system.now();
        insert le;


        Test.startTest();
        try {
            lct.caseId = cs.Id;
            update lct;
        } catch (Exception error) {
            Boolean expectedExceptionThrown =  error.getMessage().contains('Este Não é um Caso do Chat!') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
}