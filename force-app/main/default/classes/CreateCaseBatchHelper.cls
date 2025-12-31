public without sharing class CreateCaseBatchHelper {

    private static final Map<String, String> lMapFields = BulkCaseManagerController.getImportFields();
    private static final Map<String, Schema.SObjectField> lCaseFieldMap = Case.getSObjectType().getDescribe().fields.getMap();
    private static final Id RECORD_TYPE_ATENDIMENTO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CAS_Atendimento').getRecordTypeId();

    public static Map<String, ContaFinanceira__c> mapFinancialAccounts(Set<String> lSetNumContaFinanceira) {
        Map<String, ContaFinanceira__c> lMapFinAccountByNumber = new Map<String, ContaFinanceira__c>();
        List<ContaFinanceira__c> lLstFinAccounts = [SELECT Id, NumeroConta__c, NomeCliente__c, NumeroContrato__c, UnidadeNegocio__c 
            FROM ContaFinanceira__c WHERE (NumeroConta__c IN: lSetNumContaFinanceira OR NumeroContrato__c IN: lSetNumContaFinanceira)];

        for(ContaFinanceira__c lFinAccount : lLstFinAccounts) {
            if (String.isBlank(lFinAccount.NumeroConta__c)) {
                lMapFinAccountByNumber.put(lFinAccount.NumeroContrato__c, lFinAccount);
                continue;
            }

            lMapFinAccountByNumber.put(lFinAccount.NumeroConta__c, lFinAccount);
        }

        return lMapFinAccountByNumber;
    }

    public static Case buildCase(Map<String, Object> caseData, ContaFinanceira__c financialAccount) {
        Case newCase = new Case();

        for (String fieldLabel : lMapFields.keySet()) {
            Object value = caseData.get(fieldLabel);

            if (value == null) {
                continue;
            }
           
            //Atribui valores recebidos pela importação da planilha
            setFieldValue(newCase, lMapFields.get(fieldLabel), value);
        }

        newCase.AccountId = financialAccount?.NomeCliente__c;
        newCase.NomeCliente__c = financialAccount?.NomeCliente__c;
        newCase.ContaFinanceira__c = financialAccount?.Id;
        newCase.UnidadeNegocio__c = financialAccount?.UnidadeNegocio__c;
        newCase.RecordTypeId = RECORD_TYPE_ATENDIMENTO;
        newCase.CriarCasoPorComponente__c = true;
        newCase.FormaCriacao__c = 'Massificado';

        caseData.put('Unidade de Negócio', financialAccount?.UnidadeNegocio__c);

        return newCase;
    }
    
    public static BulkRecordDetail__c buildBulkRecordDetail(Map<String, Object> lCaseData) {
        return new BulkRecordDetail__c(
            ErrorMessage__c = (String) lCaseData.get('ErrorMessage'),
            BusinessUnit__c = (String) lCaseData.get('Unidade de Negócio'),
            ImportType__c = 'Abertura massificada',
            AccountNumber__c = (String) lCaseData.get('Número da Conta Financeira'),
            Subject__c = (String) lCaseData.get('Assunto'),
            Event__c = (String) lCaseData.get('Evento')
        );
    }

    public static BulkRecordDetail__c buildBulkRecordDetailUpdate(BulkCaseManagerController.UpdateCaseData lUpdateCaseData) {
        return new BulkRecordDetail__c(
            CaseNumber__c = lUpdateCaseData.CaseNumber,
            ErrorMessage__c = lUpdateCaseData.ErrorMessage,
            ImportType__c = 'Fechamento massificado'
        );
    }

    public static Case fillAccountFromIDC(Case unaccountedCase) {
        if (String.isBlank(unaccountedCase.NumeroCF__c)) {
            return unaccountedCase;
        }

        ContaFinanceira__c financialAccount = ContaFinanceiraDAO.getDadosContaFinanceiraNumero(unaccountedCase.NumeroCF__c);
        
        /*Essa lógica foi adicionada para o cenário em que está sendo importado um numero de conta que não existe na base da SF, 
            mas que aparece várias vezes dentro da tabela de importação*/

        if (financialAccount == null) {
            IdentificaCockpit.ResponseAPIContaFinanceira responseIdc = IdentificaCockpit.identificaNumeroConta(unaccountedCase.NumeroCF__c, '', '', '');
            String cpf = responseIdc?.data?.clientePorConta?.cpf;

            if (responseIdc == null || String.isBlank(cpf)) {
                return unaccountedCase;
            }

            getAccountFromIDC(cpf, unaccountedCase);
            return unaccountedCase;
        }

        //Caso a conta fincaneira tenha sido criada em uma interação anterior, não será chamada a integração com o IDC
        setAccount(unaccountedCase, financialAccount);

        return unaccountedCase;
    }

    private static void setFieldValue(Case aCase, String aFieldName, Object aFieldValue) {
        try {
            Schema.SObjectField field = lCaseFieldMap.get(aFieldName);
            String fieldType = String.valueOf(field.getDescribe().getSoapType());
    
            switch on (fieldType) {
                when 'BOOLEAN' {
                    aCase.put(aFieldName, ('1'.equals((String)aFieldValue) || 'TRUE'.equalsIgnoreCase((String)aFieldValue)));
                }
                when 'DATE' {
                    aCase.put(aFieldName, Date.valueOf((String)aFieldValue));
                }
                when 'DATETIME' {
                    aCase.put(aFieldName, DateTime.valueOf((String)aFieldValue));
                }
                when 'DOUBLE' {
                    aCase.put(aFieldName, Decimal.valueOf((String)aFieldValue));
                }
                when 'INTEGER' {
                    aCase.put(aFieldName, Decimal.valueOf((String)aFieldValue).intValue());
                }
                when else {
                    aCase.put(aFieldName, aFieldValue);
                }
            }
        } catch (Exception ex) {
            System.debug('Falha ao atribuir valor ao campo: ' + ex.getMessage());
            return;
        }
    }

    private static void getAccountFromIDC(String cpf, Case unaccountedCase) {
        Account newAccount = IdentificaCockpitController.consultaContaPorCPF(cpf, 'Cockpit');
        ContaFinanceira__c financialAccount = ContaFinanceiraDAO.getDadosContaFinanceiraNumero(unaccountedCase.NumeroCF__c);

        setAccount(unaccountedCase, financialAccount);
    }

    private static void setAccount(Case unaccountedCase, ContaFinanceira__c lFinAccount) {
        unaccountedCase.CPFCase__c = lFinAccount.NomeCliente__r.CPF__c;
        unaccountedCase.NomeCliente__c = lFinAccount.NomeCliente__c;
        unaccountedCase.AccountId = lFinAccount.NomeCliente__c;
        unaccountedCase.ContaFinanceira__c = lFinAccount.Id;
    }

    public static List<Case> getCases(Set<String> lSetCaseNumbers) {
        return [SELECT Id, Status, Resolucao__c, CaseNumber FROM Case WHERE CaseNumber IN: lSetCaseNumbers];
    }
}