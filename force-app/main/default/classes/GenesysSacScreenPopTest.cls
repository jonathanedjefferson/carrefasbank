@IsTest(SeeAllData=true)
private class GenesysSacScreenPopTest {
    
    private static Case criarCaseBCSFSAC() {
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_SAC').getRecordTypeId();
        System.assertNotEquals(null, rtId, 'RecordType BCSF_SAC deve existir na org');
        
        Case c = new Case(
            RecordTypeId    = rtId,
        Origin          = 'SAC',
        CanalEntrada__c = 'Voz'
            );
        insert c;
        
        return [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :c.Id LIMIT 1];
    }
    
    private static void configurarUraSAC(String telefoneOuLista) {
        UraSAC__c cs = UraSAC__c.getOrgDefaults();
        if (cs == null) {
            cs = new UraSAC__c();
            cs.SetupOwnerId = UserInfo.getOrganizationId();
        }
        cs.Telefone__c = telefoneOuLista;
        upsert cs;
    }
    
    private static String makePayloadJson(String cpfValidado, String protocoloUra, String interactionId, String calledNumber) {
        Map<String, Object> attributes = new Map<String, Object>();
        if (cpfValidado != null)  attributes.put('Participant.CPF_VALIDADO', cpfValidado);
        if (protocoloUra != null) attributes.put('Participant.PROTOCOLO_URA_SAC', protocoloUra);
        
        Map<String, Object> interaction = new Map<String, Object>{
            'id'           => (interactionId != null ? interactionId : 'conv-TEST-000'),
            'attributes'   => attributes,
            'calledNumber' => calledNumber
        };
        
        Map<String, Object> payload = new Map<String, Object>{
            'interaction' => interaction
        };
        return JSON.serialize(payload);
    }
    
    @IsTest
    static void screenPop_quandoProtocoloExiste_deveRetornarUrl_eAtualizarConversationId() {
        String telefoneCS = '08001234567';
        configurarUraSAC(telefoneCS);
        
        Case existente = criarCaseBCSFSAC();
        System.debug('case++ ' + existente);
        String protocolo    = existente.CaseNumber;
        String interactionId = 'conv-EXISTE-001';
        
        String data = makePayloadJson(null, protocolo, interactionId, telefoneCS);
        
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson = sp.onScreenPop(data);
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        System.debug('resp++ ' + resp);
        Case atualizado = [SELECT Id, conversationId__c FROM Case WHERE Id = :existente.Id LIMIT 1];
        System.assertEquals(interactionId, atualizado.conversationId__c, 'Deve atualizar conversationId__c');
    }
    
