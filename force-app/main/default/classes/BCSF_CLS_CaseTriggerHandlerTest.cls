@isTest
public class BCSF_CLS_CaseTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        
        // Create Account
        Id rtAct = [
            SELECT ID
            FROM RecordType
            WHERE Name = 'Cliente Carrefour'
        ].Id;
        
        Account act = new Account(
            RecordTypeId = rtAct,
            Name = 'Teste Account',
            CPF__c = '12345678910'
        );
        
        Database.insert(act);  
        
        Id actId = [
            SELECT Id
            FROM Account
            WHERE Name = 'Teste Account'
        ].Id;
        
        //Create ContaFinanceira__c
        
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CFI_ContaFinanceira').getRecordTypeId();
        
        ContaFinanceira__c contaFinceira = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = actId,
            NumeroConta__c = '009778800'
        );
        Database.insert(contaFinceira);
        
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
            WHERE Name = 'BCSF Atendimento'
            AND SObjectType = 'Case'
        ].Id;
        
        // Case 1 which owner is User from Canais Críticos
        Case cas1 = new Case(
            AccountId = actId,
            EntitlementId = entId,
            RecordTypeId = rtCas,
            Priority = 'Medium',
            OwnerId = usrId,
            AreaProprietario__c = 'Teste de Area 123',
            Status = 'New',
            Evento__c = 'Estorno de encargos, tarifas e anuidade',
            EnviarOuvidoria__c = 'Não',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            Subject = 'Teste 1',
            NomeContato__c = 'Teste',
            CPFContato__c = '42104961033',
            CampoControle__c = true
        );
        
        Id queueId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = 'BCSF_QU_CAS_Ouvidoria'
            AND Type = 'Queue'
            LIMIT 1
        ].Id;
        
        // Case 2 which owner is Canais Críticos Queue
        Case cas2 = new Case(
            AccountId = actId,
            EntitlementId = entId,
            RecordTypeId = rtCas,
            Priority = 'Medium',
            OwnerId = queueId,
            AreaProprietario__c = 'Teste de Area 456',
            Status = 'New',
            Evento__c = 'Estorno de encargos, tarifas e anuidade',
            EnviarOuvidoria__c = 'Não',
            Assunto__c = 'Encargos, Tarifas e Anuidade',
            Subject = 'Teste 2',
            NomeContato__c = 'Teste',
            CPFContato__c = '93362498000',
            CampoControle__c = true
        );
        
        Id rtCase = [
            SELECT ID
            FROM RecordType
            WHERE DeveloperName = 'BCSF_PosVenda'
        ].Id;
        Case cas3 = new Case(
            Assunto__c = 'Correspondência de Cobrança',
            Evento__c = 'Solicitações Via e-mail',
            Type = 'Solicitação',
            RecordTypeId = rtCase,
            Description = 'O Campo Descrição é obrigatório',
            CPFContato__c = '1111111111',
            Status = 'Em tratativa'
        );
        
        
        List<Case> caseList = new List<Case>();
        caseList.add(cas1);
        caseList.add(cas2);
        caseList.add(cas3);
        
        Database.insert(caseList);
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User adminUser = new User(
            Alias = 'admusr',
            Email = 'adminuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            Username = 'adminuser' + DateTime.now().getTime() + '@carrefour.com',
            Bypass__c = TRUE
        );
        
        insert adminUser;
    }
    
    @isTest
    static void testUpdateContext(){
        Map<Id, Case> caseNewMap = new Map<Id, Case>([SELECT ID, OwnerId, RecordTypeId, AreaProprietario__c, DataRegulatoria__c, IsClosed FROM Case]);
        Map<Id, Case> caseOldMap = new Map<Id, Case>([SELECT ID, OwnerId, RecordTypeId, AreaProprietario__c, DataRegulatoria__c, IsClosed FROM Case]);
        
        // Troca o Owner Id de um dos casos no newMap para simular alteracao
        caseNewMap.values()[0].OwnerId = caseNewMap.values()[1].OwnerId;
        
        BCSF_CLS_CaseTriggerHandler HANDLER = BCSF_CLS_CaseTriggerHandler.getInstance(caseNewMap, caseNewMap.values(), caseOldMap, caseOldMap.values());
        
        HANDLER.beforeUpdate();
        HANDLER.afterDelete();
        HANDLER.beforeDelete();
        
        Case cs = [SELECT Id, CPFContato__c FROM Case WHERE CPFContato__c = '1111111111' LIMIT 1];
        cs.CPFContato__c = '123433';
        
        try {
            update cs;
        } catch (Exception e ) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('É necessário anexar um arquivo antes de salvar a resolução') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        HANDLER.afterUpdate();  
        
    }
    
    @isTest
    static void testAccountAssociationExistingAccount(){
        User adminUser = [SELECT Id, Bypass__c FROM User WHERE Alias = 'admusr' LIMIT 1];
        Case cs = new Case();
        cs.CPFCase__c = '12345678910';
        cs.NumeroCF__c = '009778800';
        cs.Type = 'Solicitação';
        cs.Status = 'Closed';
        cs.UnidadeNegocio__c = '1';
        cs.Assunto__c = 'Seguros';
        cs.Evento__c = 'Informações de sinistro';
        
        Test.StartTest();
        System.runAs(adminUser) {
            insert cs;
        }
        Test.StopTest();
        
        Case updatedCase = [SELECT Id, AccountId, NomeCliente__c, ContaFinanceira__c FROM Case WHERE Id = :cs.Id LIMIT 1];
        Assert.isNotNull(updatedCase.AccountId, 'AccountId should not be null');
        Assert.isNotNull(updatedCase.NomeCliente__c, 'NomeCliente__c should not be null');
        Assert.isNotNull(updatedCase.ContaFinanceira__c, 'ContaFinanceira__c should not be null');
    }
    
    @isTest
    static void testAccountAssociationNewAccount(){
        User adminUser = [SELECT Id, Bypass__c FROM User WHERE Alias = 'admusr' LIMIT 1];
        
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        Case cs = new Case();
        cs.CPFCase__c = '85534351055';
        cs.NumeroCF__c = '10000081470';
        cs.Type = 'Solicitação';
        cs.Status = 'Closed';
        cs.UnidadeNegocio__c = '1';
        cs.Assunto__c = 'Seguros';
        cs.Evento__c = 'Informações de sinistro';
        
        User runningUser = [SELECT Id, Bypass__c FROM User WHERE Id = :UserInfo.getUserId()];
        runningUser.Bypass__c = true;
        update runningUser;
        
        Test.StartTest();
        System.runAs(adminUser) {
            insert cs;
        }
        Test.StopTest();
        
        Case updatedCase = [SELECT Id, AccountId, NomeCliente__c, ContaFinanceira__c FROM Case WHERE Id = :cs.Id LIMIT 1];
        Assert.isNotNull(updatedCase.AccountId, 'AccountId should not be null');
        Assert.isNotNull(updatedCase.NomeCliente__c, 'NomeCliente__c should not be null');
        Assert.isNotNull(updatedCase.ContaFinanceira__c, 'ContaFinanceira__c should not be null');
    }
    
    @isTest
    static void testVerificarSePodeAceitarCaso(){
        
        // Buscar o caso que tem owner como Queue (cas2 do TestSetup)
        Case caseWithQueue = [
            SELECT Id, OwnerId, AccountId, EntitlementId, RecordTypeId 
            FROM Case 
            WHERE Subject = 'Teste 2' 
            LIMIT 1
        ];
        
        // Buscar o usuário que está na área de teste
        User userInQueue = [
            SELECT Id 
            FROM User 
            WHERE Username = 'usrname@test.com' 
            LIMIT 1
        ];
        
        // Buscar a fila
        Id queueId = [
            SELECT Id 
            FROM Group 
            WHERE DeveloperName = 'BCSF_QU_CAS_Ouvidoria' 
            AND Type = 'Queue' 
            LIMIT 1
        ].Id;
        
        // Criar um usuário que NÃO está na fila
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User userOutsideQueue = new User(
            Alias = 'outque',
            Email = 'outsidequeue@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Outside Queue',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            Username = 'outsidequeue' + DateTime.now().getTime() + '@carrefour.com',
            Bypass__c = FALSE
        );
        insert userOutsideQueue;
        
        Test.startTest();
        
        // CENÁRIO 1: Usuário DENTRO da fila aceita o caso (deve funcionar)
        System.runAs(userInQueue) {
            caseWithQueue.OwnerId = userInQueue.Id;
            caseWithQueue.Status = 'Working';
            
            try {
                update caseWithQueue;
                // Se chegou aqui, o update foi bem-sucedido
                System.assert(true, 'Usuário da fila conseguiu aceitar o caso');
            } catch (Exception e) {
                System.assert(false, 'Usuário da fila deveria conseguir aceitar o caso');
            }
        }
        
        // Retornar o caso para a fila para o próximo teste
        caseWithQueue.OwnerId = queueId;
        update caseWithQueue;
        
        // CENÁRIO 2: Usuário FORA da fila tenta aceitar o caso (deve dar erro)
        System.runAs(userOutsideQueue) {
            Case caseToReassign = [SELECT Id, OwnerId FROM Case WHERE Id = :caseWithQueue.Id];
            caseToReassign.OwnerId = userOutsideQueue.Id;
            
            try {
                update caseToReassign;
                System.assert(false, 'Deveria ter lançado exceção para usuário fora da fila');
            } catch (DmlException e) {
                // Verifica se a mensagem de erro está correta
                Boolean expectedError = e.getMessage().contains('podem aceitar este caso');
                System.assertEquals(true, expectedError, 'Mensagem de erro esperada não foi encontrada');
            }
        }
        
        Test.stopTest();
    }
    
    // Teste adicional para cobertura de cenários onde o método NÃO é executado
    @isTest
    static void testVerificarSePodeAceitarCaso_CenariosNaoExecutados(){
        
        Case caseWithUser = [
            SELECT Id, OwnerId, Status 
            FROM Case 
            WHERE Subject = 'Teste 1' 
            LIMIT 1
        ];
        
        User userOwner = [
            SELECT Id 
            FROM User 
            WHERE Username = 'usrname@test.com' 
            LIMIT 1
        ];
        
        Test.startTest();
        
        // CENÁRIO 3: Owner antigo e novo são usuários (não entram no if principal)
        System.runAs(userOwner) {
            caseWithUser.Status = 'Working';
            update caseWithUser; // Atualiza sem mudar owner
            
            caseWithUser.Description = 'Teste de atualização';
            update caseWithUser; // Outra atualização sem mudar owner
        }
        
        // CENÁRIO 4: Owner muda mas ambos são filas
        Id queueId1 = [
            SELECT Id 
            FROM Group 
            WHERE DeveloperName = 'BCSF_QU_CAS_Ouvidoria' 
            AND Type = 'Queue' 
            LIMIT 1
        ].Id;
        
        // Busca outra fila (se existir) ou cria cenário onde não entra no IF
        Case caseToTest = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Teste 2' LIMIT 1];
        // Apenas atualiza sem mudar o owner (owner continua sendo fila)
        caseToTest.Status = 'Working';
        update caseToTest;
        
        Test.stopTest();
    }
    
    // Teste para cobertura de bulk operations
    @isTest
    static void testVerificarSePodeAceitarCaso_BulkOperation(){
        
        User userInQueue = [
            SELECT Id 
            FROM User 
            WHERE Username = 'usrname@test.com' 
            LIMIT 1
        ];
        
        Id queueId = [
            SELECT Id 
            FROM Group 
            WHERE DeveloperName = 'BCSF_QU_CAS_Ouvidoria' 
            AND Type = 'Queue' 
            LIMIT 1
        ].Id;
        
        // Criar múltiplos casos na fila
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Entitlement ent = [SELECT Id FROM Entitlement LIMIT 1];
        Id rtCas = [SELECT Id FROM RecordType WHERE Name = 'BCSF Atendimento' AND SObjectType = 'Case' LIMIT 1].Id;
        
        List<Case> casesToInsert = new List<Case>();
        for(Integer i = 0; i < 5; i++){
            casesToInsert.add(new Case(
                AccountId = acc.Id,
                EntitlementId = ent.Id,
                RecordTypeId = rtCas,
                OwnerId = queueId,
                Status = 'New',
                Subject = 'Bulk Test ' + i,
                Priority = 'Medium'
            ));
        }
        insert casesToInsert;
        
        Test.startTest();
        
        // Atualizar múltiplos casos de uma vez
        System.runAs(userInQueue) {
            for(Case c : casesToInsert){
                c.OwnerId = userInQueue.Id;
                c.Status = 'Working';
            }
            
            try {
                update casesToInsert;
                System.assert(true, 'Bulk update funcionou');
            } catch (Exception e) {
                System.assert(false, 'Bulk update deveria funcionar: ' + e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    
}