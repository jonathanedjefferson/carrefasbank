global class RastreabilidadeTagueamentoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
		String jobId = System.schedule(RastreabilidadeTagueamentoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new RastreabilidadeTagueamentoSchedule());
        return jobId;
	}

    global static String start(String pCronExp) {
		String jobId = System.schedule(RastreabilidadeTagueamentoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new RastreabilidadeTagueamentoSchedule());
        return jobId;
	}
    
    global void execute(SchedulableContext sc){
        RastreabilidadeTagueamentoExpurgoBatch.start();
    }
}