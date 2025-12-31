public class AccountDAO {

    public static Account getAccountById(Id accountId){
        List<Account> contas = getAccountsByLstId(new List<Id>{ accountId });
        return contas.isEmpty() ? null : contas[0];
    }

    public static List<Account> getAccountsByLstId(List<Id> accountIdLst) {
        return [
            SELECT 
                Id,
                CPF__c,
                Name
            FROM Account
            WHERE Id IN :accountIdLst
        ];
    }

    public static List<Account> getAccountsByCPF(List<String> cpfList) {
        return [
            SELECT 
                Id, 
                CPF__c,
                Name
            FROM Account
            WHERE CPF__c IN :cpfList
        ];
    }
}