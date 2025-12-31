global class ChatVisitorExpurgoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 3 * * ?';
		String jobId = System.schedule(ChatVisitorExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ChatVisitorExpurgoSchedule());
        return jobId;
	}

    global static String start(String pCronExp) {
		String jobId = System.schedule(ChatVisitorExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ChatVisitorExpurgoSchedule());
        return jobId;
	}
    
    global void execute(SchedulableContext sc){
        ChatVisitorExpurgoBatch.start();
    }
}