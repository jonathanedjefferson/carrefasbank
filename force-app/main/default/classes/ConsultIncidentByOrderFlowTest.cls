@IsTest
private class ConsultIncidentByOrderFlowTest {

   @IsTest
    static void testConsultarComRespostaValida() {

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('TDCA Consultar Incidente Via Pedido');
        String orderId = '5593653070001';
        String endPoint = config.endPoint__c + orderId;

        MockGeneric mock = new MockGeneric();
        mock.CreateMock(endPoint, 'OK', 
            '{' +
            '"consignmentCode": "5593653070001",' +
            '"createdAt": "22/06/2025 13:03:06",' +
            '"customer": {' +
                '"firstName": "ALINE",' +
                '"lastName": "Vieira",' +
                '"email": "alineguerracd@hotmail.com",' +
                '"document": "08411510751"' +
            '},' +
            '"incident": [{' +
                '"status": "INCIDENT_OPEN",' +
                '"reasonDescription": "Atraso na entrega",' +
                '"reasonCode": "37",' +
                '"productDescription": "Pneu Aro 15 Goodyear EfficientGrip Performance 195/65 R15 91H - 4 Unidades",' +
                '"productSku": "MP927253599",' +
                '"id": "5593653070001-A-1",' +
                '"createdAt": "25/06/2025 15:11:19",' +
                '"hasRefund": "true",' +
                '"price": 2239.60' +
            '}]' +
            '}',
            200,
            new Map<String, String>()
        );

        // 🔹 Registra o mock
        Test.setMock(HttpCalloutMock.class, mock);

        // 🔹 Prepara request como o Flow faria
        ConsultIncidentByOrderFlow.Request req = new ConsultIncidentByOrderFlow.Request();
        req.orderId = orderId;

        Test.startTest();
        List<ConsultIncidentByOrderFlow.Result> results =
            ConsultIncidentByOrderFlow.consultar(new List<ConsultIncidentByOrderFlow.Request>{ req });
        Test.stopTest();

        // 🔹 Valida resultado
        System.assertEquals(1, results.size());
        ConsultIncidentByOrderFlow.Result res = results[0];

        System.assertEquals('5593653070001', res.consignmentCode);
        System.assertEquals('ALINE', res.customerFirstName);
        System.assertEquals('Vieira', res.customerLastName);
        System.assertEquals('alineguerracd@hotmail.com', res.customerEmail);
        System.assertEquals('08411510751', res.customerDocument);
        System.assertEquals('INCIDENT_OPEN', res.incidentStatus);
        System.assertEquals('Atraso na entrega', res.incidentReasonDescription);
        System.assertEquals('37', res.incidentReasonCode);
        System.assertEquals('MP927253599', res.incidentProductSku);
        System.assertEquals('5593653070001-A-1', res.incidentId);
        System.assertEquals('true', res.incidentHasRefund);
        System.assertEquals('2239.6', res.incidentPrice);
        System.assertEquals('Incidente resgatado com sucesso!', res.message);

    }


    @IsTest
    static void testConsultarComErro() {
        ConsultIncidentByOrderFlow.Request req = new ConsultIncidentByOrderFlow.Request();
        req.orderId = 'ERRO_TESTE';

        Test.startTest();
        List<ConsultIncidentByOrderFlow.Result> results =
            ConsultIncidentByOrderFlow.consultar(new List<ConsultIncidentByOrderFlow.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].message != null && results[0].message.startsWith('Erro'));
    }
}