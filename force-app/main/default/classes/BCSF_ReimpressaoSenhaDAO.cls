public without sharing class BCSF_ReimpressaoSenhaDAO {
    private static final BCSF_ReimpressaoSenhaDAO instance = new BCSF_ReimpressaoSenhaDAO();

    public static BCSF_ReimpressaoSenhaDAO getInstance() { return instance; }

    public ContaFinanceira__c getContaFinanceira(String idContaFinanceira) {
        List<ContaFinanceira__c> lst = [SELECT 
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
                                            NomeCliente__r.DataNascimento__c,
                                            Name
                                        FROM 
                                            ContaFinanceira__c WHERE id =: idContaFinanceira];
        return lst.isEmpty() ? null : lst[0];
    }
    public Case getCase(String caseId) {
        List<Case> lst = [SELECT CaseNumber FROM Case WHERE Id = :caseId];
        return lst.isEmpty() ? null : lst[0];
    }
}