public class AlteracaoVencimentoDAO {
    public static ContaFinanceira__c getContaFinanceiraById(String contaFinanceiraId) {
        List<ContaFinanceira__c> lst = [
            SELECT 
                Id,
                NomeCliente__c,
                NomeCliente__r.Name,
                NumeroConta__c, 
                TipoConta__c, 
                UnidadeNegocio__c, 
                StatusConta__c,
                Telefone__c,
                Bairro__c,
                CEP__c,
                Cidade__c,
                Complemento__c,
                Rua__c,
                Estado__c,
                Numero__c,
                CelularSeguro__c,
                ModoRecebimentoFatura__c,
                Email__c,
                NomeCliente__r.CPF__c,
                NomeCliente__r.DataNascimento__c
            FROM 
                ContaFinanceira__c
            WHERE 
                Id = :contaFinanceiraId
        ];

        return lst.isEmpty() ? null : lst[0];
    }

    public static List<Asset> getAssetByContaFinanceira(String contaFinanceiraId) {
        List<Asset> lst = [
            SELECT 
                Id, 
                Product2.Name, 
                CartaoPrimario__c 
            FROM 
                Asset
            WHERE 
                ContaFinanceira__r.id = :contaFinanceiraId
        ];
        
        return lst;
    }

    public static Case getCase(String caseId) {
        List<Case> lst = [
            SELECT 
                Id,
                CaseNumber 
            FROM 
                Case 
            WHERE 
                Id = :caseId
        ];

        return lst.isEmpty() ? null : lst[0];
    }
}