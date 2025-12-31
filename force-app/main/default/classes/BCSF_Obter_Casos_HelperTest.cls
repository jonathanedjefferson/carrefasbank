@isTest
public with sharing class BCSF_Obter_Casos_HelperTest {
    @TestSetup
    static void makeData(){
        
        // Create Account
        Id rtAct = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'BCSF_RT_PAC_ClientePessoalCarrefour'
        ].Id;

        Account act = new Account(
            RecordTypeId = rtAct,
            LastName = 'Teste Account',
            CPF__c = '1234567891'
        );
        
        Database.insert(act);  

        Id actId = [
            SELECT Id
            FROM Account
            WHERE LastName = 'Teste Account'
        ].Id;

        // Create ContaFinanceira
        Id rtCon = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'BCSF_RT_CFI_ContaFinanceira'
        ].Id;

        ContaFinanceira__c con = new ContaFinanceira__c(
            RecordTypeId = rtCon,
            NomeCliente__c = actId,
            NumeroConta__c = '00977880022825672'
        );
        
        Database.insert(con);  

        Id conId = [
            SELECT Id
            FROM ContaFinanceira__c
            WHERE NumeroConta__c = '00977880022825672'
        ].Id;
        
        // Create Entitlement
        Entitlement ent = new Entitlement(
            Name = 'Entitlement Teste',
            AccountId = actId,
            Type = 'Phone Support',
            StartDate = Date.today().addDays(-1)
        );

        Database.insert(ent);
        
        Id prfId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'BCSF_PF_Banco Carrefour'
        ].Id;

        // Create User
        User usr = new User(
            LastName = 'User Teste 1',
            Alias = 'utester',
            Email = 'email@email.com',
            Username = 'usrname@test.com',
            CommunityNickname = 'nick',
            ProfileId = prfId,
            DRT__c = '12313534',
            TipodeTrabalho__c = 'Presencial',
            TipodeColaborador__c = 'DVA',
            UnidadedeNegocio__c = 'CRF',
            Departamento__c = 'Atendimento',
            AreaPrincipal__c = 'pos_vendas',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Bypass__c = TRUE
        );

        Database.insert(usr);
        
        Id usrId = [
            SELECT Id
            FROM User
            WHERE Username = 'usrname@test.com'
        ].Id;

        Id entId = [
            SELECT Id
            FROM Entitlement
            WHERE Name = 'Entitlement Teste'
        ].Id;

        Id rtCas = [
            SELECT Id
            FROM RecordType 
            WHERE DeveloperName = 'BCSF_RT_CAS_CasoChat'
                AND SObjectType = 'Case'
        ].Id;
        
        // Case 1 which owner is User from Canais Críticos
        Case cas1 = new Case(
            AccountId = actId,
            EntitlementId = entId,
            RecordTypeId = rtCas,
            Priority = 'Medium',
            OwnerId = usrId,
            Status = 'New',
            Type = 'Solicitação',
            Evento__c = 'Estorno de encargos, tarifas e anuidade',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            // ContaFinanceira__c = conId,
            CampoControle__c = TRUE
        );



        List<Case> caseList = new List<Case>();
        caseList.add(cas1);

        Database.insert(caseList);
    }

}