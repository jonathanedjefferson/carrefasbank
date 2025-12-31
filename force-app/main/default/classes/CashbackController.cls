public without sharing class CashbackController {

    @AuraEnabled
    public static Cashback.Balance consultarSaldosNativos(String cpf, String canal, String unidadeNegocio){
        return Cashback.consultarSaldosNativos(cpf, canal, unidadeNegocio);
    }

    @AuraEnabled
    public static Cashback.Statement consultarExtrato(String cpf, String canal, String unidadeNegocio, Map<String, String> params){
        return Cashback.consultarExtrato(cpf, canal, unidadeNegocio, params);
    }

    @AuraEnabled
    public static Cashback.TransactionDetails consultarDetalhesTransacao(String cpf, String canal, String unidadeNegocio, String idTransacao){
        return Cashback.consultarDetalhesTransacao(cpf, canal, unidadeNegocio, idTransacao);
    }

    @AuraEnabled
    public static Cashback.FutureTransaction consultarTransacoesFuturas(String cpf, String canal, String unidadeNegocio){
        return Cashback.consultarTransacoesFuturas(cpf, canal, unidadeNegocio);
    }

    @AuraEnabled
    public static Cashback.ResultadoContestacaoCashback ContestarResgate(String cpf, String canal, String unidadeNegocio, String idTransacao){
        return Cashback.ContestarResgate(cpf, canal, unidadeNegocio, idTransacao);
    }

    @AuraEnabled
    public static Cashback.ResultadoAjusteCashback ajusteCashback(String cpf, String canal, String unidadeNegocio, String idTransacao, String dueAmount, String dueAmountBank){
        return Cashback.ajusteCashback(cpf, canal, unidadeNegocio, idTransacao, dueAmount, dueAmountBank);
    }

    @AuraEnabled
    public static ContaFinanceira__c getCashbackCustomerInfo(String cpf){
        return Cashback.getCashbackCustomerInfo(cpf);
    }
    

    @AuraEnabled
    public static Case createCase(Map<String, Object> lMapParams){
        return Cashback.createCase(lMapParams);
    }

    @AuraEnabled
    public static void updateCustomerBalance(Map<String, Object> aBalanceData){
       String cpf = (String) aBalanceData.get('cpf');
       if (String.isBlank(cpf)) {
        return;
       }
       
       Decimal rewardPoints = (Decimal) aBalanceData.get('rewardPoints');
       String expireDate = (String) aBalanceData.get('expireDate');
       String expireDateStr = String.isNotBlank(expireDate) ? expireDate.split('T')[0] : null;
            
       List<ContaFinanceira__c> lLstFinancialAccounts = [SELECT Id, Saldo__c, ValidoAte__c 
        FROM ContaFinanceira__c WHERE CPFBanco__c =: cpf AND RecordType.DeveloperName = 'Comprou_Voltou' LIMIT 1];

        if (lLstFinancialAccounts.isEmpty()) {
            return;
        }

        update new ContaFinanceira__c(
            Id = lLstFinancialAccounts[0].Id,
            Saldo__c = rewardPoints,
            ValidoAte__c = String.isNotBlank(expireDateStr) ? Date.valueOf(expireDateStr) : null
        );
    }
}