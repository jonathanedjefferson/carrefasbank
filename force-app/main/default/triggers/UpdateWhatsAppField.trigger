trigger UpdateWhatsAppField on User (after insert, after update) {
    // Coletar os IDs dos usuários que foram inseridos ou atualizados
    Set<Id> userIds = new Set<Id>();
    for (User u : Trigger.new) {
        userIds.add(u.Id);
    }

    // Consultar as permissões de conjunto de licença do usuário (PermissionSetLicenseAssignment)
    List<PermissionSetLicenseAssign> userLicenses = [
        SELECT AssigneeId,PermissionSetLicense.MasterLabel
        FROM PermissionSetLicenseAssign
        WHERE AssigneeId IN :userIds
    ];

    // Criar um conjunto para armazenar os usuários com a licença "Messaging User"
    Set<Id> usersWithMessagingUserLicense = new Set<Id>();

    for (PermissionSetLicenseAssign psa : userLicenses) {
        if (psa.PermissionSetLicense.MasterLabel == 'Messaging User') {
            usersWithMessagingUserLicense.add(psa.AssigneeId);
        }
    }
    

    // Atualizar os usuários que têm a licença "Messaging User"
    List<User> usersToUpdate = new List<User>();
    for (User u : [
        SELECT Id, Usuario_de_whatsapp__c 
        FROM User 
        WHERE Id IN :usersWithMessagingUserLicense and Usuario_de_whatsapp__c=false
    ]) {
        u.Usuario_de_whatsapp__c = true;  // Marca o campo de "Usuário de WhatsApp"
        usersToUpdate.add(u);
    }

    // Atualizar os usuários
    if (!usersToUpdate.isEmpty()) {
        update usersToUpdate;
    }
}