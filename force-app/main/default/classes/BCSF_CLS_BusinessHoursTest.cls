@isTest
public class BCSF_CLS_BusinessHoursTest {
    @IsTest
    static void isWithinTest(){
        Id orgBusinessHour = [SELECT Id FROM BusinessHours WHERE IsDefault = true].Id;
        List<String> businessHoursIds = new List<String>
        
        { (String) orgBusinessHour }
        ;
        List<Boolean> resultActual;
        List<Boolean> resultExpected = new List<Boolean>();
        Datetime now = Datetime.now();
        Test.startTest();
        BCSF_CLS_BusinessHours.dtNow = now;
        resultActual = BCSF_CLS_BusinessHours.isWithin(businessHoursIds);
        Test.stopTest();
        for (Id businessHourId : businessHoursIds)
        
        { resultExpected.add(BusinessHours.isWithin(businessHourId, now)); }
        System.assertEquals(resultActual, resultExpected);
        
    }
}