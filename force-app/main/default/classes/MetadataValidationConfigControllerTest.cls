@IsTest
private class MetadataValidationConfigControllerTest {
    
    @TestSetup
    static void makeData(){
        
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c
            .getRecordTypeInfosByDeveloperName()
            .get('BCSF_RT_CFI_ContaFinanceira')
            .getRecordTypeId();
        
        String recordTypeIdContaPessoal = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('BCSF_RT_PAC_ClientePessoalCarrefour')
            .getRecordTypeId();
        
        Account accountNomeCliente = new Account(
            RecordTypeId = recordTypeIdContaPessoal,
        LastName = 'Teste Account',
        CPF__c = '49599020006'
            );
        insert accountNomeCliente;
        
        List<ContaFinanceira__c> contas = new List<ContaFinanceira__c>{
            new ContaFinanceira__c(
                RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroConta__c = '00977880022825672',
            DataLimiteDesbloqueio__c = System.now().addDays(2),
            UltimoOperador__c = UserInfo.getUserId()
                ),
            new ContaFinanceira__c(
                RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroConta__c = '55667788990011223',
            DataLimiteDesbloqueio__c = System.now().addDays(5),
            UltimoOperador__c = UserInfo.getUserId()
                )
        };
        insert contas;
        
        insert new PerfisBypass__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
        Perfis__c = 'Administrador;Supervisor;Financeiro'
            );
        
    }
    
    
    @IsTest
    static void testGetUserValidationData_Sucesso() {
        
        User testUser = [
            SELECT Id, Profile.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        Test.startTest();
        MetadataValidationConfigTO.MetadataValidationUserWrapper result =
            MetadataValidationConfigController.GetUserValidationData(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.perfisBypass.contains('Administrador'));
        System.assertEquals(testUser.Profile.Name, result.perfilUsuario);
    }
    
    
    @IsTest
    static void testGetTempoLimiteCF() {
        
        Test.startTest();
        Integer result = MetadataValidationConfigController.GetTempoLimiteCF();
        Test.stopTest();
        
        System.assertEquals(15, result, 'O tempo limite deve vir do Custom Metadata');
    }
    
    
    @IsTest
    static void testGetPerfisCF() {
        
        Test.startTest();
        String result = MetadataValidationConfigController.GetPerfisCF();
        Test.stopTest();
        
        System.assert(result.contains('Administrador'));
        System.assert(result.contains('Supervisor'));
    }
    
    
    @IsTest
    static void testGetAllValidationData_Sucesso() {
        
        ContaFinanceira__c conta = [
            SELECT Id, DataLimiteDesbloqueio__c, UltimoOperador__c
            FROM ContaFinanceira__c
            LIMIT 1
        ];
        
        User u = [
            SELECT Id, Profile.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        Test.startTest();
        MetadataValidationConfigTO.MetadataValidationWrapper result =
            MetadataValidationConfigController.GetAllValidationData(conta.Id, u.Id);
        Test.stopTest();
        System.debug('result'+ result);
        System.assertNotEquals(null, result);
        System.assertEquals(15, result.tempoLimite);
        System.assert(result.perfisBypass.contains('Administrador'));
        System.assertEquals(u.Profile.Name, result.perfilUsuario);
        System.assertEquals(conta.DataLimiteDesbloqueio__c, result.dataLimiteDesbloqueio);
        System.assertEquals(conta.UltimoOperador__c, result.ultimoOperador);
    }
    
}