public class CriarTabelaLojasController {
    @AuraEnabled
    public static void uploadFile(Id idContentDocument){        
        Database.executeBatch(new CriarTabelaLojasBatch(idContentDocument));
   }
}