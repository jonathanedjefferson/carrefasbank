public class VarejoAPICalloutDAO {
    
    private static final VarejoAPICalloutDAO instance = new VarejoAPICalloutDAO();

    public static VarejoAPICalloutDAO getInstance() {
      return instance;
    }

    public Varejo_Api_Callout__mdt getByLabel(String label) {
        List<Varejo_Api_Callout__mdt> lst = getBySetLabel(new Set<String>{ label });
        return lst.isEmpty() ? null : lst[0];
    }

    public List<Varejo_Api_Callout__mdt	> getBySetLabel(Set<String> setLabels) {
        return [
            SELECT  
                Label,
                apiKey__c,
                endpoint__c,
                method__c,
                password__c,
                token__c,
                username__c,
            	expertId__c,
            	appInstanceKey__c,
                clientId__c,
                clientSecret__c,
                cookie__c
            FROM
                Varejo_Api_Callout__mdt	
            WHERE
                Label IN :setLabels
        ];
    }

    public static String mockConfig;
}