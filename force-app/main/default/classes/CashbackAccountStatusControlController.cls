public without sharing class CashbackAccountStatusControlController {
    @AuraEnabled
    public static ContaFinanceira__c getCashbackCustomerInfo(String accountId) {
        return CashbackAccountStatusControlService.getCashbackCustomerInfo(accountId);
    }

    @AuraEnabled
    public static Case createCase(Map<String, Object> lMapParams) {
        String actionType = (String) lMapParams.get('actionType');
        Case lCreatedCase;

        switch on actionType {
            when 'CashbackPreventiveBlocking' {
                lCreatedCase = CashbackAccountStatusControlService.createCasePreventiveBlocking(lMapParams);
            }	
            when 'CashbackPermanentBlocking' {
                lCreatedCase = CashbackAccountStatusControlService.createCasePermanentBlocking(lMapParams);
            }
            when 'CashbackUnlockAccount' {
                lCreatedCase = CashbackAccountStatusControlService.createCaseUnlockAccount(lMapParams);
            }
            when 'CashbackRequestUnlock' {
                lCreatedCase = CashbackAccountStatusControlService.createCaseRequestUnlock(lMapParams);
            }
            when 'CashbackCancelAccount' {
                lCreatedCase = CashbackAccountStatusControlService.createCaseCancelAccount(lMapParams);
            }
        }

        return lCreatedCase;
    }

    @InvocableMethod(label='Atualiza Status da Conta')
    public static List<CashbackAccountStatusControlService.Output> atualizaStatusContaComprouVoltou(List<CashbackAccountStatusControlService.Input> lLstInput) {
        return CashbackAccountStatusControlService.atualizaStatusContaComprouVoltou(lLstInput);
    }
}