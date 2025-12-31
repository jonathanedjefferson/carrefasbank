public without sharing class BloqueioCartaoDAO {
    public static RecordType getRecordType(String objeto, String developerName){
        return [
            SELECT 
                Id 
            FROM 
                RecordType 
            WHERE 
                SobjectType = :objeto AND 
                DeveloperName = :developerName
        ];
    }


    public static Group getQueue(String tipo, String developerName){
        return [
            SELECT 
                Id, 
                Name, 
                DeveloperName, 
                Type 
            FROM 
                Group 
            WHERE 
                Type = :tipo AND 
                DeveloperName = :developerName
        ];
    }


    public static List<Asset> getAtivos(String contaFinanceiraId){
        return [
            SELECT 
                Id, 
                NomeReduzido__c, 
                NumeroCartao__c, 
                CPF__c 
            FROM 
                Asset 
            WHERE 
                ContaFinanceira__c = :contaFinanceiraId];
    }


    public static InfoStatus__c getInfoStatus(String status){
        return [
            SELECT 
                Descricao__c,
                Name
            FROM
                InfoStatus__c
            WHERE
                Name = :status
            LIMIT 1
        ];
    }
}