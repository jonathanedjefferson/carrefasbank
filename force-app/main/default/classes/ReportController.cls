public class ReportController{
    ReportControllerRepository repository;
    public ReportController(){
        repository = new ReportControllerRepository();
    }
    public Boolean executed;
    public void generateReport(List<string> reportDevNames, String[] emailsToAdress, String displayName, String subject)
    {
        try
        {
            List <Report> reportList = repository.findReportsByDeveloperNames(reportDevNames);
            if(reportList.size()<=0) throw new ReportControllerException('Nenhum report encontrado na lista de nomes:' + String.join(reportDevNames,', '));
            List<Messaging.EmailFileAttachment> attach = new List<Messaging.EmailFileAttachment>();

            for (Report report : reportList) {
                Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
                
                String reportId = report.Id;
            
                string reportName = report.Name;
                
                String instanceName = URL.getOrgDomainURL().toExternalForm();
                
                string url=instanceName+'/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId='+reportId;
                
                ApexPages.PageReference objPage = new ApexPages.PageReference(url);
                Blob body = Test.isRunningTest() ? Blob.valueOf('test') : objPage.getContent();

                objMsgEmailAttach.setFileName(reportName+'.xlsx');
                objMsgEmailAttach.setBody(body);
                objMsgEmailAttach.setContentType('text/csv');
                
                attach.add(objMsgEmailAttach);
                
            }
            
            Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
            
            email.setFileAttachments(attach);  
            
            EmailService service=new EmailService(email);
            service.body='Olá, <br/><br/> Seguem os anexos '+String.join(reportDevNames, ' / ')+'.<br/><br/>Obrigado!<br/>Admin';
            service.isAttachment = true;
            service.attachments = attach;
            service.isHtml=true;
            service.toAddresses=new List<string>();
            service.toAddresses.addAll(emailsToAdress);  
            service.displayName= displayName;
            service.subject=subject;
            service.sendMail();
            this.executed = true;

        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            this.executed = false;
         
        }
        
    }
  
    @TestVisible
    private void setRepository( ReportControllerRepository repository){
        this.repository = repository;
    }

    public class ReportControllerException extends Exception{}
}