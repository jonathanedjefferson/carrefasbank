public with sharing class CloseTabEndChatDAO {
    private static final CloseTabEndChatDAO instance = new CloseTabEndChatDAO();

    public static CloseTabEndChatDAO getInstance() { return instance; }

    public TimeCloseTabEndChat__mdt getFirst() 
    {
        List<TimeCloseTabEndChat__mdt> lst = getList();
        return lst.isEmpty() ? null : lst[0];
    }

    public List<TimeCloseTabEndChat__mdt> getList() 
    {
        return [SELECT 
                    Minutos__c
                FROM 
                    TimeCloseTabEndChat__mdt
                ];
    }
}