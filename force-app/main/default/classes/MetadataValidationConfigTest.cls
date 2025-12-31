@IsTest
private class MetadataValidationConfigTest {
    
    @TestSetup
    static void setupData() {
        PerfisBypass__c pf = new PerfisBypass__c();
        pf.SetupOwnerId = UserInfo.getOrganizationId();
        pf.Perfis__c = 'Administrador;Supervisor;Financeiro';
        insert pf;
    }
    
    @IsTest
    static void testBuscaPerfisBypassCF_Sucesso() {
        
        Set<String> result = MetadataValidationConfig.BuscaPerfisBypassCF();
        
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo');
        System.assertEquals(true, result.contains('Administrador'));
        System.assertEquals(true, result.contains('Supervisor'));
        System.assertEquals(true, result.contains('Financeiro'));
        System.assertEquals(3, result.size(), 'Devem existir exatamente 3 perfis');
    }
    
    @IsTest
    static void testBuscaPerfisBypassCF_SemRegistro() {
        
        delete [SELECT Id FROM PerfisBypass__c];
        
        Set<String> result = MetadataValidationConfig.BuscaPerfisBypassCF();
        
        System.assertEquals(true, result.isEmpty(), 'Deve retornar um conjunto vazio quando não há registros');
    }
    
    // @IsTest
    // static void testBuscaTempoCF_Sucesso() {
        
    //     Test.startTest();
        
    //     IntervaloAtualizacaoDados__mdt mockMetadata = (IntervaloAtualizacaoDados__mdt)
    //         MetadataValidationConfig.BuscaTempoCF();
        
    //     System.assertEquals(15, 15);
        
    //     Test.stopTest();
    // }
    // @IsTest
    // static void BuscaContaFinanceiraById_Sucesso() {
    //     ContaFinanceira__c conta = new ContaFinanceira__c(
    //         DataLimiteDesbloqueio__c = Date.today().addDays(10),
    //     UltimoOperador__c = UserInfo.getUserId()
    //         );
    //     insert conta;
        
    //     Test.startTest();
    //     ContaFinanceira__c result = MetadataValidationConfig.BuscaContaFinanceiraById(conta.Id);
    //     Test.stopTest();
    //     System.assertNotEquals(null, result, 'O resultado não deve ser nulo');
    //     System.assertEquals(conta.DataLimiteDesbloqueio__c, result.DataLimiteDesbloqueio__c, 'DataLimiteDesbloqueio__c deve corresponder');
    //     System.assertEquals(conta.UltimoOperador__c, result.UltimoOperador__c, 'UltimoOperador__c deve corresponder');
    // }
    // @IsTest
    // static void BuscaContaFinanceiraById_Erro() {
      
    //     Test.startTest();
    //     ContaFinanceira__c result = MetadataValidationConfig.BuscaContaFinanceiraById('0000g00000A1BcD');
    //     Test.stopTest();
    //     System.assertEquals(null, result);
    //     System.assertEquals(null, result, 'DataLimiteDesbloqueio__c deve corresponder');
    //     System.assertEquals(null, result, 'UltimoOperador__c deve corresponder');
    // }
    @IsTest
    static void BuscaPerfilUsuario_Sucesso() {
        User testUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Test.startTest();
        User result = MetadataValidationConfig.BuscaPerfilUsuario(testUser.Id);
        Test.stopTest();
        System.debug('Resultado: ' + result);
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo');
        System.assertEquals(testUser.Profile.Name, result.Profile.Name, 'O nome do perfil deve corresponder');
    }
    @IsTest
    static void BuscaPerfilUsuario_Erro() {

        Test.startTest();
        User result = MetadataValidationConfig.BuscaPerfilUsuario('0000g00000A1BcD');
        Test.stopTest();
        System.debug('Resultado: ' + result);
        System.assertEquals(null, result, 'O resultado deve ser nulo');
    }
}