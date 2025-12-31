global class FecharCasoExecucaoScheduler implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 1 * * ?';
		String jobId = System.schedule(FecharCasoExecucaoScheduler.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new FecharCasoExecucaoScheduler());
        return jobId;
	}

    global static void start(String pCronExp) {
		System.schedule(FecharCasoExecucaoScheduler.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new FecharCasoExecucaoScheduler());
	}
    
    global void execute(SchedulableContext sc){
        FecharCasoExecucaoBatch.start(100);
    }
}