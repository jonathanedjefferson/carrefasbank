@isTest
public class IntegracaoCelularSeguroTest {

    @isTest
    public static void gravarCelularSeguroSucessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockGravarCelularSeguro');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Boolean retorno = IntegracaoCelularSeguro.gravarCelularSeguro('40020010025', '11900000000', '37000000', '1', 'cockpit');
        Test.StopTest();

        System.assertEquals(true, retorno);
    }

    @isTest
    public static void gravarCelularSeguroErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockGravarCelularSeguro');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Boolean retorno = BCSF_CadastroCelularSeguroController.gravarCelularSeguro('40020010025', '11900000000', '37000000', '1', 'cockpit');
        Test.StopTest();

        System.assertEquals(false, retorno);
    }

    @isTest
    public static void CriarCasosTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        String telefone = '900000000';
        String telefoneAntigo = '910000000';

        Test.StartTest();
            BCSF_CadastroCelularSeguroController.criarCaso(telefone, telefoneAntigo, cf.Id, acc.Id, 'cenario1', '1', '40020010025', 'Ouvidoria',  'Whatsapp');
            BCSF_CadastroCelularSeguroController.criarCaso(telefone, telefoneAntigo, cf.Id, acc.Id, 'cenario2', '1', '40020010025', 'Ouvidoria',  'Whatsapp');
            BCSF_CadastroCelularSeguroController.criarCaso(telefone, telefoneAntigo, cf.Id, acc.Id, 'cenario3', '1', '40020010025', 'Ouvidoria',  'Whatsapp');
            BCSF_CadastroCelularSeguroController.criarCaso(telefone, telefoneAntigo, cf.Id, acc.Id, 'cenarioFraude', '1', '40020010025', 'Ouvidoria',  'Whatsapp');
        Test.StopTest();

        System.AssertEquals(4, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void atualizarCasoTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Case cs = BCSF_CadastroCelularSeguroController.criarCaso('900000000', '910000000', cf.Id, acc.Id, 'cenario2', '1', '40020010025', 'Ouvidoria',  'Whatsapp');

        Test.StartTest();
            BCSF_CadastroCelularSeguroController.atualizarCaso(cs.id, 'Sim', 'Sim', 'Sim', 'teste');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void getContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Test.StartTest();
            ContaFinanceira__c response = BCSF_CadastroCelularSeguroController.getContaFinanceira(cf.Id);
        Test.StopTest();

        System.AssertEquals(response.id, cf.id);
    }

    @IsTest
    static void getAcessoPerfilTest() {
        Test.startTest();
        PerfisCadastroCelularSeguro__mdt result = BCSF_CadastroCelularSeguroController.getAcessoPerfil('Administrador do sistema');
        Test.stopTest();

        System.assertNotEquals(result, null);
    }

        @isTest
    public static void usuarioPossuiPermissaoTest(){

        PermissionSet pm = new PermissionSet();
        pm.Name='Permissao_Teste'; 
        pm.Label='Permissao Teste';
        insert pm;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'BCSF_PF_Banco Carrefour' LIMIT 1];

        User us = new User();
        us.Username = 'usrnameForTest@test.com';
        us.LastName = 'test';
        us.ProfileId = p.Id;
        us.Alias = 'tuser';
        us.Email = 'testuser@example.com';
        us.EmailEncodingKey = 'UTF-8';
        us.LanguageLocaleKey = 'en_US';
        us.LocaleSidKey = 'en_US';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        insert us;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = us.Id;
        psa.PermissionSetId = pm.Id;
        insert psa;

        Test.StartTest();
            System.runAs(us) {
                List<String> listaPerms = new List<String>{'Permissao_Teste', 'Outra_Permissao'};
                Boolean resultado = BCSF_CadastroCelularSeguroController.usuarioPossuiPermissao(listaPerms);
                System.assertEquals(true, resultado, 'Usuário deve ter permissão');
            }
        Test.StopTest();
    }

    @isTest
    static void usuarioSemPermissionSetTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'BCSF_PF_Banco Carrefour' LIMIT 1];
        User us = new User();
        us.Username = 'usrnameForTest@test.com';
        us.LastName = 'test';
        us.ProfileId = p.Id;
        us.Alias = 'tuser';
        us.Email = 'testuser@example.com';
        us.EmailEncodingKey = 'UTF-8';
        us.LanguageLocaleKey = 'en_US';
        us.LocaleSidKey = 'en_US';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        insert us;


        Test.startTest();
            System.runAs(us) {
                List<String> listaPerms = new List<String>{'Permissao_Inexistente'};
                Boolean resultado = BCSF_CadastroCelularSeguroController.usuarioPossuiPermissao(listaPerms);
                System.assertEquals(false, resultado, 'Usuário não deve ter permissão');
            }
        Test.stopTest();
    }

}