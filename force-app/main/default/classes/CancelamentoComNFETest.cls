@isTest
public with sharing class CancelamentoComNFETest {
    @isTest
    public static void solicitarCancelamentoComNFETrue(){
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('CancelamentoComNFE');

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(
            configCustomer.endPoint__c, 
            'Sucesso', 
            '{"id":"QD08ZOLE1uCwMfssiqTU","protocolId":"500D500000DDM1gIAH","protocol":"00093669","brand":"carrefour","orderId":"500063871","createdAt":"2025-06-16T10:45:47.453784433","updatedAt":null,"events":[{"originSystem":"Cockpit","eventDescription":"Solicitação de cancelamento criada","status":"REQUEST_CREATED","createdAt":"2025-06-16T10:45:47.453807894"}],"cancellationFinalized":false}',
            200,
            new Map<String,String>()
        );

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            FlowCancelamentoComNFE.Input input = new FlowCancelamentoComNFE.Input();
            input.caseId = '500D500000DDM1gIAH';
            input.caseNumber = '00093669';
            input.orderId = '500063871';
            input.deliveryId = '5000638710001';
            input.orderStatus = 'NFE';
            input.brand = 'CARREFOUR';
            input.methodBy = 'OP';
            input.document = '123';
            input.fullName = '123';
            input.bankCode = '123';
            input.bankBranchCode = '123';
            input.bankAccountNumber = '123';
            input.canal = 'Cockpit';


            List<FlowCancelamentoComNFE.Input> lstInput = new List<FlowCancelamentoComNFE.Input>();
            lstInput.add(input);

            List<CancelamentoComNFEWrapper.ResponseCancelamentoComNFE> lstRetorno = FlowCancelamentoComNFE.solicitarCancelamentoComNFE(lstInput);
        Test.stopTest();

        System.assertEquals(lstRetorno[0].Id, 'QD08ZOLE1uCwMfssiqTU');
        System.assertEquals(lstRetorno[0].protocolId, '500D500000DDM1gIAH');
        System.assertEquals(lstRetorno[0].protocol, '00093669');
    }

    @isTest
    public static void solicitarCancelamentoComNFEFalse(){
        Varejo_Api_Callout__mdt configCustomer = Varejo_Api_Callout__mdt.getinstance('CancelamentoComNFE');

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(
            configCustomer.endPoint__c, 
            'Sucesso', 
            '',
            400,
            new Map<String,String>()
        );

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            FlowCancelamentoComNFE.Input input = new FlowCancelamentoComNFE.Input();
            input.caseId = '500D500000DDM1gIAH';
            input.caseNumber = '00093669';
            input.orderId = '500063871';
            input.deliveryId = '5000638710001';
            input.orderStatus = 'NFE';
            input.brand = 'CARREFOUR';
            input.methodBy = 'OP';
            input.document = '123';
            input.fullName = '123';
            input.bankCode = '123';
            input.bankBranchCode = '123';
            input.bankAccountNumber = '123';
            input.canal = 'Cockpit';


            List<FlowCancelamentoComNFE.Input> lstInput = new List<FlowCancelamentoComNFE.Input>();
            lstInput.add(input);

            List<CancelamentoComNFEWrapper.ResponseCancelamentoComNFE> lstRetorno = FlowCancelamentoComNFE.solicitarCancelamentoComNFE(lstInput);
        Test.stopTest();

        System.assertEquals(lstRetorno, null);
    }
}