public class CalendarioCarinaFrasesController {
    @AuraEnabled
    public static void uploadFile(Id idContentDocument){        
        Database.executeBatch( new CalendarioCarinaFrasesBatch(idContentDocument));
   }
}