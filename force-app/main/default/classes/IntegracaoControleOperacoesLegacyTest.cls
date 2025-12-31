@isTest
public class IntegracaoControleOperacoesLegacyTest {

    @isTest
    public static void listagemHierarquiasSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockListagemHierarquias');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        integracaoControleOperacoesLegacy.OutputListaLojas retorno = BCSF_ControleOperacoesLegacyController.listagemHierarquias('0000000000', 'cockpit', '1');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(4, retorno.response.size());
    }

    @isTest
    public static void listagemHierarquiasErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockListagemHierarquias');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        integracaoControleOperacoesLegacy.OutputListaLojas retorno = BCSF_ControleOperacoesLegacyController.listagemHierarquias('0000000000', 'cockpit', '1');
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @isTest
    public static void listagemTipoEventosSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockListagemTipoEventos');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        integracaoControleOperacoesLegacy.OutputListaTipoEventos retorno = BCSF_ControleOperacoesLegacyController.listagemTipoEventos('0000000000', 'cockpit', '1');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(4, retorno.response.size());
    }

    @isTest
    public static void listagemTipoEventosErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockListagemTipoEventos');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        integracaoControleOperacoesLegacy.OutputListaTipoEventos retorno = BCSF_ControleOperacoesLegacyController.listagemTipoEventos('0000000000', 'cockpit', '1');
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @isTest
    public static void consultarOperacoesSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarOperacoes');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        String body = '{"dataFinal": "2025-08-15","dataInicial": "2025-08-14","cpf": "00000000000",}';

        Test.StartTest();
        integracaoControleOperacoesLegacy.OutputConsultarOperacoes retorno = BCSF_ControleOperacoesLegacyController.consultarOperacoes(body, '0000000000', 'cockpit', '1');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(2, retorno.data.size());
    }

        @isTest
    public static void consultarOperacoesErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockConsultarOperacoes');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        String body = '{"dataFinal": "2025-08-15","dataInicial": "2025-08-14","cpf": "00000000000",}';

        Test.StartTest();
        integracaoControleOperacoesLegacy.OutputConsultarOperacoes retorno = BCSF_ControleOperacoesLegacyController.consultarOperacoes(body, '0000000000', 'cockpit', '1');
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @isTest
    public static void getAccountTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        List<String> cpfList = new List<String>{'123.456.789-12', '12345678912'};
        
        Test.StartTest();
        Account retorno = BCSF_ControleOperacoesLegacyController.getAccount(cpfList);
        Test.StopTest();

        System.AssertEquals('123.456.789-12', retorno.CPF__c);
        System.AssertEquals('Teste', retorno.Name);
    }
}