public without sharing class CloseTabEndChatController {
    @AuraEnabled
    public static Decimal getMinutos(){
        return CloseTabEndChatDAO.getInstance().getFirst().Minutos__c;
    }
}