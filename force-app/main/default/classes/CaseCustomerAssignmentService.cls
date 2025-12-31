public inherited sharing class CaseCustomerAssignmentService  {

    List<Case> newCases;
    Set<String> validSubjectEventkeys = new Set<String>();
    Map<String, String> recordTypeConfig = new Map<String, String>();
    Map<String, Account> mapAccountsByCPF = new Map<String, Account>();
    Map<String, ContaFinanceira__c> mapCardByAccoutNumber = new Map<String, ContaFinanceira__c>();
    List<Case> casesPendingAccountAssignment = new List<Case>();
    List<Case> casesCallIdentifyApi = new List<Case>();

    private static final List<Map<String, String>> RULES = new List<Map<String, String>>{
        new Map<String, String>{
            'Subject' => 'Seguros',
            'Event' => 'Informações de sinistro',
            'RecordType' => 'BCSF_RT_CAS_Atendimento'
        },
        new Map<String, String>{
            'Subject' => 'Sistema de valores a receber',
            'Event' => 'Devolução',
            'RecordType' => 'BCSF_RT_CAS_Atendimento'
        }
    };

    private static CaseCustomerAssignmentService instance;

    public CaseCustomerAssignmentService(List<Case> newCases) {
        this.newCases = newCases;
    }

    public void evaluateAccountAssignmentNeed() {
        try {
            generateMatchKeys();
            this.casesPendingAccountAssignment = rulesMatcher();
            if (!this.casesPendingAccountAssignment.isEmpty()) {
                getCustomerRelatedRecords();
                assignCaseRelatedRecords();
                if(!this.casesCallIdentifyApi.isEmpty()){
                    for (Case cs : this.casesCallIdentifyApi){
                        System.enqueueJob(new CaseAssignmentQueueable(cs));
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Erro ao avaliar necessidade de atribuição de conta: ' + e.getMessage());
        }

        return;
    }
    
    public void generateMatchKeys(){
        Set<String> validSubjectEventkeys = new Set<String>(); 
        Set<String> lstCasesRecordTypeToQuery = new Set<String>();
        for (Map<String, String> rule : RULES) {
            String key = rule.get('Subject') + ':' + rule.get('Event');
            validSubjectEventkeys.add(key);
            recordTypeConfig.put(key, rule.get('RecordType'));
        }
        this.validSubjectEventkeys = validSubjectEventkeys;
    }

    
    public List<Case> rulesMatcher() {
        List<Case> casesPendingAccountAssignment = new List<Case>();
        Set<String> recordTypesDeveloperNames = new Set<String>();
        Map<String, RecordType> recordTypeByDeveloperName = new Map<String, RecordType>();

        for (Case cs : this.newCases) {
            if (cs.CPFCase__c == null || cs.NumeroCF__c == null || cs.AccountId != null || cs.NomeCliente__c != null || cs.ContaFinanceira__c != null) {
                continue;
            }

            String key = cs.Assunto__c + ':' + cs.Evento__c;

            if (this.validSubjectEventkeys.contains(key)) {
                Case caseToUpdade = new Case();
                caseToUpdade.Id = cs.Id;
                caseToUpdade.Assunto__c = cs.Assunto__c;
                caseToUpdade.Evento__c = cs.Evento__c;
                caseToUpdade.CPFCase__c = cs.CPFCase__c;
                caseToUpdade.NumeroCF__c = cs.NumeroCF__c;
                casesPendingAccountAssignment.add(caseToUpdade);
                
                if(this.recordTypeConfig.containsKey(key)){
                    recordTypesDeveloperNames.add(this.recordTypeConfig.get(key));
                }
                
            }
            
        }

        if(!recordTypesDeveloperNames.isEmpty()){
            recordTypeByDeveloperName = getRecordTypesByDeveloperNames(recordTypesDeveloperNames, 'Case');
        }

        for(Case cs : casesPendingAccountAssignment){
            
            String key = cs.Assunto__c + ':' + cs.Evento__c; 
            String recTypeDeveloperName = recordTypeConfig.containsKey(key) ? recordTypeConfig.get(key) : '';

            if(recordTypeByDeveloperName.containsKey(recTypeDeveloperName)){
                cs.RecordTypeId = recordTypeByDeveloperName.get(recTypeDeveloperName).Id;
            }
            
        }

        return casesPendingAccountAssignment;
    }

    public Map<String, RecordType> getRecordTypesByDeveloperNames(Set<String> lstRecordTypeDevNames, String sObjectType){
        Map<String, RecordType> recordTypeByDeveloperName = new Map<String, RecordType>();
        List<RecordType> lstRecordType = RecordTypeDAO.getRecordTypesByDeveloperName(lstRecordTypeDevNames, sObjectType);

        for(RecordType rt : lstRecordType){
            recordTypeByDeveloperName.put(rt.DeveloperName, rt);
        }

        return recordTypeByDeveloperName;
    }

    public void getCustomerRelatedRecords(){
        List<String> lstCustomerCPF = new List<String>();
        List<String> lstCustomerAccountNumber= new List<String>();

        for(Case cs : this.casesPendingAccountAssignment){
            if(cs.CPFCase__c != null){
                lstCustomerCPF.add(cs.CPFCase__c);
            }
            if(cs.NumeroCF__c != null){
                lstCustomerAccountNumber.add(cs.NumeroCF__c);
            }
            
        }

        if(!lstCustomerCPF.isEmpty()){
            this.mapAccountsByCPF = getAccountsByCPF(lstCustomerCPF);
        }

        if(!lstCustomerAccountNumber.isEmpty()){
            this.mapCardByAccoutNumber = getContaFinanceiraByNumber(lstCustomerAccountNumber);
        }
    }

    public void assignCaseRelatedRecords(){
        List<Case> casesToUpdate = new List<Case>();

        for(Case cs : this.casesPendingAccountAssignment){
            String cpf = cs.CPFCase__c;
            String accountNumber = cs.NumeroCF__c;

            if(!this.mapAccountsByCPF.containsKey(cpf) || !this.mapCardByAccoutNumber.containsKey(accountNumber)){
                this.casesCallIdentifyApi.add(cs);
                continue;
            }

            Id accountId = mapAccountsByCPF.get(cpf).Id;
            Id financeAccountId = mapCardByAccoutNumber.get(accountNumber).Id;

            cs.AccountId = accountId;
            cs.NomeCliente__c = accountId;
            cs.ContaFinanceira__c = financeAccountId;

            casesToUpdate.add(cs);
        }

        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }

    public Map<String, Account> getAccountsByCPF(List<String> lstCPF){
        Map<String, Account> accountByCPF = new Map<String, Account>();
        List<Account> lstAccount = AccountDAO.getAccountsByCPF(lstCPF);

        for(Account acct : lstAccount){
            accountByCPF.put(acct.CPF__c, acct);
        }

        return accountByCPF;
    }

    public Map<String, ContaFinanceira__c> getContaFinanceiraByNumber(List<String> lstAccountNumber){
        Map<String, ContaFinanceira__c> cfByCPF = new Map<String, ContaFinanceira__c>();
        List<ContaFinanceira__c> lstCF = ContaFinanceiraDAO.getContaFinanceiraByNumberList(lstAccountNumber);

        for(ContaFinanceira__c cf : lstCF){
            cfByCPF.put(cf.NumeroConta__c, cf);
        }

        return cfByCPF;
    }

}