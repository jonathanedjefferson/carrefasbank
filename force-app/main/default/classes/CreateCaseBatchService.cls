public without sharing class CreateCaseBatchService {
    public List<Map<String, Object>> lLstData;
    public List<Map<String, Object>> lLstFailedImportData;
    public List<Case> lLstCreatedCases;
    public Map<String, ContaFinanceira__c> lMapFinAccountByNumber;

    public CreateCaseBatchService(List<Map<String, Object>> lLstData) {
        this.lLstData = lLstData;
        this.lLstCreatedCases = new List<Case>();
        this.lLstFailedImportData = new List<Map<String, Object>>();
        this.lMapFinAccountByNumber = new Map<String, ContaFinanceira__c>();
    }

    public void createCases() {
        getAndMapccounts(this.lLstData);

        for (Map<String, Object> caseData : this.lLstData) {
            String accountNumber = (String) caseData.get('Número da Conta Financeira');

            Case createdCase = CreateCaseBatchHelper.buildCase(caseData, this.lMapFinAccountByNumber.get(accountNumber));

            if (String.isBlank(createdCase.AccountId)) {
                CreateCaseBatchHelper.fillAccountFromIDC(createdCase);
            }

            this.lLstCreatedCases.add(createdCase);
        }

        if (!this.lLstCreatedCases.isEmpty()) {
            insertCasesAndSaveFailed();
        }
    }

    private void getAndMapccounts(List<Map<String, Object>> lLstCaseData) {
        Set<String> lSetNumContaFinanceira = new Set<String>();
        for (Map<String, Object> caseData : lLstCaseData) {
            String accountNumber = (String) caseData.get('Número da Conta Financeira');

            if (String.isBlank(accountNumber)) {
                continue;
            }

            lSetNumContaFinanceira.add(accountNumber);
        }

        if (!lSetNumContaFinanceira.isEmpty()) {
            this.lMapFinAccountByNumber = CreateCaseBatchHelper.mapFinancialAccounts(lSetNumContaFinanceira);
        }
    }

    private void insertCasesAndSaveFailed() {
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;

        List<Database.SaveResult> saveResults = Database.insert(this.lLstCreatedCases, dmlOpts);
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                Map<String, Object> caseData = this.lLstData[i];
                caseData.put('ErrorMessage', saveResults[i].getErrors()[0].getMessage() + ' / Campos: ' + saveResults[i].getErrors()[0].getFields());
                this.lLstFailedImportData.add(caseData);
            }
        }
    }

    public void createBulkRecordDetails() {
        List<BulkRecordDetail__c> lLstBulkRecordDetails = new List<BulkRecordDetail__c>();

        for (Map<String, Object> caseData : this.lLstFailedImportData) {
            lLstBulkRecordDetails.add(CreateCaseBatchHelper.buildBulkRecordDetail(caseData));
        }

        Database.insert(lLstBulkRecordDetails);
    }

    public void sendNotification() {
        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'BulkActionNotification'];
        Id userId = Userinfo.getUserId();
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setTitle('Gerenciador de Casos: Abertura em Massa');
        customNotificationObj.setBody('Arquivo importado com sucesso!');
        customNotificationObj.setTargetId('000000000000000AAA');
        customNotificationObj.setNotificationTypeId(cnType.id);
        customNotificationObj.setSenderId(userId);
        customNotificationObj.send(new Set<String> {userId});
    }
}