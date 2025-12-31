global class WhatsappLicenseBatch implements Database.Batchable<SObject>, Database.Stateful {
    private String messagingUserLicenseId;

    // Construtor para buscar o ID dinamicamente
    public WhatsappLicenseBatch() {
        PermissionSetLicense psl = [
            SELECT Id FROM PermissionSetLicense WHERE MasterLabel = 'Messaging User' LIMIT 1
        ];
        messagingUserLicenseId = psl.Id;
        System.debug('Messaging User License ID: ' + messagingUserLicenseId);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT AssigneeId FROM PermissionSetLicenseAssign WHERE PermissionSetLicenseId = \'' + messagingUserLicenseId + '\'';
        System.debug('Query Locator Query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<PermissionSetLicenseAssign> scope) {
        Set<Id> userIdsWithPermission = new Set<Id>();
        for (PermissionSetLicenseAssign psla : scope) {
            userIdsWithPermission.add(psla.AssigneeId);
        }
        System.debug('User IDs with Permission: ' + userIdsWithPermission);

        // Atualizar os usuários com a licença marcada como true
        if (!userIdsWithPermission.isEmpty()) {
            List<User> usersToUpdateTrue = [
                SELECT Id, Usuario_de_whatsapp__c FROM User WHERE Id IN :userIdsWithPermission
            ];
            System.debug('Users to Update (True): ' + usersToUpdateTrue);
            for (User user : usersToUpdateTrue) {
                user.Usuario_de_whatsapp__c = true;
            }
            update usersToUpdateTrue;
        }

        // Atualizar usuários sem a licença para false
        List<User> usersToUpdateFalse = [
            SELECT Id, Usuario_de_whatsapp__c FROM User WHERE Usuario_de_whatsapp__c = true 
            AND Id NOT IN :userIdsWithPermission
        ];
        System.debug('Users to Update (False): ' + usersToUpdateFalse);
        for (User user : usersToUpdateFalse) {
            user.Usuario_de_whatsapp__c = false;
        }
        update usersToUpdateFalse;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch process completed.');
    }
}