public without sharing class ConsultaCPFNoIDDAO {
    public static Account getAccountByCPF(String cpf) {
        List<Account> lst = [
            SELECT 
                Id,
                Name,
                FirstName,
                LastName,
                DataNascimento__c
            FROM 
                Account
            WHERE 
                CPF__c = :cpf
        ];

        return lst.size() == 0 ? null : lst[0];
    }

    public static RecordType getRecordType(String name){
        List<RecordType> lst = [
            SELECT 
                Id, 
                Name, 
                SobjectType 
            FROM 
                RecordType
            WHERE 
                Name = :name
        ];

        return lst.size() == 0 ? null : lst[0];
    }


    public static Map<String, RecordType> getRecordTypeBySobjectType(String objeto){
        Map<String, RecordType> mapRecordTypes = new Map<String, RecordType>();

        List<RecordType> lst = [
            SELECT 
                Id,
                DeveloperName 
            FROM 
                RecordType 
            WHERE 
                SobjectType = :objeto
                AND IsActive = true
        ];

        for(RecordType recordType : lst){
            mapRecordTypes.put(recordType.DeveloperName, recordType);
        }

        return mapRecordTypes;
    }
}