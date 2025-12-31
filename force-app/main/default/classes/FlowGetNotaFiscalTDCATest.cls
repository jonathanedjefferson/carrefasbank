@isTest
public class FlowGetNotaFiscalTDCATest {
    @isTest
    public static void getInvoiceLinkTest(){
        FlowGetNotaFiscalTDCA.Input input = new FlowGetNotaFiscalTDCA.Input();
        input.orderId = '142464767';
        input.consigmentCode = '5463546477';
        input.brand = 'Carrefour';

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Obter Nota Fiscal');
        MockGeneric mock = new MockGeneric();
        mock.CreateMock(config.endPoint__c + input.orderId + '/consignment/' + input.consigmentCode + '/invoice', 'Success', '{"invoiceLink": "https://example.com/invoice/123456", "encodedInvoice": null}', 200, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            List<FlowGetNotaFiscalTDCA.Output> retornos =  FlowGetNotaFiscalTDCA.getNFTDCA(new List<FlowGetNotaFiscalTDCA.Input> {input});
        Test.stopTest();

        System.assertEquals(1, retornos.size());
        System.assertEquals('OK', retornos[0].StatusAPI);
        System.assertEquals('https://example.com/invoice/123456', retornos[0].invoiceLink);
    }

    @isTest
    public static void getEncodedInvoiceTest(){
        FlowGetNotaFiscalTDCA.Input input = new FlowGetNotaFiscalTDCA.Input();
        input.orderId = '142464767';
        input.consigmentCode = '5463546477';
        input.brand = 'Carrefour';

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Obter Nota Fiscal');
        MockGeneric mock = new MockGeneric();
        mock.CreateMock(config.endPoint__c + input.orderId + '/consignment/' + input.consigmentCode + '/invoice', 'Success', '{"invoiceLink": null, "encodedInvoice": "dGVzdF9lbmNvZGVkX2ludm9pY2U="}', 200, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            List<FlowGetNotaFiscalTDCA.Output> retornos =  FlowGetNotaFiscalTDCA.getNFTDCA(new List<FlowGetNotaFiscalTDCA.Input> {input});
        Test.stopTest();    
            
        List<ContentVersion> listContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'VarejoNF.pdf'];
        
        System.assertEquals(1, retornos.size());
        System.assertEquals('OK', retornos[0].StatusAPI);
        System.assertEquals(1, listContentVersion.size());
        System.assertEquals(retornos[0].contentDocumentId, listContentVersion[0].contentDocumentId);
    }

    @isTest
    public static void getInvoiceErro(){
        FlowGetNotaFiscalTDCA.Input input = new FlowGetNotaFiscalTDCA.Input();
        input.orderId = '142464767';
        input.consigmentCode = '5463546477';
        input.brand = 'Carrefour';

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Obter Nota Fiscal');
        MockGeneric mock = new MockGeneric();
        mock.CreateMock(config.endPoint__c + input.orderId + '/consignment/' + input.consigmentCode + '/invoice', 'Error', '{}', 400, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            List<FlowGetNotaFiscalTDCA.Output> retornos =  FlowGetNotaFiscalTDCA.getNFTDCA(new List<FlowGetNotaFiscalTDCA.Input> {input});
        Test.stopTest();    
        
        System.assertEquals(1, retornos.size());
        System.assertEquals('ERROR', retornos[0].StatusAPI);
    }
}