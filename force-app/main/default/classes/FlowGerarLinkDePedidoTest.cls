@isTest
public class FlowGerarLinkDePedidoTest {
    @isTest
    public static void testgerarLink() {
        
        String items = 'item1';
        String categoria = '2';
        String cep = '12345';
        list<FlowGerarLinkDePedido> ListInput = new list<FlowGerarLinkDePedido>();
        
        Test.setMock(HttpCalloutMock.class, new GerarLinkMock());
        GerarLinkDeCatalogoTO.ResponseWrapper result = GerarLinkDeCatalogo.gerarLink(items,categoria,cep);
    }
    
     public class GerarLinkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"success": true,"payload": {"orderFormId": "e71f8818a7a84ec699ae723b676e4325","orderURL": "https://carrefour.com.br/checkout?orderFormId=e71f8818a7a84ec699ae723b676e4325#/cart"},"error": null}');
            return response;
        }
    }
    

    public class GerarLinkMock2 implements HttpCalloutMock {
        private GerarLinkDeCatalogoTO.ResponseWrapper responseWrapper;
 	public GerarLinkMock2(GerarLinkDeCatalogoTO.ResponseWrapper responseWrapper) {
            this.responseWrapper = responseWrapper;
        }
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"success": true,"payload": {"orderFormId": "e71f8818a7a84ec699ae723b676e4325","orderURL": "https://carrefour.com.br/checkout?orderFormId=e71f8818a7a84ec699ae723b676e4325#/cart"},"error": null}');
            return response;
        }
    }
    
     @isTest
    public static void testLinkDePedidos() {
        
        FlowGerarLinkDePedido.Input input = new FlowGerarLinkDePedido.Input();
        input.items = 'item1,item2,item3';
        input.categoria = '1';
        input.cep = '12345';

        List<FlowGerarLinkDePedido.Input> lstEntrada = new List<FlowGerarLinkDePedido.Input>{input};
		GerarLinkDeCatalogoTO.ResponseWrapper responseWrapper = new GerarLinkDeCatalogoTO.ResponseWrapper();
        responseWrapper.success = true;
        GerarLinkDeCatalogoTO.Payload payload = new GerarLinkDeCatalogoTO.Payload();
        payload.orderFormId = '12345';
        payload.orderURL = 'https://example.com/order/12345';
		responseWrapper.payload = payload;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GerarLinkMock2(responseWrapper));
        List<FlowGerarLinkDePedido.Output> outputList = FlowGerarLinkDePedido.chamarLinkCatalogo(lstEntrada);
        Test.stopTest();
}
}