global class ContatoAtendimentoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
		String jobId = System.schedule(ContatoAtendimentoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ContatoAtendimentoSchedule());
        return jobId;
	}

    global static void start(String pCronExp) {
		System.schedule(ContatoAtendimentoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ContatoAtendimentoSchedule());
	}
    
    global void execute(SchedulableContext sc){
        ContatoAtendimentoBatch.start();
    }
}