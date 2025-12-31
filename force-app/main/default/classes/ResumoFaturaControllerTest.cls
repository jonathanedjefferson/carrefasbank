@isTest
public class ResumoFaturaControllerTest {
    
    @isTest
    public static void resumoFaturaContaTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockResumoFaturaAberta');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        ResumoFatura.OutputFatura output = 
            ResumoFaturaController.obterResumoFaturaConta('37000113748', '98390073277', '1', 'Cockpit');
        Test.StopTest();

        System.assertEquals('OK', output.StatusAPI);
        System.assertEquals('Aberta', output.faturas[0].tipoFatura);
        System.assertEquals(0, output.faturas[0].idTipoFatura);
        System.assertEquals('Atrasada', output.faturas[1].tipoFatura);
        System.assertEquals(5, output.faturas[1].idTipoFatura);
        System.assertNotEquals(null, output.faturas[1].linhaDigitavel);
    }

    @isTest
    public static void resumoFaturaAnteriorFechadaTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockResumoFaturaAnteriorFechada');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        ResumoFatura.OutputFatura output = 
            ResumoFaturaController.obterResumoFaturaMes('37000113748', '2030-06-08', '98390073277', '1', 'Cockpit');
        Test.StopTest();

        System.assertEquals('OK', output.StatusAPI);
        System.assertEquals('Fechada', output.fatura.tipoFatura);
        System.assertEquals(1, output.fatura.idTipoFatura);
    }

    @isTest
    public static void resumoFaturaAnteriorFuturaTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockResumoFaturaAnteriorFutura');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        ResumoFatura.OutputFatura output = 
            ResumoFaturaController.obterResumoFaturaMes('37000113748', '2030-06-08', '98390073277', '1', 'Cockpit');
        Test.StopTest();

        System.assertEquals('OK', output.StatusAPI);
        System.assertEquals('Futura', output.fatura.tipoFatura);
        System.assertEquals(2, output.fatura.idTipoFatura);
    }

    @isTest
    public static void resumoFaturaAnteriorPagaTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockResumoFaturaAnteriorPaga');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        ResumoFatura.OutputFatura output = 
            ResumoFaturaController.obterResumoFaturaMes('37000113748', '2030-06-08', '98390073277', '1', 'Cockpit');
        Test.StopTest();

        System.assertEquals('OK', output.StatusAPI);
        System.assertEquals('Paga', output.fatura.tipoFatura);
        System.assertEquals(3, output.fatura.idTipoFatura);
    }

    @isTest
    public static void resumoFaturaAnteriorParcialTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockResumoFaturaAnteriorParcial');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        ResumoFatura.OutputFatura output = 
            ResumoFaturaController.obterResumoFaturaMes('37000113748', '2030-06-08', '98390073277', '1', 'Cockpit');
        Test.StopTest();

        System.assertEquals('OK', output.StatusAPI);
        System.assertEquals('Paga parcialmente', output.fatura.tipoFatura);
        System.assertEquals(4, output.fatura.idTipoFatura);
    }

    @isTest
    public static void resumoFaturaAnteriorErroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        ResumoFatura.OutputFatura output = 
            ResumoFaturaController.obterResumoFaturaMes('37000113748', '2030-06-08', '98390073277', '1', 'Cockpit');
        Test.StopTest();

        System.assertEquals('ERROR', output.StatusAPI);
    }

}