public class HomeMultiProdutoController {
    @AuraEnabled
    public static List<ContaFinanceira__c> getContasFinanceiras(String AccountId) {
        return HomeMultiProdutoDAO.getContaFinanceirasByAccount(AccountId);
    }
}