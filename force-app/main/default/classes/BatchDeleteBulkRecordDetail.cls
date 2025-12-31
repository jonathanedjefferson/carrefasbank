global without sharing class BatchDeleteBulkRecordDetail implements Database.Batchable<sObject>, Schedulable{
    private static PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgoErrosMassificado');
    private static final Date LIMIT_DATE = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, CreatedDate FROM BulkRecordDetail__c WHERE CreatedDate <: LIMIT_DATE');
    }

    global void execute(Database.BatchableContext bc, List<BulkRecordDetail__c> contextData) {
       if (contextData.isEmpty()) {
            return;
       }

       Database.delete(contextData);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Exclusão dos registros de Detalhe Registro em Massa finalizado!');
    }

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchDeleteBulkRecordDetail());
    }

    global static String runSchedule() {
        Datetime lDtCron = System.now().addMinutes(5);
        // runs every day at 1AM
        String lCron = ((!Test.isRunningTest()) ? '0 0 1' : String.join(new Object[]{ lDtCron.second(), lDtCron.minute(), lDtCron.hour() }, ' ')) + ' * * ?';
        String lJobName = 'Delete Detalhe Registro em Massa' + (Test.isRunningTest() ? lDtCron.format('yyyyMMddHHmmss') : '');
        return System.schedule(lJobName, lCron, new BatchDeleteBulkRecordDetail());
    }
}