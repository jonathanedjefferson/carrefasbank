public virtual class ReportControllerRepository {
    public virtual List<Report> findReportsByDeveloperNames(List<String> developerNames){
        return [SELECT Id,DeveloperName,Name FROM Report where DeveloperName IN:developerNames];
    }

}