public without sharing class CreateCaseBatch implements Database.Batchable<Map<String, Object>>, Database.Stateful, Database.AllowsCallouts{
    public BulkCaseManagerController.CaseData lCaseData;
    CreateCaseBatchService service;

    public CreateCaseBatch(BulkCaseManagerController.CaseData lCaseData) {
        this.lCaseData = lCaseData;
    }

    public Iterable<Map<String, Object>> start(Database.BatchableContext bc) {
       return this.lCaseData.Data;
    }

    public void execute(Database.BatchableContext bc, List<Map<String,Object>> lData) {
        this.service = new CreateCaseBatchService(lData);
        this.service.createCases();
        this.service.createBulkRecordDetails();
    }

    public void finish(Database.BatchableContext bc) {
        if (this.service != null) {
            this.service.sendNotification();
        }
    }
}