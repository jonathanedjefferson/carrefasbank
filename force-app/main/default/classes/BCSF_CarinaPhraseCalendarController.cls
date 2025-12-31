public class BCSF_CarinaPhraseCalendarController {
    @AuraEnabled
    public static void uploadFile(Id idContentDocument){ 
        List<Calendario_Frases_Saudacoes__c> resultList = BCSF_CarinaPhraseCalendarBO.validateDateCSV(idContentDocument);

        if(resultList.size() == 0){
            throw new AuraHandledException('Datas duplicadas encontradas na lista.');
        }else{
            upsert resultList;
        }
    }

    @AuraEnabled
    public static void deleteFile(Id idContentDocument){ 
        delete BCSF_CarinaPhraseCalendarDAO.getDocumentById(idContentDocument);
    }
}