public without sharing class CashbackAccountStatusControlService {
    public static ContaFinanceira__c getCashbackCustomerInfo(String accountId) {
        if (String.isBlank(accountId)) {
            return null;
        }

        List<ContaFinanceira__c> lLstFinancialAccounts = [SELECT Id, NomeCliente__r.Name, CPFBanco__c, Produto__c, 
            StatusContrato__c, NumeroContrato__c, IdConta__c FROM ContaFinanceira__c 
            WHERE Id =: accountId LIMIT 1];

        return !lLstFinancialAccounts.isEmpty() ? lLstFinancialAccounts[0] : null;
    }

    public static Case createCasePreventiveBlocking(Map<String, Object> lMapParams) {
        String cpf = (String) lMapParams.get('customerCpf');

        if (!Cashback.realizarBloqueioPreventivo(cpf, '', '')) {
           throw new AuraHandledException('Falha ao integrar');
        }

        updateCustomer(lMapParams, 'BloqueioTemporario');
        Case createdCase = buildCase(lMapParams);

        return insertCaseWithAssignmentRule(createdCase);
    }

    public static Case createCasePermanentBlocking(Map<String, Object> lMapParams) {
        String cpf = (String) lMapParams.get('customerCpf');

        if (!Cashback.realizarBloqueioDefinitivo(cpf, '', '')) {
           throw new AuraHandledException('Falha ao integrar');
        }

        updateCustomer(lMapParams, 'BloqueioDefinitivo');
        Case createdCase = buildCase(lMapParams);

        return insertCaseWithAssignmentRule(createdCase);
    }

    public static Case createCaseUnlockAccount(Map<String, Object> lMapParams) {
        String cpf = (String) lMapParams.get('customerCpf');
        String contractKey = (String) lMapParams.get('contractNumber');

        if (String.isBlank(contractKey) || String.isBlank(cpf)) {
            throw new AuraHandledException('Falha ao obter chave do contrato');
        }

        if (!Cashback.desbloquearConta(cpf, contractKey, '', '')) {
           throw new AuraHandledException('Falha ao integrar');
        }

        updateCustomer(lMapParams, 'Ativo');
        Case createdCase = buildCase(lMapParams);

        return insertCaseWithAssignmentRule(createdCase);
    }

    public static Case createCaseRequestUnlock(Map<String, Object> lMapParams) {
        Case createdCase = buildCase(lMapParams);

        return insertCaseWithAssignmentRule(createdCase);
    }

    public static Case createCaseCancelAccount(Map<String, Object> lMapParams) {
        String cpf = (String) lMapParams.get('customerCpf');
        String channel = (String) lMapParams.get('channel');

        if (!Cashback.cancelarConta(cpf, channel, '')) {
           throw new AuraHandledException('Falha ao integrar');
        }

        updateCustomer(lMapParams, 'Cancelado');
        Case createdCase = buildCase(lMapParams);

        return insertCaseWithAssignmentRule(createdCase);
    }

    private static Case buildCase(Map<String, Object> lMapParams) {
        Case newCase = new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CAS_Atendimento').getRecordTypeId();
        newCase.ContaFinanceira__c = (String) lMapParams.get('customerId');
        newCase.Origin = (String) lMapParams.get('origin');
        newCase.CanalEntrada__c = (String) lMapParams.get('channel');
        newCase.Assunto__c = (String) lMapParams.get('subject');
        newCase.Evento__c = (String) lMapParams.get('event');
        newCase.Motivo__c = (String) lMapParams.get('reason');
        newCase.Description = (String) lMapParams.get('description');
        newCase.Contratos__c = (String) lMapParams.get('contractNumber');
        newCase.Produto_c__c = 'Comprou Voltou';
        newCase.CriarCasoPorComponente__c = true;

        return newCase;
    }

    private static Case insertCaseWithAssignmentRule(Case lCase) {
        AssignmentRule caseAssignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];

        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = caseAssignmentRule.Id;
        lCase.setOptions(dmlOpts);

        try {
            insert lCase;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        Case createdCase = [SELECT Id, CaseNumber, OwnerId FROM Case WHERE Id =: lCase.Id LIMIT 1];
        return createdCase;
    }

    private static void updateCustomer(Map<String, Object> lMapParams, String lStatus) {
        String customerId = (String) lMapParams.get('customerId');

        try {
            update new ContaFinanceira__c(Id = customerId, StatusContrato__c = lStatus);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<Output> atualizaStatusContaComprouVoltou(List<Input> lLstInput) {

        if (validateInput(lLstInput)) {
            return executionError();
        }

        Boolean successExecution;
        String customerCpf = lLstInput.get(0).cpf;
        String actionType = lLstInput.get(0).actionType;
        String contractKey = lLstInput.get(0).contractKey;

        if ('CashbackUnlockAccount'.equals(actionType)) {
            successExecution = Cashback.desbloquearConta(customerCpf, contractKey, '', '');
        }
        else {
            successExecution = Cashback.realizarBloqueioDefinitivo(customerCpf, '', '');
        }

        if (!successExecution) {
            return executionError();
        }

        Output returnValue = new Output();
        returnValue.statusAPI = 'OK';
        returnValue.message = 'Atualização de Status realizada com sucesso';

        return new List<Output>{returnValue};
    }

    private static Boolean validateInput(List<Input> lLstInput) {
        if (lLstInput.isEmpty()) {
            return true;
        }

        String customerCpf = lLstInput.get(0).cpf;
        String actionType = lLstInput.get(0).actionType;

        if (String.isBlank(customerCpf) || String.isBlank(actionType)) {
            return true;
        }

        return false;
    }

    private static List<Output> executionError() {
        Output returnValue = new Output();
        returnValue.statusAPI = 'NOK';
        returnValue.message = 'Falha na execução';

        return new List<Output>{returnValue};
    }

    public class Input {
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String actionType;
        @InvocableVariable
        public String contractKey;
    }

    public class Output {
        @InvocableVariable
        public String statusAPI;
        @InvocableVariable
        public String message;
    }
}