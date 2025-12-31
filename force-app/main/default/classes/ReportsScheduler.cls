global with sharing class ReportsScheduler implements Schedulable {
    
    public string cron;
    public String jobName;
    public string DISPLAY_NAME = 'Relatórios Picker';
    public string SUBJECT = 'RELATÓRIOS PICKER';

    global void execute(SchedulableContext sc) {
        ReportsScheduler.calloutCurrency(DISPLAY_NAME,SUBJECT);
    }

    public Id scheduleJob() {
        return System.schedule(jobName, cron, new ReportsScheduler());
    }

    
    @future(callout=true) public static void calloutCurrency(String DISPLAY_NAME,String SUBJECT){
        ReportsEmail__mdt meta = ReportsEmail__mdt.getInstance('Picker');
        ReportController controller = new ReportController();
        
        controller.generateReport(meta.Reports__c.split(';'),meta.Emails__c.split(';') , DISPLAY_NAME, SUBJECT);
    }
    
}