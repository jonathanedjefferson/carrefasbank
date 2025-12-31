@isTest
public class TDCAManagerTest {

    @isTest
    public static void testObterPedidoPorId() {
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('TDCAListarPedidoPorID');
        String orderId = '1234';
        String brand = 'CARREFOUR';
        String endPoint = configCustomer.endPoint__c + orderId;

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(endPoint, 'Sucesso', '{"orderCode":"500060085","vtexOrderCode":"1461630060085-01","deliveryNumber":"1461630060085","totalValue":647.25,"totalItemValue":599.00,"totalFreight":48.25,"totalDiscounts":0.00,"totalTaxValue":0.00,"totalChangeValue":0.00,"salesChannelId":1,"salesChannel":"CARREFOUR","status":"payment-approved","origin":"ORDER","creationDate":"13/09/2024 15:41:13","lastUpdateDate":"13/09/2024 15:42:54","allowCancellation":false,"deliveryLate":false,"linkedOrders":false,"customer":{"firstName":"Paula","lastName":"Balbino","email":"paula_balbino_da_silva@carrefour.com","documentType":"cpf","documentNumber":"35140826852"},"billingAddress":{"street":"Avenida das Nações Unidas","number":"1010","neighborhood":"Vila Gertrudes","city":"São Paulo","state":"SP","postalCode":"04794-000"},"seller":{"id":"2000","name":"CRF-MKTP-QA"},"payments":[{"type":"CREDIT_CARD","brand":"Visa","installments":1,"value":647.25,"paymentStatus":"PURCHASE SUCCEEDED Transaction successful","acquirer":"REDE","authorizedDate":"13/09/2024 15:42:20"}],"consignments":[{"consignmentCode":"5000600850001","consignmentState":"CREATED","type":"MARKETPLACE_IN","status":"PCP","totalValue":314.48,"totalItemValue":299.0,"totalFreight":15.48,"totalDiscounts":0.0,"delivery":{"modality":"MARKETPLACE","deliveryOption":"1-1548-10","shippingEstimateTime":"10bd","shippingEstimateDate":"27/09/2024 15:42:53","deliveryAddress":{"street":"Avenida das Nações Unidas","number":"1010","neighborhood":"Vila Gertrudes","city":"São Paulo","state":"SP","country":"BRA","postalCode":"04794-000"}},"items":[{"id":"326550302","name":"Lavadora Brastemp 13kg Bwk13ab Branca 110v","unitPrice":299.0,"quantity":1,"subtotal":299.0,"descriptionUrl":"/lavadora-brastemp-13kg-bwk13ab-branca-110v-mp120050045/p","imageUrl":"https://carrefourbrqa.vteximg.com.br/arquivos/ids/433865-55-55/fcaf07825e044fb7a8d873a26f347715.jpg?v=638487883296730000"}],"consignmentStatusHistory":[{"status":"PIM","description":"pedido enviado ao parceiro","origin":"ORDER","creationTime":"13/09/2024 15:45:10"},{"status":"CCW","origin":"BACKEND","creationTime":"13/09/2024 15:43:04"},{"status":"CPR","description":"captura do pagamento realizada","origin":"BACKEND","creationTime":"13/09/2024 15:43:04"},{"status":"PAP","description":"pagamento confirmado","origin":"VTEX","creationTime":"13/09/2024 15:43:00"},{"status":"PCP","origin":"ORDER","creationTime":"13/09/2024 15:41:34"},{"status":"AAP","description":"pagamento pendente","origin":"VTEX","creationTime":"13/09/2024 15:41:32"},{"status":"PED","description":"pedido criado","origin":"VTEX","creationTime":"13/09/2024 15:41:34"}]},{"consignmentCode":"5000600850002","consignmentState":"CREATED","type":"MARKETPLACE_IN","status":"PCP","totalValue":219.23,"totalItemValue":201.0,"totalFreight":18.23,"totalDiscounts":0.0,"delivery":{"modality":"MARKETPLACE","deliveryOption":"1-1823-10","shippingEstimateTime":"10bd","shippingEstimateDate":"27/09/2024 15:42:53","deliveryAddress":{"street":"Avenida das Nações Unidas","number":"1010","neighborhood":"Vila Gertrudes","city":"São Paulo","state":"SP","country":"BRA","postalCode":"04794-000"}},"items":[{"id":"326550304","name":"Pneu Aro 15 185/65r15 Westlake 88h Z108 Cr65772","unitPrice":201.0,"quantity":1,"subtotal":201.0,"descriptionUrl":"/pneu-aro-15-18565r15-westlake-88h-z108-cr65772-mp120050046/p","imageUrl":"https://carrefourbrqa.vteximg.com.br/arquivos/ids/433867-55-55/4efa08ca03664ea683ecbf64d02ddda4.jpg?v=638487883990930000"}],"consignmentStatusHistory":[{"status":"CCW","origin":"BACKEND","creationTime":"13/09/2024 15:43:04"},{"status":"CPR","description":"captura do pagamento realizada","origin":"BACKEND","creationTime":"13/09/2024 15:43:04"},{"status":"PAP","description":"pagamento confirmado","origin":"VTEX","creationTime":"13/09/2024 15:43:00"},{"status":"PCP","origin":"ORDER","creationTime":"13/09/2024 15:41:34"},{"status":"AAP","description":"pagamento pendente","origin":"VTEX","creationTime":"13/09/2024 15:41:32"},{"status":"PED","description":"pedido criado","origin":"VTEX","creationTime":"13/09/2024 15:41:34"}]},{"consignmentCode":"5000600850003","consignmentState":"CREATED","type":"MARKETPLACE_IN","status":"PCP","totalValue":113.54,"totalItemValue":99.0,"totalFreight":14.54,"totalDiscounts":0.0,"delivery":{"modality":"MARKETPLACE","deliveryOption":"1-1454-10","shippingEstimateTime":"10bd","shippingEstimateDate":"27/09/2024 15:42:53","deliveryAddress":{"street":"Avenida das Nações Unidas","number":"1010","neighborhood":"Vila Gertrudes","city":"São Paulo","state":"SP","country":"BRA","postalCode":"04794-000"}},"items":[{"id":"326550303","name":"Tablet Samsung Galaxy Tab A9","unitPrice":99.0,"quantity":1,"subtotal":99.0,"descriptionUrl":"/tablet-samsung-galaxy-tab-a9-mp120050050/p","imageUrl":"https://carrefourbrqa.vteximg.com.br/arquivos/ids/433866-55-55/6f9fbc94cd104ebd8059c751568e81cd.jpg?v=638487883688470000"}],"consignmentStatusHistory":[{"status":"CCW","origin":"BACKEND","creationTime":"13/09/2024 15:43:04"},{"status":"CPR","description":"captura do pagamento realizada","origin":"BACKEND","creationTime":"13/09/2024 15:43:04"},{"status":"PAP","description":"pagamento confirmado","origin":"VTEX","creationTime":"13/09/2024 15:43:00"},{"status":"PCP","origin":"ORDER","creationTime":"13/09/2024 15:41:34"},{"status":"AAP","description":"pagamento pendente","origin":"VTEX","creationTime":"13/09/2024 15:41:32"},{"status":"PED","description":"pedido criado","origin":"VTEX","creationTime":"13/09/2024 15:41:34"}]}],"changes":[],"actions":{"returnAllowed":false,"getInvoiceAllowed":false,"getBankSlipAllowed":false}}',
                        200,
                        new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        FlowGetOrderByIdTDCA.Input input = new FlowGetOrderByIdTDCA.Input();
        input.brand = brand;
        input.orderId = orderId;

        List<FlowGetOrderByIdTDCAResponseWrapper> output = FlowGetOrderByIdTDCA.getBankSlipFromFlow(new List<FlowGetOrderByIdTDCA.Input>{input});
        // TDCAManager.getOrdersByOrderId(orderId, brand);
        Test.stopTest();

        System.assertEquals(1, output.size());
        System.assertEquals('paula_balbino_da_silva@carrefour.com', output[0].email);
        System.assertEquals('MARKETPLACE', output[0].modality);
        System.assertEquals(false, output[0].getBankSlipAllowed);
    }

    @isTest
    public static void FlowTDCAManagerTest() {
        Varejo_Api_Callout__mdt configCustomer = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Obter Segunda Via de Boleto');
        String orderId = '1234';
        String brand = 'CARREFOUR';
        String endPoint = configCustomer.endPoint__c + orderId + '/bankslip';

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(endPoint, 'Sucesso', '{"bankslipLink":"https://www.pagador.com.br/post/pagador/reenvia.asp/83f98f9f-b712-465a-ab91-eaccb7d6e01d"}', 200, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        FlowTDCAManager.Input input = new FlowTDCAManager.Input();
        input.brand = brand;
        input.orderId = orderId;

        List<FlowTDCAManager.Output> output = FlowTDCAManager.getBankSlipFromFlow(new List<FlowTDCAManager.Input>{input});
        Test.stopTest();

        System.assertEquals('https://www.pagador.com.br/post/pagador/reenvia.asp/83f98f9f-b712-465a-ab91-eaccb7d6e01d', output[0].bankslipLink);
        System.assertEquals('Success', output[0].status);
    }

    @isTest
    public static void testObterClientePorDocumento() {
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('TDCAObterClientesPorDocumento');
        String document = '1234';
        String brand = 'CARREFOUR';
        String endPoint = configCustomer.endPoint__c + '?documentNumber=' + document;

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(endPoint, 'Sucesso', '{"name":"Paula LINDAAA Balbino","email":"paula_balbino_da_silva@carrefour.com","document":"35140826852","birthDate":"30/08/1977","phone":null,"homePhone":"+5511957950269","businessPhone":null,"updatedIn":"01/11/2024 23:15:40"}',
                        200,
                        new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        ResponseGetCustomerWrapper response = TDCAManager.getCustomerByDocument(document, brand);
        Test.stopTest();

        System.assertEquals(response.name, 'Paula LINDAAA Balbino');
        System.assertEquals(response.email, 'paula_balbino_da_silva@carrefour.com');
    }

    @isTest
    public static void testObterPedidosPorCPF() {
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('TDCAListarPedidosCPF');
        String cpf = '1234';
        String brand = 'CARREFOUR';
        String endPoint = configCustomer.endPoint__c + cpf;

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(endPoint, 'Sucesso', '{"content":[{"code":"500061119","principalCode":"1473400061119-01","createdAt":"2024-11-01T16:54:05"},{"code":"500061115","principalCode":"1473390061115-01","createdAt":"2024-11-01T15:39:43"},{"code":"500061110","principalCode":"1473370061110-01","createdAt":"2024-11-01T13:58:58"},{"code":"500061109","principalCode":"1473370061109-01","createdAt":"2024-11-01T13:43:56"},{"code":"500061094","principalCode":"1473150061094-01","createdAt":"2024-10-31T15:52:48"}],"page":{"size":5,"number":0,"totalElements":115,"totalPages":23}}',
                        200,
                        new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        FlowTDCAManagerGetOrders.Input inp = new FlowTDCAManagerGetOrders.Input();
        inp.cpf = cpf;
        inp.brand = brand;

        List<GetOrdersByCPFResponseWrapper> response = FlowTDCAManagerGetOrders.getOrdersByCpf(New List<FlowTDCAManagerGetOrders.Input>{inp});
        Test.stopTest();

        System.assertEquals(response[0].content[0].code, '500061119');
        System.assertEquals(response[0].content[0].principalCode, '1473400061119-01');

    }

    @isTest
    public static void testObterNotaFiscal() {
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('TDCAObterNotaFiscal');
        String orderId = '500059064';
        String consigmentCode  = '5000590640001';
        String brand = 'CARREFOUR';
        String endPoint = configCustomer.endPoint__c + orderId + '/consignment/' + consigmentCode + '/invoice';

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(endPoint, 'Sucesso', '{"invoiceLink":null,"invoiceKey":null,"encodedInvoice":"JVBERi0xLjQKJeLjz9MKMy"}',
                        200,
                        new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        GetInvoiceResponseWrapper response = TDCAManager.getInvoice(orderId, consigmentCode, brand);
        Test.stopTest();

        System.assertEquals(response.encodedInvoice, 'JVBERi0xLjQKJeLjz9MKMy');

    }
}