    @IsTest
    static void screenPop_semProtocolo_deveCriarCase_comCamposBasicos() {
        String telefoneCS   = '08001234567';
        configurarUraSAC(telefoneCS);
        
        String cpf          = '12345678901';
        String interactionId = 'conv-CRIAR-001';
        String data         = makePayloadJson(cpf, null, interactionId, telefoneCS);
        
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson = sp.onScreenPop(data);
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        System.assert(resp.containsKey('url'), 'Sem protocolo, deve criar Case e retornar "url".');
        Id caseId = Id.valueOf((String) resp.get('url'));
        
        Case criado = [
            SELECT Id, Origin, CanalEntrada__c, CPFContato__c, conversationId__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        System.assertEquals('SAC', criado.Origin);
        System.assertEquals('Voz', criado.CanalEntrada__c);
        System.assertEquals(cpf, criado.CPFContato__c);
        System.assertEquals(interactionId, criado.conversationId__c);
    }
    
    @IsTest
    static void screenPop_protocoloInexistente_deveCriarCase_porCPF() {
        String telefoneCS        = '08001234567';
        configurarUraSAC(telefoneCS);
        
        String cpf               = '98765432100';
        String protocoloFake     = '99999999';
        String interactionId     = 'conv-FALLBACK-001';
        String data              = makePayloadJson(cpf, protocoloFake, interactionId, telefoneCS);
        
        GenesysSacScreenPop sp   = new GenesysSacScreenPop();
        String respJson          = sp.onScreenPop(data);
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        System.assert(resp.containsKey('url'), 'Sem encontrar protocolo, deve criar Case e retornar "url".');
        Id caseId = Id.valueOf((String) resp.get('url'));
        
        Case criado = [
            SELECT Id, CPFContato__c, conversationId__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        System.assertEquals(cpf, criado.CPFContato__c);
        System.assertEquals(interactionId, criado.conversationId__c);
    }
    
    @IsTest
    static void screenPop_deveRespeitarListaDeTelefonesSeparadosPorPontoEVirgula() {
        String listaTelefonesCS = '08001234567;08000000000;08009998877';
        configurarUraSAC(listaTelefonesCS);
        
        String cpf           = '11122233344';
        String interactionId = 'conv-LISTA-OK-001';
        String calledNumber  = '08000000000';
        
        String data = makePayloadJson(cpf, null, interactionId, calledNumber);
        
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson        = sp.onScreenPop(data);
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        System.assert(resp.containsKey('url'), 'Quando o número chamado consta na lista CS, deve criar/retornar Case.');
        Id caseId = Id.valueOf((String) resp.get('url'));
        
        Case c = [SELECT Id, conversationId__c FROM Case WHERE Id = :caseId LIMIT 1];
        System.assertEquals(interactionId, c.conversationId__c);
    }
    
    @IsTest
    static void screenPop_numeroIncorretoUra_deveFazerDefaultScreenPopSemURL() {
        configurarUraSAC('08001235555');
        
        String cpf           = '98765432100';
        String interactionId = 'conv-NUM-ERR-001';
        String calledNumber  = '0800123444';
        
        String data = makePayloadJson(cpf, null, interactionId, calledNumber);
        
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson        = sp.onScreenPop(data);
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        System.assert(!resp.containsKey('url'), 'Quando o número não coincide, não deve haver "url".');
        System.assertEquals(true, (Boolean) resp.get('defaultScreenPop'), 'Deve cair no defaultScreenPop');
    }
    
    private static String makePayloadJson2(String cpfValidado, String protocoloUra, String interactionId, String calledNumber,String numeroConta,String contaValidada) {
        Map<String, Object> attributes = new Map<String, Object>();
        if (cpfValidado != null)  attributes.put('Participant.CPF_VALIDADO', cpfValidado);
        if (protocoloUra != null) attributes.put('Participant.PROTOCOLO_URA_OUVIDORIA', protocoloUra);
        
        Map<String, Object> interaction = new Map<String, Object>{
            'id'           => (interactionId != null ? interactionId : 'conv-TEST-000'),
            'attributes'   => attributes,
            'calledNumber' => calledNumber,
            'numeroConta' => numeroConta,
            'CPF'=> cpfValidado,
            'contaValidada' => contaValidada
                
        };
        
        Map<String, Object> payload = new Map<String, Object>{
            'interaction' => interaction
        };
        return JSON.serialize(payload);
    }
    
    
    @IsTest
    static void screenPop_contaValidada_semNumero_coincide() {
        
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');
        
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        String accountRtName = 'BCSF Cliente Pessoal Carrefour';
        
        String cpf = '48283917200';
        String contaValidada = 'Sim';
        String interactionId = 'conv-NUM-ERR-001';
        String numeroConta = '';
        String calledNumber = '22980296177';
       
        
        configurarUraOuvidora('22980296177;08000000000;08009998877');
        String data = makePayloadJson2(cpf, null, interactionId, calledNumber, numeroConta, contaValidada);
        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();
      
        
        Test.startTest();
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson = sp.onScreenPop(data);
        Test.stopTest();
       List<ContaFinanceira__c> lst = [
        SELECT Id, NomeCliente__c, NomeCliente__r.CPF__c, NumeroConta__c, CreatedDate
        FROM ContaFinanceira__c
        ORDER BY CreatedDate DESC
        LIMIT 1
        ];

        
        String contaf;
        if (!lst.isEmpty()) {
            contaf = lst[0].Id;
        } else {
            contaf = null;
            System.debug('⚠️ Nenhum registro encontrado para os critérios informados.');
        }
        
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        
        
        System.assertEquals(contaf, resp.get('url'), 'A URL de retorno deve conter o ID da conta buscada.');
    }
    @IsTest
    static void screenPop_contaNaoValidada_semNumero_coincide() {
        
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');
        
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        String accountRtName = 'BCSF Cliente Pessoal Carrefour';
        
        String cpf = '48283917200';
        String contaValidada = 'Não';
        String interactionId = 'conv-NUM-ERR-001';
        String numeroConta = '10000081470';
        String calledNumber = '22980296177';
       
        
        
        configurarUraOuvidora('22980296177;08000000000;08009998877');
        String data = makePayloadJson2(cpf, null, interactionId, calledNumber, numeroConta, contaValidada);
        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();
        
        Test.startTest();
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson = sp.onScreenPop(data);
        Test.stopTest();
        List<ContaFinanceira__c> lst = [
        SELECT Id, NomeCliente__c, NomeCliente__r.CPF__c, NumeroConta__c, CreatedDate
        FROM ContaFinanceira__c
        ORDER BY CreatedDate DESC
        LIMIT 1
        ];
        
        String contaf;
        if (!lst.isEmpty()) {
            contaf = lst[0].Id;
        } else {
            contaf = null;
            System.debug('⚠️ Nenhum registro encontrado para os critérios informados.');
        }
        
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        System.assertEquals(contaf, resp.get('url'), 'A URL de retorno deve conter o ID da conta buscada.');
    }
    
    @IsTest
    static void screenPop_contaNaoValidada_semNumero_coincide_semCPF() {
        
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');
        
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        
        String accountRtName = 'BCSF Cliente Pessoal Carrefour';
        
        String cpf = '';
        String contaValidada = 'Não';
        String interactionId = 'conv-NUM-ERR-001';
        String numeroConta = '10000081470';
        String calledNumber = '22980296177';
        
        configurarUraOuvidora('22980296177;08000000000;08009998877');
        String data = makePayloadJson2(cpf, null, interactionId, calledNumber, numeroConta, contaValidada);
        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();
        
        Test.startTest();
        GenesysSacScreenPop sp = new GenesysSacScreenPop();
        String respJson = sp.onScreenPop(data);
        
        Test.stopTest();
        
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(respJson);
        
        System.assertEquals(true, resp.get('defaultScreenPop'),'Deve cair no defaultScreenPop');
    }
    private static void configurarUraOuvidora(String telefoneOuLista) {
        UraOuvidoria__c cs = UraOuvidoria__c.getOrgDefaults();
        if (cs == null) {
            cs = new UraOuvidoria__c();
            cs.SetupOwnerId = UserInfo.getOrganizationId();
        }
        cs.Telefone__c = telefoneOuLista;
        upsert cs;
    }
}