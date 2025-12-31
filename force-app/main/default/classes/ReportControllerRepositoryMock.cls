public with sharing class ReportControllerRepositoryMock extends ReportControllerRepository{
    private String payload;

    public ReportControllerRepositoryMock(String payload){
        this.payload = payload;
    }

    public override List<Report> findReportsByDeveloperNames(List<String> developerNames){
        return (List<Report> )JSON.deserialize(payload, List<Report>.class);
    }

}