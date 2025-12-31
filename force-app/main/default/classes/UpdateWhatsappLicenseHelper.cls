public class UpdateWhatsappLicenseHelper {
    @future
    public static void updateUsers(Set<Id> userIds, Boolean isInsert) {
        // Recupera os usuários para atualizar
        List<User> usersToUpdate = [
            SELECT Id, Usuario_de_whatsapp__c FROM User WHERE Id IN :userIds
        ];
        
        // Atualiza o campo com base na operação
        for (User user : usersToUpdate) {
            user.Usuario_de_whatsapp__c = isInsert;
        }
        
        // Executa a atualização em lote
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }
}