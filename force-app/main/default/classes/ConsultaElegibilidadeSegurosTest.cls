@isTest
private class ConsultaElegibilidadeSegurosTest {
    @IsTest
    public static void OfertaSeguroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockOfertasSeguros');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        string numeroConta = '37000119869';
        Integer idEmpresa = 1;

        ConsultaElegibilidadeSeguros.RequestSeguro requestController = new ConsultaElegibilidadeSeguros.RequestSeguro();
        requestController.idEmpresa = idEmpresa;
        requestController.numeroConta = numeroConta;
        requestController.canal = 'chat';
        requestController.cpf = '08116407015';

        Test.startTest();
        List<ConsultaElegibilidadeSeguros.ResponseElegibilidade> responseController = ConsultaElegibilidadeSeguros.OfertaSeguro(new List<ConsultaElegibilidadeSeguros.RequestSeguro>{requestController});
        Test.stopTest();

        Assert.areNotEqual(null, responseController);
    }

    @IsTest
    public static void OfertaSeguroErroAPI() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400, 'MockOfertaSeguroErroAPI');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        string numeroConta = '37000119869';
        Integer idEmpresa = 1;

        ConsultaElegibilidadeSeguros.RequestSeguro requestController = new ConsultaElegibilidadeSeguros.RequestSeguro();
        requestController.idEmpresa = idEmpresa;
        requestController.numeroConta = numeroConta;
        requestController.canal = 'chat';
        requestController.cpf = '08116407015';


        Test.startTest();
        List<ConsultaElegibilidadeSeguros.ResponseElegibilidade> responseController = ConsultaElegibilidadeSeguros.OfertaSeguro(new List<ConsultaElegibilidadeSeguros.RequestSeguro>{requestController});
        Test.stopTest();
        
        Assert.areEqual('ERRO', responseController[0].elegivel);
    }

    @IsTest
    public static void OfertaSeguroNaoElegivel() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockOfertaSeguroNaoElegivel');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        string numeroConta = '37000119869';
        Integer idEmpresa = 1;

        ConsultaElegibilidadeSeguros.RequestSeguro requestController = new ConsultaElegibilidadeSeguros.RequestSeguro();
        requestController.idEmpresa = idEmpresa;
        requestController.numeroConta = numeroConta;
        requestController.canal = 'chat';
        requestController.cpf = '08116407015';


        Test.startTest();
        List<ConsultaElegibilidadeSeguros.ResponseElegibilidade> responseController = ConsultaElegibilidadeSeguros.OfertaSeguro(new List<ConsultaElegibilidadeSeguros.RequestSeguro>{requestController});
        Test.stopTest();
        
        Assert.areEqual('NAO ELEGIVEL', responseController[0].elegivel);
    }
}