global class PontoContatoEmailTelefoneScheduler implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
		String jobId = System.schedule(PontoContatoEmailTelefoneScheduler.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new PontoContatoEmailTelefoneScheduler());
        return jobId;
	}

    global static void start(String pCronExp) {
		System.schedule(PontoContatoEmailTelefoneScheduler.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new PontoContatoEmailTelefoneScheduler());
	}
    
    global void execute(SchedulableContext sc){
        PontoContatoEmailBatch.start();
        PontoContatoTelefoneBatch.start();
    }
}