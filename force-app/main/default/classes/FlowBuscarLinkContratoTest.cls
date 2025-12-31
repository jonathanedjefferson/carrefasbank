@isTest
public class FlowBuscarLinkContratoTest {

    @isTest
    static void testBuscarLinkContrato() {
        // Configurar o mock do callout
        Test.setMock(HttpCalloutMock.class, new BuscarLinkContratoMock());

        // Criar input
        FlowBuscarLinkContrato.Input input = new FlowBuscarLinkContrato.Input();
        input.orderId = '551666555';
        input.brand = 'CARREFOUR';

        List<FlowBuscarLinkContrato.Input> inputs = new List<FlowBuscarLinkContrato.Input>{ input };

        Test.startTest();
        List<FlowBuscarLinkContrato.Output> result = FlowBuscarLinkContrato.buscar(inputs);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('https://sis.pdvbox.com.br/carrefour/temporario/bilhete/index/dummyTicket', result[0].linkTicket);
    }
    
    // Classe de mock do callout
    public class BuscarLinkContratoMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"linkTicket": "https://sis.pdvbox.com.br/carrefour/temporario/bilhete/index/dummyTicket"}');
            res.setStatusCode(200);
            return res;
        }
    }
}