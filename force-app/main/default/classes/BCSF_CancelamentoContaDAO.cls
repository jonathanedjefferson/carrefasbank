public with sharing class BCSF_CancelamentoContaDAO {
    private static final BCSF_CancelamentoContaDAO instance = new BCSF_CancelamentoContaDAO();

    public static BCSF_CancelamentoContaDAO getInstance() { return instance; }

    public ContaFinanceira__c getContaFinanceira(String idContaFinanceira) {
        List<ContaFinanceira__c> lst = [SELECT 
                                            Id,
                                            NomeCliente__c,
                                            NomeCliente__r.Name,
                                            NumeroConta__c, 
                                            TipoConta__c, 
                                            UnidadeNegocio__c, 
                                            StatusConta__c,
                                            NomeCliente__r.CPF__c,
                                            NomeCliente__r.DataNascimento__c
                                        FROM 
                                            ContaFinanceira__c WHERE id =: idContaFinanceira];
                                            /* accounts.CPF__C,
                                            DataNascimento__c */
        return lst.isEmpty() ? null : lst[0];
    }

    public user getUser(String userId){
        return [SELECT DRT__c FROM user WHERE Id =: userId];
    }

}