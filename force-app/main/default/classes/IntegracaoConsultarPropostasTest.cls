@isTest
public class IntegracaoConsultarPropostasTest {
    @isTest
    public static void ConsultarPropostasSucessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarPropostas');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoConsultarPropostas.OutPutConsultarPropostas retorno = BCSF_ConsultarPropostaController.ConsultarPropostas('40000000000', '0', '0', '2019-01-11 11:34:55', '2019-01-11 11:34:55', 'cockpit');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(1, retorno.propostas.size());
    }

    @isTest
    public static void ConsultarPropostasErro404Test() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(404, 'MockConsultarPropostas');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoConsultarPropostas.OutPutConsultarPropostas retorno = BCSF_ConsultarPropostaController.ConsultarPropostas('40000000000', '0', '0', '2019-01-11 11:34:55', '2019-01-11 11:34:55', 'cockpit');
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @isTest
    public static void ConsultarPropostasErro400Test() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockConsultarPropostasAlternativo');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoConsultarPropostas.OutPutConsultarPropostas retorno = BCSF_ConsultarPropostaController.ConsultarPropostas('40000000000', '0', '0', '2019-01-11 11:34:55', '2019-01-11 11:34:55', 'cockpit');
        Test.StopTest();
        System.assertEquals('400', retorno.statusResponse);
    }

    @isTest
    public static void ConsultarHistoricoPropostaSucessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarHistoricoProposta');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoConsultarPropostas.OutputHistoricoProposta retorno = BCSF_ConsultarPropostaController.ConsultarHistoricoProposta('0550000', '40020010020', 'cockpit');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(1, retorno.historicoProposta.size());
    }

    @isTest
    public static void ConsultarHistoricoPropostaErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockConsultarHistoricoProposta');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        IntegracaoConsultarPropostas.OutputHistoricoProposta retorno = BCSF_ConsultarPropostaController.ConsultarHistoricoProposta('00000', '40020010020', 'cockpit');
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @IsTest
    static void GetListParametrosPropostaTest() {
        Test.startTest();
        List<ParametrosConsultaProposta__mdt> result = BCSF_ConsultarPropostaController.getListParametrosProposta();
        Test.stopTest();

        System.assertNotEquals(result.size(), 0);
    }

    @IsTest
    static void GetAcessoPerfilTest() {
        Test.startTest();
        PerfisConsultaProsposta__mdt result = BCSF_ConsultarPropostaController.getAcessoPerfil('Administrador do sistema');
        Test.stopTest();

        System.assertNotEquals(result, null);
    }


    @isTest
    public static void CriarCasoConsultaPropostaTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        Test.StartTest();
        BCSF_ConsultarPropostaController.criarCasoConsulta(acc.Name, acc.Id, '40020010020', 'Ouvidoria',  'Voz');
        BCSF_ConsultarPropostaController.criarCasoConsulta(acc.Name, '', '40020010020', 'Ouvidoria',  'Voz');
        Test.StopTest();

        System.AssertEquals(2, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void CriarCasoPropostaRecusadaTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        Test.StartTest();
        BCSF_ConsultarPropostaController.criarCasoPropostaRecusada(acc.Name, acc.Id, '40020010020', 'Ouvidoria',  'Voz', 'descrição de teste');
        BCSF_ConsultarPropostaController.criarCasoPropostaRecusada(acc.Name, '', '40020010020', 'Ouvidoria',  'Voz', 'descrição de teste');
        Test.StopTest();

        System.AssertEquals(2, [SELECT COUNT() FROM Case]);
    }
}