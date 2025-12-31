@IsTest
public with sharing class CancelamentoSemNFETest {
    @IsTest
    public static void testCancelOrder() {
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('CancelarPedidoSemNF');

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(
            configCustomer.endPoint__c.replace('{numeroPedido}', '12345'), 
            'Sucesso', 
            '{"orderId": "abxoajshdayusha12", "receipt": "receipt", "date":"2025-04-02T11:25:12.345678"}',
            200,
            new Map<String,String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        FlowCancelamentoSemNFE.Input input = new FlowCancelamentoSemNFE.Input();
        input.brand = 'CARREFOUR';
        input.orderNumber = '12345';
        List<FlowCancelamentoSemNFE.Input> listInput = new List<FlowCancelamentoSemNFE.Input>{input};

        List<CancelamentoSemNFEWrapper> result = FlowCancelamentoSemNFE.cancelamentoSemNFE(listInput);
        Test.stopTest();

        System.assertEquals('receipt', result[0].receipt);
    }

    @IsTest
    public static void testErrorOrder() {
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('CancelarPedidoSemNF');

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(
            configCustomer.endPoint__c.replace('{numeroPedido}', '12345'), 
            'Falha', 
            '{"timestamp": "2025-04-03T11:51:40.821+00:00", "status": 422,"error": "Unprocessable Entity","message": "error [422] trying to contact with order cancellation: Qtd pedido de entrega [1] Qtd pedido com sucesso [0] Qtd pedido com erro [1] \n555813955 - Pedido de Entrega nao existe no sistema GOLD para cancelamento","path": "/v1/orders/555813955/cancel"} ',
            422,
            new Map<String,String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        FlowCancelamentoSemNFE.Input input = new FlowCancelamentoSemNFE.Input();
        input.brand = 'CARREFOUR';
        input.orderNumber = '12345';
        List<FlowCancelamentoSemNFE.Input> listInput = new List<FlowCancelamentoSemNFE.Input>{input};

        List<CancelamentoSemNFEWrapper> result = FlowCancelamentoSemNFE.cancelamentoSemNFE(listInput);
        Test.stopTest();

        System.assertEquals(null, result);
    }
}