public with sharing class IdentificaCockpitDAO {
    
    private static final IdentificaCockpitDAO instance = new IdentificaCockpitDAO();
    
    public static IdentificaCockpitDAO getInstance() { return instance; }
    
    public List<ContaFinanceira__c> getContaByCliente(String accountId) {
        List<ContaFinanceira__c> lst = [SELECT 
                                            StatusConta__c, 
                                            UnidadeNegocio__c, 
                                            NumeroConta__c,
                                            NomeCliente__c, 
                                            NomeCliente__r.CPF__c 
                                        FROM ContaFinanceira__c 
                                        WHERE NomeCliente__c =: accountId];
        System.debug('lst => ' + lst);
        return lst;
        
    }
    
    public ContaFinanceira__c getContaByCliente(String accountId, String numeroConta) {
        List<ContaFinanceira__c> lst = [
        SELECT StatusConta__c, UnidadeNegocio__c, NumeroConta__c,
               NomeCliente__c, NomeCliente__r.CPF__c
        FROM ContaFinanceira__c
        WHERE NomeCliente__c = :accountId 
        AND NumeroConta__c = :numeroConta
        LIMIT 1
    ];
        System.debug('lst => '+ lst);
        return lst.isEmpty() ? null : lst[0];
    }
    
    public ContaFinanceira__c getContaById(String accountId) {
        List<ContaFinanceira__c> conta2 = [SELECT Id, Cep__c, Rua__c, Numero__c, Complemento__c, ModoRecebimentoFatura__c, Bairro__c, Cidade__c, NomeCliente__c, NumeroConta__c, UnidadeNegocio__c, CelularSeguro__c, NomeCliente__r.RecordType.IsPersonType, NomeCliente__r.CPF__c,
                                        	(SELECT Id, Cep__c, Endereco__c, Numero__c, Complemento__c, Bairro__c, Cidade__c
                                            FROM ContatosAtendimentos__r),
                                            (SELECT Id, NumeroCartao__c
                                            FROM Ativos__r)
                                        FROM ContaFinanceira__c 
                                        WHERE id =: accountId];
        
        return conta2.isEmpty() ? null : conta2[0];
    }
    
    public Account getAccoutById(String accountId){
        Account acc = [
            SELECT
                Id, CPF__c
            FROM Account
            WHERE Id = :accountId
        ];
        return acc;
    }
    public Account getAccoutByCPF(String cpf) {
        List<Account> contas = [
        SELECT Id 
        FROM Account 
        WHERE CPF__c = :cpf 
        LIMIT 1
    ];
        return contas.isEmpty() ? null : contas[0];
    }

        
        public static Map<String, ContaFinanceira__c> buscarContasFinanceirasPorNumeros(
            Id accountId,
        List<String> numerosConta
        ) {
            Map<String, ContaFinanceira__c> contas = new Map<String, ContaFinanceira__c>();
            
            if (accountId == null || numerosConta == null || numerosConta.isEmpty()) {
                return contas;
            }
            
            for (ContaFinanceira__c cf : [
            SELECT Id, NumeroConta__c, StatusConta__c, UnidadeNegocio__c, NomeCliente__c
            FROM ContaFinanceira__c
            WHERE NomeCliente__c = :accountId
            AND NumeroConta__c IN :numerosConta
        ]) {
                contas.put(cf.NumeroConta__c, cf);
            }
            
            return contas;
        }
    
    
    
    public Map<String, Product2>  getMapProduct() {
        Map<String, Product2> productCodeToRecordMap = new Map<String, Product2>();
        List<Product2> produtos = [SELECT Id, ProductCode FROM Product2];
        
        
        for (Product2 produto : produtos) {
            productCodeToRecordMap.put(produto.ProductCode, produto);
        }
        return productCodeToRecordMap.isEmpty() ? null : productCodeToRecordMap;
    }
}