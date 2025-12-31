global class LogIntegracaoExpurgoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
		String jobId = System.schedule(LogIntegracaoExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new LogIntegracaoExpurgoSchedule());
        return jobId;
	}

    global static String start(String pCronExp) {
		String jobId = System.schedule(LogIntegracaoExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new LogIntegracaoExpurgoSchedule());
        return jobId;
	}
    
    global void execute(SchedulableContext sc){
        LogIntegracaoExpurgoBatch.start();
    }
}