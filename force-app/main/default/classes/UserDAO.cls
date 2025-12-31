public with sharing class UserDAO {
    private static final UserDAO instance = new UserDAO();

    public static UserDAO getInstance() { return instance; }

    public user getUserDRT(String userId){
        return [SELECT DRT__c FROM user WHERE Id =: userId];
    }
}