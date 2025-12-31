public class UserPermissionChecker {
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

        List<User> allUsers = [SELECT Id 
                            FROM User 
                            WHERE IsActive = true 
                            AND Usuario_de_whatsapp__c = false];
        List<PermissionSetLicenseAssign> psaList = [SELECT AssigneeId, PermissionSetLicense.MasterLabel 
                                                FROM PermissionSetLicenseAssign 
                                                WHERE AssigneeId IN :allUsers];
        for (User u : allUsers) {
            for (PermissionSetLicenseAssign psa : psaList) {
                if (psa.AssigneeId == u.Id && psa.PermissionSetLicense.MasterLabel == 'Messaging User') {
                    u.Usuario_de_whatsapp__c = true;  
                    usersToUpdate.add(u);  
                    break; 
                }
            }
        }
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
        
        
    }
}