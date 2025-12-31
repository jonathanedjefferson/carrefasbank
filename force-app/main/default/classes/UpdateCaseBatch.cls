public with sharing class UpdateCaseBatch implements Database.Batchable<BulkCaseManagerController.UpdateCaseData>, Database.Stateful{
    public List<BulkCaseManagerController.UpdateCaseData> lLstUpdateCaseData;
    public List<BulkCaseManagerController.UpdateCaseData> lLstFailedCases;
    public Map<String, BulkCaseManagerController.UpdateCaseData> lMapCaseByNumber;

    public UpdateCaseBatch(List<BulkCaseManagerController.UpdateCaseData> lLstUpdateCaseData) {
        this.lLstUpdateCaseData = lLstUpdateCaseData;
        this.lLstFailedCases = new List<BulkCaseManagerController.UpdateCaseData>();
        this.lMapCaseByNumber = new Map<String, BulkCaseManagerController.UpdateCaseData>();
    }

    public Iterable<BulkCaseManagerController.UpdateCaseData> start(Database.BatchableContext bc) {
       return this.lLstUpdateCaseData;
    }

    public void execute(Database.BatchableContext bc, List<BulkCaseManagerController.UpdateCaseData> lLstUpdateCaseData) {
        List<Case> lLstCasesToUpdate = CreateCaseBatchHelper.getCases(getCaseNumbers(lLstUpdateCaseData));
        closeCases(lLstCasesToUpdate);
        updateCasesAndSaveFailed(lLstCasesToUpdate);
        createBulkRecordDetails();
    }

    public void finish(Database.BatchableContext bc) {
        sendNotification();
    }

    private Set<String> getCaseNumbers(List<BulkCaseManagerController.UpdateCaseData> lLstUpdateCaseData) {
        this.lMapCaseByNumber = new Map<String, BulkCaseManagerController.UpdateCaseData>();

        for (BulkCaseManagerController.UpdateCaseData updateCaseData : lLstUpdateCaseData) {
            lMapCaseByNumber.put(updateCaseData.CaseNumber, updateCaseData);
        }

        return this.lMapCaseByNumber.keySet();
    }

    private void closeCases(List<Case> lLstCasesToUpdate) {
        for (Case lCase : lLstCasesToUpdate) {
            lCase.Status = 'Closed';
            lCase.Resolucao__c = this.lMapCaseByNumber.get(lCase.CaseNumber).ClosedReason;
        }
    }
    
    private void updateCasesAndSaveFailed(List<Case> lLstCasesToUpdate) {
        List<Database.SaveResult> saveResults = Database.update(lLstCasesToUpdate, false);
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                BulkCaseManagerController.UpdateCaseData updateCaseData = this.lLstUpdateCaseData[i];
                updateCaseData.ErrorMessage = saveResults[i].getErrors()[0].getMessage() + ' / Campos: ' + saveResults[i].getErrors()[0].getFields();
                this.lLstFailedCases.add(updateCaseData);
            }
        }
    }

    public void createBulkRecordDetails() {
        List<BulkRecordDetail__c> lLstBulkRecordDetails = new List<BulkRecordDetail__c>();

        for (BulkCaseManagerController.UpdateCaseData updateCaseData : this.lLstFailedCases) {
            lLstBulkRecordDetails.add(CreateCaseBatchHelper.buildBulkRecordDetailUpdate(updateCaseData));
        }

        Database.insert(lLstBulkRecordDetails);
    }

    public void sendNotification() {
        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'BulkActionNotification'];
        Id userId = Userinfo.getUserId();
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setTitle('Gerenciador de Casos: Fechamento em Massa');
        customNotificationObj.setBody('Casos finalizados com sucesso!');
        customNotificationObj.setTargetId('000000000000000AAA');
        customNotificationObj.setNotificationTypeId(cnType.id);
        customNotificationObj.setSenderId(userId);
        customNotificationObj.send(new Set<String> {userId});
    }
}