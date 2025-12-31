@isTest
public with sharing class ReportControllerTest {
   
    @isTest
    public static void generateReportTest(){
        ReportController controller = new ReportController();
        String payload = '[{"Id":"00O8B000000XXXXXXX","DeveloperName":"Report1","Name":"Sales Report"},{"Id":"00O8B000000XXXXXXY","DeveloperName":"Report2","Name":"Marketing Report"}]';
        controller.setRepository(new ReportControllerRepositoryMock(payload));
        Test.startTest();
            controller.generateReport(New List<String>{'Report1','Report2'},New List<String>{'test@gmail.com'} , 'Testando', 'Assunto');
        Test.stopTest();
        
        System.assertEquals(controller.executed, true);
    }

}