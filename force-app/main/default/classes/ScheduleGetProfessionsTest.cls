@isTest
private class ScheduleGetProfessionsTest {
    private static final String OCUPACAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Ocupacao').getRecordTypeId();
    private static final String CATEGORIA_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Categoria').getRecordTypeId();
    private static final String PROFISSAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Profissao').getRecordTypeId();
   
    @isTest 
    private static void testSchedule() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockBuscarModelosContratacao');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarCategorias');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarProfissoes');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarProfissoes');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        String jobId = ScheduleGetProfessions.runSchedule();
        Test.stopTest();
        
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

      	Assert.areEqual(0, ct1.TimesTriggered);
    }

    @isTest
    private static void startProcessTest() {

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockBuscarModelosContratacao');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarCategorias');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarProfissoes');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarProfissoes');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        ScheduleGetProfessions execution = new ScheduleGetProfessions();
        execution.execute(null);
        Test.stopTest();

        List<ParametroConsultaProfissao__c> lLstOcupation = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :OCUPACAO_RECORDTYPE_ID];

        List<ParametroConsultaProfissao__c> lLstCategories = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID];

        List<ParametroConsultaProfissao__c> lLstProfessions = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :PROFISSAO_RECORDTYPE_ID];

        Assert.areEqual(1, lLstOcupation.size());
        Assert.areEqual(3, lLstCategories.size());
        Assert.areEqual(3, lLstProfessions.size());
    }

    @isTest
    private static void reprocessProfessionsTest() {

        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockBuscarModelosContratacao');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarCategorias');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarProfissoes');
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockBuscarProfissoes');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        ReprocessaProfissoesAction.manageActions();
        Test.stopTest();

        List<ParametroConsultaProfissao__c> lLstOcupation = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :OCUPACAO_RECORDTYPE_ID];

        List<ParametroConsultaProfissao__c> lLstCategories = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID];

        List<ParametroConsultaProfissao__c> lLstProfessions = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :PROFISSAO_RECORDTYPE_ID];

        Assert.areEqual(1, lLstOcupation.size());
        Assert.areEqual(3, lLstCategories.size());
        Assert.areEqual(3, lLstProfessions.size());
    }
}