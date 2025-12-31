global class ContatoAtendimentoBatch implements Database.Batchable<sObject> {
    global static void start() {
		Database.executeBatch(new ContatoAtendimentoBatch());
	}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Bairro__c, CEP__c, Cidade__c, Complemento__c, ContaFinanceira__c, Email__c, Endereco__c, Estado__c, Numero__c, NumeroConta__c, Telefone__c, NewValue__c, CelularSeguro__c FROM ContatoAtendimento__c WHERE NewValue__c = true';
         
        PontoContato__c pontoContato = PontoContato__c.getInstance('PontoContato');
        if (pontoContato != null) {
            if (pontoContato.TodosRegistros__c) {
                query = 'SELECT Bairro__c, CEP__c, Cidade__c, Complemento__c, ContaFinanceira__c, Email__c, Endereco__c, Estado__c, Numero__c, NumeroConta__c, Telefone__c, NewValue__c, CelularSeguro__c FROM ContatoAtendimento__c';
            }
        }

        return Database.getQueryLocator(query);    
    }

    global void execute(Database.BatchableContext BC, list<ContatoAtendimento__c> records){   
        Map<String, ContatoAtendimento__c> mapIdContatoAtend = new Map<String, ContatoAtendimento__c>();         
        Map<String, String> mapIdEmail = new Map<String, String>();  
        Map<String, String> mapIdTelefone = new Map<String, String>();         
        Set<String> setNumConta = new Set<String>();

        for (ContatoAtendimento__c item: records) {
            item.NewValue__c = false;
            setNumConta.add(item.NumeroConta__c);
            mapIdEmail.put(item.NumeroConta__c, item.Email__c);
            mapIdTelefone.put(item.NumeroConta__c, item.Telefone__c);
            mapIdContatoAtend.put(item.NumeroConta__c, item);
        }

        update records;
        ContatoAtendimentoBO.UpdateContaFinanceira(setNumConta, mapIdEmail, mapIdTelefone, mapIdContatoAtend);
    }
    
    global void finish(Database.BatchableContext BC){

    }
}