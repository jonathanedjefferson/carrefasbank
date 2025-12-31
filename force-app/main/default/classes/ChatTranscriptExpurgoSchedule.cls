global class ChatTranscriptExpurgoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
		String jobId = System.schedule(ChatTranscriptExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ChatTranscriptExpurgoSchedule());
        return jobId;
	}

    global static String start(String pCronExp) {
		String jobId = System.schedule(ChatTranscriptExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ChatTranscriptExpurgoSchedule());
        return jobId;
	}
    
    global void execute(SchedulableContext sc){
        ChatTranscriptExpurgoBatch.start();
    }
}