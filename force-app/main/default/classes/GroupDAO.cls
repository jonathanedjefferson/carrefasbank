public with sharing class GroupDAO {
    private static final GroupDAO instance = new GroupDAO();

    public static GroupDAO getInstance() { return instance; }

    public Group getGroupById(String type, String developerName){
        return [
            SELECT Id 
            FROM Group 
            WHERE Type =: type 
            AND DeveloperName =: developerName 
            LIMIT 1];
    }
}