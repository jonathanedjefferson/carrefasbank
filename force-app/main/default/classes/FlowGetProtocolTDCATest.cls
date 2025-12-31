@isTest
global with sharing class FlowGetProtocolTDCATest {

    // Teste do cenário de sucesso
    @isTest
    public static void testGetProtocolByDocumentSuccess() {
        List<FlowGetProtocolTDCA.Input> lstInputs = new List<FlowGetProtocolTDCA.Input>();

        FlowGetProtocolTDCA.Input newInput = new FlowGetProtocolTDCA.Input();
        newInput.brand = 'carrefour';
        newInput.document = '40587162821';

        lstInputs.add(newInput);

        Test.setMock(HttpCalloutMock.class, new ConsultarProtocolTDCAMockSuccess());
        
        List<FlowGetProtocolTDCA.Output> result = FlowGetProtocolTDCA.getProtocolByDocument(lstInputs);
        
        System.assertNotEquals(0, result.size(), 'Deve retornar ao menos um registro');
        System.assertEquals('00339534', result[0].records[0].caseNumber, 'O número do caso deve ser o esperado');
    }

    @isTest
    public static void testGetProtocolByDocumentNoRecords() {
        List<FlowGetProtocolTDCA.Input> lstInputs = new List<FlowGetProtocolTDCA.Input>();

        FlowGetProtocolTDCA.Input newInput = new FlowGetProtocolTDCA.Input();
        newInput.brand = 'carrefour';
        newInput.document = '99999999999';
        
        lstInputs.add(newInput);

        Test.setMock(HttpCalloutMock.class, new ConsultarProtocolTDCAMockNoRecords());
        
        List<FlowGetProtocolTDCA.Output> result = FlowGetProtocolTDCA.getProtocolByDocument(lstInputs);
        
        System.assertEquals(0, result[0].records.size(), 'A lista de registros deve estar vazia');
    }

    // Teste do cenário de erro (Exceção na chamada HTTP)
    @isTest
    public static void testGetProtocolByDocumentError() {
        List<FlowGetProtocolTDCA.Input> lstInputs = new List<FlowGetProtocolTDCA.Input>();

        FlowGetProtocolTDCA.Input newInput = new FlowGetProtocolTDCA.Input();
        newInput.brand = 'carrefour';
        newInput.document = '40587162821';

        lstInputs.add(newInput);

        Test.setMock(HttpCalloutMock.class, new ConsultarProtocolTDCAMockError());
        
        List<FlowGetProtocolTDCA.Output> result = FlowGetProtocolTDCA.getProtocolByDocument(lstInputs);
        
        System.assertEquals(0, result[0].records.size(), 'A lista de registros deve estar vazia devido ao erro');
    }
    

    // Mock de sucesso para o caso de sucesso
    global with sharing class ConsultarProtocolTDCAMockSuccess implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{"totalSize":14,"done":true,"records":[{"attributesJson":{"type":"Case","url":"/services/data/v60.0/sobjects/Case/500De000002LpKNIA0"},"caseNumber":"00339534","orderNumber":null,"modality":"MARKETPLACE_OUT","documentNumber":"40587162821","typeorder":"Pai","category":"Reclamação","reason":"Cadastro","event":"Erro de acesso","status":"Em tratativa","brand":"CARREFOUR","protocolTypeName":"EvrVarejoEcomCarrefour","dateCreation":"2025-03-20T16:00:19"}]}';
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }

    // Mock para o caso em que não há registros
    global with sharing class ConsultarProtocolTDCAMockNoRecords implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            String body = '{"totalSize":0,"done":true,"records":[]}'; // Nenhum registro retornado
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }

    // Mock para o caso de erro
    global with sharing class ConsultarProtocolTDCAMockError implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody('{"error":"Internal Server Error"}');
            response.setStatusCode(500); // Erro 500, simula falha no servidor
            return response;
        }
    }
}