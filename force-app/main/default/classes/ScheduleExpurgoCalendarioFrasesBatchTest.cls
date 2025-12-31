@isTest
private class ScheduleExpurgoCalendarioFrasesBatchTest {
    @isTest
    static void testSchedulable() {
        ScheduleExpurgoCalendarioFrasesBatch newSchedule = new ScheduleExpurgoCalendarioFrasesBatch();
        ScheduleExpurgoCalendarioFrasesBatch.scheduleBatch();
        newSchedule.execute(null);

    }
}