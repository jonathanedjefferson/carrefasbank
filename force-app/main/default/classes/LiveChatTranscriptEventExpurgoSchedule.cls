global class LiveChatTranscriptEventExpurgoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
		String jobId = System.schedule(LiveChatTranscriptEventExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new LiveChatTranscriptEventExpurgoSchedule());
        return jobId;
	}

    global static String start(String pCronExp) {
		String jobId = System.schedule(LiveChatTranscriptEventExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new LiveChatTranscriptEventExpurgoSchedule());
        return jobId;
	}
    
    global void execute(SchedulableContext sc){
        LiveChatTranscriptEventExpurgoBatch.start();
    }
}