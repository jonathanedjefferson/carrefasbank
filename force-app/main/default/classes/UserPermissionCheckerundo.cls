public class UserPermissionCheckerundo {
    public static Boolean hasMessagingPermission(Id userId) {
        List<PermissionSetLicenseAssign> psaList = [SELECT PermissionSetLicense.MasterLabel 
                                                  FROM PermissionSetLicenseAssign 
                                                  WHERE AssigneeId = :userId];
        for (PermissionSetLicenseAssign psa : psaList) {
            if (psa.PermissionSetLicense.MasterLabel == 'Messaging User') {
                return true;
            }
        }
      return false;
    }
    public static void updateUserPermissions() {
      List<User> usersToUpdate = new List<User>();

        List<User> allUsers = [SELECT Id , Usuario_de_whatsapp__c
                            FROM User 
                            WHERE IsActive = true 
                            AND Usuario_de_whatsapp__c = true];
        List<PermissionSetLicenseAssign> psaList = [SELECT AssigneeId, PermissionSetLicense.MasterLabel 
                                                FROM PermissionSetLicenseAssign 
                                                WHERE AssigneeId IN :allUsers];
        for (User u : allUsers) {
            Boolean hasMessagingPermission = false;
            for (PermissionSetLicenseAssign psa : psaList) {
                if (psa.AssigneeId == u.Id && psa.PermissionSetLicense.MasterLabel == 'Messaging User') {
                   hasMessagingPermission = true;
                    break; 
                }
            }
        if (hasMessagingPermission) {
            if (u.Usuario_de_whatsapp__c != true) {
                u.Usuario_de_whatsapp__c = true;
                usersToUpdate.add(u);
            }
        } else {
            if (u.Usuario_de_whatsapp__c != false) {
                u.Usuario_de_whatsapp__c = false;
                usersToUpdate.add(u);
            }
        }    
        }
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
        
        
    }
}