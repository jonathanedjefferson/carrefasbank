public without sharing class IdentificacaoPositivaDAO {
    public static List<Asset> getAtivos(String contaFinanceiraId){
        return [
            SELECT 
                Id, 
                NomeReduzido__c, 
                NumeroCartao__c, 
                CPF__c, 
                CartaoPrimario__c,
                Status
            FROM 
                Asset 
            WHERE 
                ContaFinanceira__c = :contaFinanceiraId AND 
                (
                    Situacao__c = 'A' OR
                    CartaoPrimario__c = true
                )
        ];
    }

    public static List<StatusContaCancelada__mdt> getStatusCancelado(){
        return [
            SELECT 
                Label,
                DeveloperName
            FROM 
                StatusContaCancelada__mdt
        ];
    }

    public static ContaFinanceira__c getContaFinanceira(String contaFinanceiraId){
        List<ContaFinanceira__c> lst = [
            SELECT 
                Id,
                NomeCliente__c,
                NomeCliente__r.Name,
                NumeroConta__c, 
                TipoConta__c, 
                UnidadeNegocio__c, 
                StatusConta__c,
                NomeCliente__r.CPF__c,
                NomeCliente__r.DataNascimento__c,
                DataUltimaIdentificacaoPositiva__c,
                IdentificaoPositiva__c,
                EhBlindado__c,
                EhBlindadoFull__c
            FROM 
                ContaFinanceira__c WHERE id =: contaFinanceiraId
        ];
        return lst.isEmpty() ? null : lst[0];
    }
}