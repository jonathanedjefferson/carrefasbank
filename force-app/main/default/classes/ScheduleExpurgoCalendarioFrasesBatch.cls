global class ScheduleExpurgoCalendarioFrasesBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        ExpurgoCalendarioFrasesBatch.start();
    }
    
    public static void scheduleBatch() {
        String cronExpression = '0 0 0 15 * ?'; // Executar no dia 15 de cada mês à meia-noite
        ScheduleExpurgoCalendarioFrasesBatch scheduler = new ScheduleExpurgoCalendarioFrasesBatch();
        if(!Test.isRunningTest()) {
            System.schedule('ScheduleExpurgoCalendarioFrasesBatch', cronExpression, scheduler);
        }
    }
}