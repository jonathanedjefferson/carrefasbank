public class CarrefourAPICalloutDAO {
    
    private static final CarrefourAPICalloutDAO instance = new CarrefourAPICalloutDAO();

    public static CarrefourAPICalloutDAO getInstance() {
      return instance;
    }

    public CarrefourAPICallout__mdt getByLabel(String label) {
        List<CarrefourAPICallout__mdt> lst = getBySetLabel(new Set<String>{ label });
        return lst.isEmpty() ? null : lst[0];
    }

    public List<CarrefourAPICallout__mdt> getBySetLabel(Set<String> setLabels) {
        return [
            SELECT  
                Label,
                Access_Token__c,
                Authorization__c,
                Body__c,
                Database__c,
                Endpoint__c,
                Method__c,
                Path__c,
                Timeout__c,
                Type__c,
                UAT__c
            FROM 
                CarrefourAPICallout__mdt
            WHERE
                Label IN :setLabels
        ];
    }
}