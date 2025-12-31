public class BCSF_CarinaPhraseCalendarDAO {
    public static List<Calendario_Frases_Saudacoes__c> getCalendarioFrasesByData(Set<Date> listData){
        return [
            SELECT 
                Id,
                Data__c,
                DataString__c,
                DiaSemana__c,
                Onde__c,
                Fraseologia__c,
                Frase__c,
                Tema__c
            FROM 
                Calendario_Frases_Saudacoes__c
            WHERE
                Data__c in :listData
        ];
    }

    public static ContentVersion getVersionByContentDocument(Id contentDocumentId){
        return [
            SELECT 
                Id, 
                VersionData, 
                title 
            FROM 
                ContentVersion 
            WHERE 
                ContentDocumentId =: contentDocumentId
        ];
    }

    public static ContentDocument getDocumentById(Id contentDocumentId){
        return [SELECT Id FROM ContentDocument WHERE id =: contentDocumentId];
    }
}