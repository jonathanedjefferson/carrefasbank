@isTest
private class BulkCaseManagerControllerTest {
    private static final Id RECORD_TYPE_SAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_SAC').getRecordTypeId();

    @TestSetup
    static void makeData(){
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CFI_ContaFinanceira').getRecordTypeId();
        String recordTypeIdConsignado = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSFConsignado').getRecordTypeId();
        String recordTypeIdContaPessoal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BCSF_RT_PAC_ClientePessoalCarrefour').getRecordTypeId();

        Account accountNomeCliente = new Account(
            RecordTypeId = recordTypeIdContaPessoal,
            LastName = 'Teste Account',
            CPF__c = '09550369099'
        );
        insert accountNomeCliente;

        ContaFinanceira__c contaFinceira = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroConta__c = '70000014996'
        );
        insert contaFinceira;

        ContaFinanceira__c contaFinceiraConsignado = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdConsignado,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroContrato__c = 'a567e837-ada1-49d3-8674-67ae9013abb9'
        );
        insert contaFinceiraConsignado;
    }

    @isTest
    private static void createBulkCasesTest() {
        Map<String, Object> lMapInputParams = new Map<String, Object>{
            'Assunto' => 'Processos Especiais',
            'Evento' => 'Comprovante de crédito pessoal',
            'Case Origin' => 'APP',
            'Canal' => 'Chat',
            'Número da Conta Financeira' => 'a567e837-ada1-49d3-8674-67ae9013abb9',
            'Description' => 'criação de caso com conta identificada',
            'Data da Transação' => '2025-09-30 14:13:45',
            'Data' => '2025-10-01',
            'Valor' => '123.30'
        };

        BulkCaseManagerController.CaseData inputData = new BulkCaseManagerController.CaseData();
        inputData.Data = new List<Map<String, Object>>{lMapInputParams};

        Test.StartTest();
        BulkCaseManagerController.createBulkCases(inputData);
        Test.StopTest();

        List<Case> lLstCreatedCases = [SELECT Id FROM Case];

        Assert.areEqual(1, lLstCreatedCases.size());
    }

    @isTest
    private static void createBulkCasesConsignadoTest() {
        Map<String, Object> lMapInputParams = new Map<String, Object>{
            'Assunto' => 'Processos Especiais',
            'Evento' => 'Comprovante de crédito pessoal',
            'Case Origin' => 'APP',
            'Canal' => 'Chat',
            'Número da Conta Financeira' => '70000014996',
            'Description' => 'criação de caso com conta identificada'
        };

        BulkCaseManagerController.CaseData inputData = new BulkCaseManagerController.CaseData();
        inputData.Data = new List<Map<String, Object>>{lMapInputParams};

        Test.StartTest();
        BulkCaseManagerController.createBulkCases(inputData);
        Test.StopTest();

        List<Case> lLstCreatedCases = [SELECT Id FROM Case];

        Assert.areEqual(1, lLstCreatedCases.size());
    }

    @isTest
    private static void createBulkCasesTestError() {
        Map<String, Object> lMapInputParams = new Map<String, Object>{
            'Assunto' => 'Prevenção a Fraude',
            'Evento' => 'Comprovante de crédito pessoal',
            'Case Origin' => 'APP',
            'Canal' => 'Chat',
            'Número da Conta Financeira' => '70000014996',
            'Description' => 'criação de caso com conta identificada'
        };

        BulkCaseManagerController.CaseData inputData = new BulkCaseManagerController.CaseData();
        inputData.Data = new List<Map<String, Object>>{lMapInputParams};

        Test.StartTest();
        BulkCaseManagerController.createBulkCases(inputData);
        Test.StopTest();

        List<Case> lLstCreatedCases = [SELECT Id FROM Case];
        List<BulkRecordDetail__c> lLstErrorData = [SELECT Id FROM BulkRecordDetail__c];

        Assert.areEqual(0, lLstCreatedCases.size());
        Assert.areEqual(1, lLstErrorData.size());
    }

    @isTest
    private static void createBulkCasesTestWithoutFinAccount() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitNumeroConta');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        Map<String, Object> lMapInputParams = new Map<String, Object>{
            'Assunto' => 'Processos Especiais',
            'Evento' => 'Comprovante de crédito pessoal',
            'Case Origin' => 'APP',
            'Canal' => 'Chat',
            'Número da Conta Financeira' => '10000081470',
            'Description' => 'criação de caso com conta identificada'
        };

        BulkCaseManagerController.CaseData inputData = new BulkCaseManagerController.CaseData();
        inputData.Data = new List<Map<String, Object>>{lMapInputParams};

        Test.StartTest();
        BulkCaseManagerController.createBulkCases(inputData);
        Test.StopTest();

        List<Case> lLstCreatedCases = [SELECT Id, AccountId, ContaFinanceira__c FROM Case];

        Assert.areEqual(1, lLstCreatedCases.size());
        Assert.isNotNull(lLstCreatedCases[0].AccountId);
        Assert.isNotNull(lLstCreatedCases[0].ContaFinanceira__c);
    }

    @isTest
    private static void updateBulkCasesTest() {
        Case newCase = new Case(
            Assunto__c = 'Processos Especiais',
            Evento__c = 'Comprovante de crédito pessoal',
            Origin = 'APP', 
            CanalEntrada__c = 'Chat',
            Description = 'Teste',
            NomeContato__c = 'Teste',
            CPFContato__c = '42104961033'
        );
        insert newCase;

        BulkCaseManagerController.UpdateCaseData inputData = new BulkCaseManagerController.UpdateCaseData();
        inputData.CaseNumber = [SELECT Id, CaseNumber FROM Case WHERE Id =: newCase.Id].CaseNumber;
        inputData.ClosedReason = 'Mensagem para finalização';

        Test.StartTest();
        BulkCaseManagerController.updateBulkCases(new List<BulkCaseManagerController.UpdateCaseData>{inputData});
        Test.StopTest();

        List<Case> lLstUpdatedCases = [SELECT Id, Status FROM Case];

        Assert.areEqual('Closed', lLstUpdatedCases[0].Status);
    }

    @isTest
    private static void getBulkRecordDetailsAllFilterTest() {

        BulkRecordDetail__c data = new BulkRecordDetail__c(
            ErrorMessage__c = 'Test error message',
            BusinessUnit__c = '1',
            ImportType__c = 'Abertura massificada',
            AccountNumber__c = '123456',
            Subject__c = 'Test subject',
            Event__c = 'Test event'
        );

        insert data;

        Map<String, String> lMapFilters = new Map<String, String>{
            'itensPerPage' => '10',
            'startIndex' => '0',
            'event' => 'Test event',
            'subject' => 'Test subject',
            'importType' => 'Abertura massificada'
        };
        
        BulkCaseManagerController.ErrorImportData errorImportData = new BulkCaseManagerController.ErrorImportData();

        Test.StartTest();
        errorImportData = BulkCaseManagerController.getBulkRecordDetails(lMapFilters);
        Test.StopTest();

        Assert.areEqual(1, errorImportData.records.size());
        Assert.areEqual(1, errorImportData.totalItems);
    }

    @isTest
    private static void getBulkRecordDetailsEventFilterTest() {

        BulkRecordDetail__c data = new BulkRecordDetail__c(
            ErrorMessage__c = 'Test error message',
            BusinessUnit__c = '1',
            ImportType__c = 'Abertura massificada',
            AccountNumber__c = '123456',
            Subject__c = 'Test subject',
            Event__c = 'Test event'
        );

        insert data;

        Map<String, String> lMapFilters = new Map<String, String>{
            'itensPerPage' => '10',
            'startIndex' => '0',
            'event' => 'Test event'
        };
        
        BulkCaseManagerController.ErrorImportData errorImportData = new BulkCaseManagerController.ErrorImportData();

        Test.StartTest();
        errorImportData = BulkCaseManagerController.getBulkRecordDetails(lMapFilters);
        Test.StopTest();

        Assert.areEqual(1, errorImportData.records.size());
        Assert.areEqual(1, errorImportData.totalItems);
    }

    @isTest
    private static void getBulkRecordDetailsSubjectFilterTest() {

        BulkRecordDetail__c data = new BulkRecordDetail__c(
            ErrorMessage__c = 'Test error message',
            BusinessUnit__c = '1',
            ImportType__c = 'Abertura massificada',
            AccountNumber__c = '123456',
            Subject__c = 'Test subject',
            Event__c = 'Test event'
        );

        insert data;

        Map<String, String> lMapFilters = new Map<String, String>{
            'itensPerPage' => '10',
            'startIndex' => '0',
            'subject' => 'Test subject'
        };
        
        BulkCaseManagerController.ErrorImportData errorImportData = new BulkCaseManagerController.ErrorImportData();

        Test.StartTest();
        errorImportData = BulkCaseManagerController.getBulkRecordDetails(lMapFilters);
        Test.StopTest();

        Assert.areEqual(1, errorImportData.records.size());
        Assert.areEqual(1, errorImportData.totalItems);
    }

    @isTest
    private static void getBulkRecordDetailsImportTypeFilterTest() {

        BulkRecordDetail__c data = new BulkRecordDetail__c(
            ErrorMessage__c = 'Test error message',
            BusinessUnit__c = '1',
            ImportType__c = 'Abertura massificada',
            AccountNumber__c = '123456',
            Subject__c = 'Test subject',
            Event__c = 'Test event'
        );

        insert data;

        Map<String, String> lMapFilters = new Map<String, String>{
            'itensPerPage' => '10',
            'startIndex' => '0',
            'importType' => 'Abertura massificada'
        };
        
        BulkCaseManagerController.ErrorImportData errorImportData = new BulkCaseManagerController.ErrorImportData();

        Test.StartTest();
        errorImportData = BulkCaseManagerController.getBulkRecordDetails(lMapFilters);
        Test.StopTest();

        Assert.areEqual(1, errorImportData.records.size());
        Assert.areEqual(1, errorImportData.totalItems);
    }

    @isTest
    private static void getImportFieldsTest() {
        Map<String, String> lMapFields = new Map<String, String>();

        Test.StartTest();
        lMapFields = BulkCaseManagerController.getImportFields();
        Test.StopTest();

        Assert.isTrue(!lMapFields.isEmpty());
    }
}