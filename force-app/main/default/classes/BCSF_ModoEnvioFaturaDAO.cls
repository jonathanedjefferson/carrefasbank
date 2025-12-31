public without sharing class BCSF_ModoEnvioFaturaDAO {
    private static final BCSF_ModoEnvioFaturaDAO instance = new BCSF_ModoEnvioFaturaDAO();

    public static BCSF_ModoEnvioFaturaDAO getInstance() { return instance; }

    public ContaFinanceira__c getContaFinanceira(String idContaFinanceira) {
        List<ContaFinanceira__c> lst = [SELECT 
                                            Id,
                                            NomeCliente__r.CPF__c,
                                            Email__c,
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
                                            CelularSeguro__c
                                        FROM 
                                            ContaFinanceira__c WHERE id =: idContaFinanceira];
        return lst.isEmpty() ? null : lst[0];
    }
    public Case getCase(String caseId) {
        List<Case> lst = [SELECT CaseNumber FROM Case WHERE Id = :caseId];
        return lst.isEmpty() ? null : lst[0];
    }
}