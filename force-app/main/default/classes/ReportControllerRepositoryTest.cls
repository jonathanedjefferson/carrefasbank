@isTest
public with sharing class ReportControllerRepositoryTest {
   
    @isTest
    public static void findReportsByDeveloperNamesTest(){
        ReportControllerRepository repository = new ReportControllerRepository();
        Test.startTest();
            List<Report> reports = repository.findReportsByDeveloperNames(new List<string>{'Relatório Report Controller Repository Test'});
        Test.stopTest();
        system.assertEquals(reports.size(), 0);
    }
}