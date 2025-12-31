global class ContentDocumentExpurgoSchedule implements Schedulable{
    global static String start() {
        String pCronExp = '0 0 2 * * ?';
        String jobId = System.schedule(ContentDocumentExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ContentDocumentExpurgoSchedule());
        return jobId;
    }

    global static String start(String pCronExp) {
        String jobId = System.schedule(ContentDocumentExpurgoSchedule.class.getName() + '-' + System.currentTimeMillis(), pCronExp, new ContentDocumentExpurgoSchedule());
        return jobId;
    }
    
    global void execute(SchedulableContext sc){
        ContentDocumentExpurgoBatch.start();
        ExpurgoFileVarejoBatch.start();
    }
}