public without sharing class RecordTypeDAO {
    
    public static List<RecordType> getRecordTypesByDeveloperName(Set<String> developerNames, String sObjectType){
        return [
            SELECT 
                Id, 
                Name, 
                DeveloperName, 
                SObjectType
            FROM 
                RecordType
            WHERE 
                SObjectType = :sObjectType AND 
                DeveloperName IN :developerNames
        ];
    }

}