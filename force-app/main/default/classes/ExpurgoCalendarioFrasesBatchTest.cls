@isTest
private class ExpurgoCalendarioFrasesBatchTest {
    @isTest
    static void testBatchExecution() {
        List<CalendarioCarinaFrasesSaudacao__c> testRecords = new List<CalendarioCarinaFrasesSaudacao__c>();
        for (Integer i = 1; i <= 12; i++) {
            CalendarioCarinaFrasesSaudacao__c record = new CalendarioCarinaFrasesSaudacao__c();
            record.DataString__c = '01/' + (i < 10 ? '0' : '') + i + '/2023';
            testRecords.add(record);
        }
        insert testRecords;

        Date dataAtual = System.today();
        Integer mesAtual = dataAtual.month();

        Test.startTest();
        ExpurgoCalendarioFrasesBatch.start();
        Test.stopTest();
   
        Integer actualRecordsRemaining = [SELECT COUNT() FROM CalendarioCarinaFrasesSaudacao__c];
        if(mesAtual >= 3) {
            System.assert(actualRecordsRemaining < 12, 'Os registros não foram excluídos corretamente.');
        }
    }
}