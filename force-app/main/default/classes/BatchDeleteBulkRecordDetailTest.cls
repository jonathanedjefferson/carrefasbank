@isTest
private with sharing class BatchDeleteBulkRecordDetailTest {

    @TestSetup
    static void makeData(){
        PeriodoBatchExpurgo__c setting = new PeriodoBatchExpurgo__c(
            Name = 'DiasExpurgoErrosMassificado', 
            DiasExpurgo__c = 15
        );
        insert setting;
    }

    @isTest
    private static void testBatch() {
        BulkRecordDetail__c data = new BulkRecordDetail__c(
            ErrorMessage__c = 'Test error message',
            BusinessUnit__c = '1',
            ImportType__c = 'Abertura massificada',
            AccountNumber__c = '123456',
            Subject__c = 'Test subject',
            Event__c = 'Test event',
            CreatedDate = System.now().addDays(-100)
        );
        insert data;

        Test.startTest();
        Database.executeBatch( new BatchDeleteBulkRecordDetail());
        Test.stopTest();

        List<BulkRecordDetail__c> lLstBulkRecordDetail = [SELECT Id FROM BulkRecordDetail__c];
        Assert.areEqual(0, lLstBulkRecordDetail.size());
    }

    @isTest
    private static void testBatchWithoutRecords() {
        Test.startTest();
        Database.executeBatch( new BatchDeleteBulkRecordDetail());
        Test.stopTest();

        List<BulkRecordDetail__c> lLstBulkRecordDetail = [SELECT Id FROM BulkRecordDetail__c];
        Assert.areEqual(0, lLstBulkRecordDetail.size());
    }

     @isTest 
    static void testSchedule() {
        Test.startTest();
        String jobId = BatchDeleteBulkRecordDetail.runSchedule();
        Test.stopTest();
        
        CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

      	Assert.areEqual(0, ct1.TimesTriggered);
    }
}