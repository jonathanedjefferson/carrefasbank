@isTest
public class GerarLinkDeCatalogoTest{
    @isTest
    static void testGerarLink() {
       String items = 'Item1, Item2, Item3'; 
       String categoria = 'Eletrônicos';       
       String cep = '12345-678'; 
        
       Test.setMock(HttpCalloutMock.class, new GerarLinkMock());
       GerarLinkDeCatalogoTO.ResponseWrapper response = GerarLinkDeCatalogo.gerarLink(items, categoria, cep);

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
}