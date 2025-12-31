public with sharing class BCSF_CLS_BusinessHours {
@TestVisible
    private static Datetime dtNow;
    @InvocableMethod(label='IsWithinBusinessHours' description='Returns if the record is within the business hours')
    public static List<Boolean> isWithin(List<String> businessHoursID){
        Datetime now = dtNow == null? Datetime.now() : dtNow;
        List<Boolean> result = new List<Boolean>();
        for (Id bid : businessHoursID)
    
    { result.add(BusinessHours.isWithin(bid, now)); }
    return result;
	}
}