@isTest
private class ProtocoloAtendimentoTest {

    @isTest
    public static void protocoloAtendimentoTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultaProtocoloExceller');

        List<ProtocoloAtendimentoHelper.InputConsultaProtocolo> lstInputConsultaProtocolo = new List<ProtocoloAtendimentoHelper.InputConsultaProtocolo>();
        ProtocoloAtendimentoHelper.InputConsultaProtocolo objInputConsultaProtocolo = new ProtocoloAtendimentoHelper.InputConsultaProtocolo();

        objInputConsultaProtocolo.canal = 'chat';
        objInputConsultaProtocolo.cpf = '49926079857';
        objInputConsultaProtocolo.unidadeNegocio = '1';

        lstInputConsultaProtocolo.add(objInputConsultaProtocolo);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        Test.StartTest();

        List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo> lstOutputConsultaProtocolo = ProtocoloAtendimentoHelper.ProtocoloAtendimento(lstInputConsultaProtocolo);

        Test.StopTest();

        System.assertEquals('Sim', lstOutputConsultaProtocolo[0].possuiProtocolo);

    }

    @isTest
    public static void protocoloAtendimentoErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultaProtocoloExcellerNao');

        List<ProtocoloAtendimentoHelper.InputConsultaProtocolo> lstInputConsultaProtocolo = new List<ProtocoloAtendimentoHelper.InputConsultaProtocolo>();
        ProtocoloAtendimentoHelper.InputConsultaProtocolo objInputConsultaProtocolo = new ProtocoloAtendimentoHelper.InputConsultaProtocolo();

        objInputConsultaProtocolo.canal = 'chat';
        objInputConsultaProtocolo.cpf = '49926079857';
        objInputConsultaProtocolo.unidadeNegocio = '1';

        lstInputConsultaProtocolo.add(objInputConsultaProtocolo);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        Test.StartTest();

        List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo> lstOutputConsultaProtocolo = ProtocoloAtendimentoHelper.ProtocoloAtendimento(lstInputConsultaProtocolo);

        Test.StopTest();

        System.assertEquals('Nao', lstOutputConsultaProtocolo[0].possuiProtocolo);

    }

    @isTest
    public static void protocoloAtendimentoNaoPossuiProtocoloTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultaProtocoloExcellerNaoPossui');

        List<ProtocoloAtendimentoHelper.InputConsultaProtocolo> lstInputConsultaProtocolo = new List<ProtocoloAtendimentoHelper.InputConsultaProtocolo>();
        ProtocoloAtendimentoHelper.InputConsultaProtocolo objInputConsultaProtocolo = new ProtocoloAtendimentoHelper.InputConsultaProtocolo();

        objInputConsultaProtocolo.canal = 'chat';
        objInputConsultaProtocolo.cpf = '49926079857';
        objInputConsultaProtocolo.unidadeNegocio = '1';

        lstInputConsultaProtocolo.add(objInputConsultaProtocolo);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        Test.StartTest();

        List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo> lstOutputConsultaProtocolo = ProtocoloAtendimentoHelper.ProtocoloAtendimento(lstInputConsultaProtocolo);

        Test.StopTest();

        System.assertEquals('Nao', lstOutputConsultaProtocolo[0].possuiProtocolo);

    }

    @isTest
    public static void protocoloAtendimentoErroAPITest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);

        List<ProtocoloAtendimentoHelper.InputConsultaProtocolo> lstInputConsultaProtocolo = new List<ProtocoloAtendimentoHelper.InputConsultaProtocolo>();
        ProtocoloAtendimentoHelper.InputConsultaProtocolo objInputConsultaProtocolo = new ProtocoloAtendimentoHelper.InputConsultaProtocolo();

        objInputConsultaProtocolo.canal = 'chat';
        objInputConsultaProtocolo.cpf = '49926079857';
        objInputConsultaProtocolo.unidadeNegocio = '1';

        lstInputConsultaProtocolo.add(objInputConsultaProtocolo);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        Test.StartTest();

        List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo> lstOutputConsultaProtocolo = ProtocoloAtendimentoHelper.ProtocoloAtendimento(lstInputConsultaProtocolo);

        Test.StopTest();

        System.assertEquals('Erro', lstOutputConsultaProtocolo[0].possuiProtocolo);

    }
}