public inherited sharing class CaseAssignmentQueueable implements Queueable, Database.AllowsCallouts {

    Case currentCase;

    public CaseAssignmentQueueable(Case currentCase) {
        this.currentCase = currentCase;
    }

    public void execute(QueueableContext context) {
        getAccountIDC(this.currentCase);
    }

    public void getAccountIDC(Case cs){
        Account newAccount = IdentificaCockpitController.consultaContaPorCPF(cs.CPFCase__c, 'Cockpit');
        ContaFinanceira__c financialAccount = ContaFinanceiraDAO.getDadosContaFinanceiraNumero(cs.NumeroCF__c);

        String accoutId = newAccount.Id;
        String cfId = financialAccount.Id;

        cs.NomeCliente__c =  accoutId;
        cs.AccountId = accoutId;
        cs.ContaFinanceira__c = cfId;

        update cs;
    }

}