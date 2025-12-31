@isTest
public class BCSF_CLS_CalculaTempoMilesTest {
    @TestSetup
    static void makeData(){
        
        // Create Account
        Id rtAct = [
            SELECT ID
            FROM RecordType
            WHERE DeveloperName = 'BCSF_RT_PAC_ClientePessoalCarrefour'
        ].Id;

        Account act = new Account(
            RecordTypeId = rtAct,
            FirstName = 'Teste',
            LastName = 'Account',
            CPF__c = '12345678910'
        );

        Database.insert(act);  
        
        // Create Entitlement
        List<SlaProcess> slaList = [
            SELECT Id
            FROM SlaProcess
            WHERE Name = 'bcsf atendimento'
                AND IsVersionDefault =: true
        ];

        Entitlement ent = new Entitlement(
            Name = 'Entitlement Teste',
            AccountId = act.Id,
            Type = 'Phone Support',
            StartDate = Date.today().addDays(-1),
            SlaProcessId = slaList[0].Id
        );

        Database.insert(ent);

        // Create Asssunto de Atendimento
        AssuntoAtendimento__c assuntoRec = new AssuntoAtendimento__c(
            PrazoAtendimentoBackofficeClientes__c = 5,
            PrazoAtendimentoBackofficeJuridico__c = 5,
            PrazoAtendimentoCanaisCriticos__c = 5,
            PrazoAtendimentoOuvidoria__c = 5,
            PrazoAtendimentoProcon__c = 6,
            PrazoConclusao2__c = 5,
            Assunto__c = 'Encargos, Tarifas e Anuidade'
        );

        Database.insert(assuntoRec);
        
        // Create User (Case Owner)
        Id prfId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'BCSF_PF_Banco Carrefour'
        ].Id;

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
            AreaPrincipal__c = 'ouvidoria',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Bypass__c = TRUE
        );

        Database.insert(usr);

        // Create Queue
        Group testGroup = [
            SELECT DeveloperName
            FROM Group
            WHERE DeveloperName = 'BCSF_QU_CAS_Ouvidoria'
        ];

        System.runAs(new User(Id=UserInfo.getUserId())){

            QueuesObject testQueue = new QueueSObject(
                QueueID = testGroup.id,
                SObjectType = 'Case'
            );

            Database.insert(testQueue);

        }
    
    }

    @isTest
    public static void testBothDatesFalse() {

        Id actId = [
            SELECT Id
            FROM Account
            WHERE Name = 'Teste Account'
        ].Id;

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
            WHERE Name = 'BCSF Atendimento'
                AND SObjectType = 'Case'
        ].Id;
        
        // Case 1 which owner is User from Ouvidoria
        Case cas1 = new Case(
            AccountId = actId,
            Type = 'Solicitação',
            EntitlementId = entId,
            RecordTypeId = rtCas,
            Priority = 'Medium',
            OwnerId = usrId,
            AreaProprietario__c = 'Ouvidoria',
            Origin = 'Ouvidoria',
            Status = 'New',
            Evento__c = 'Exceção',
            EnviarOuvidoria__c = 'Não',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            CampoControle__c = true,
            DataProrrogada__c = false,
            DataRegulatoria__c = null
        );

        Id queueId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = 'BCSF_QU_CAS_Ouvidoria'
                AND Type = 'Queue'
        ].Id;
        
        // Case 2 which owner is Ouvidoria Queue
        Case cas2 = new Case(
            AccountId = actId,
            Type = 'Solicitação',
            EntitlementId = entId,
            RecordTypeId = rtCas,
            Priority = 'Medium',
            OwnerId = queueId,
            AreaProprietario__c = 'Ouvidoria',
            Origin = 'Ouvidoria',
            Status = 'New',
            Evento__c = 'Exceção',
            EnviarOuvidoria__c = 'Não',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            CampoControle__c = true,
            DataProrrogada__c = false,
            DataRegulatoria__c = null
        );


        List<Case> caseList = new List<Case>();
        caseList.add(cas1);
        caseList.add(cas2);

        
        Test.startTest();
        List<Database.SaveResult> result = Database.insert(caseList);
        Test.stopTest();
    
        System.assertEquals(true, result[0].isSuccess());
        System.assertEquals(true, result[1].isSuccess());
        System.assertEquals(0, result[0].getErrors().size());
        System.assertEquals(0, result[1].getErrors().size());

    }

}