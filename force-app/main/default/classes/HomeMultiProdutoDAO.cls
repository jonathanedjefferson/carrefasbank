public class HomeMultiProdutoDAO {
    public static List<ContaFinanceira__c> getContaFinanceirasByAccount(String AccountId) {
        List<ContaFinanceira__c> retorno = new List<ContaFinanceira__c>();
        retorno = [
            SELECT 
                Id, 
                Name,
                NumeroConta__c, 
                StatusConta__c, 
                Logotipo__c, 
                UnidadeNegocio__c, 
                NumeroContrato__c, 
                ValorTotal__c, 
                DataInicioConta__c, 
                StatusContrato__c, 
                StatusContaDigital__c,
                CartaoTransversal__c,
                RecordType.DeveloperName
            FROM 
                ContaFinanceira__c
            WHERE 
                NomeCliente__r.Id = :AccountId
        ];

        return retorno;
    }
}