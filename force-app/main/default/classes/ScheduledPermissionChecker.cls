public class ScheduledPermissionChecker implements Schedulable{
    public void execute(SchedulableContext context) {
        UserPermissionChecker.updateUserPermissions();
        UserPermissionCheckerundo.updateUserPermissions();
    }

}