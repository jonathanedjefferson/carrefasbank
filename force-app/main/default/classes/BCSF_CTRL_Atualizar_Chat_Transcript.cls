public with sharing class BCSF_CTRL_Atualizar_Chat_Transcript implements Queueable{
    
    protected Id idLCTranscript;
    
    public BCSF_CTRL_Atualizar_Chat_Transcript(Id idTranscript) {
        this.idLCTranscript = idTranscript;
    }

    public BCSF_CTRL_Atualizar_Chat_Transcript() { } 
    
    public void execute(QueueableContext context) {
        updateChatTranscript(idLCTranscript);
    }
    
    private void updateChatTranscript(Id idTranscript) {
        LiveChatTranscript transcript = [Select id, CPF__c, PrimeiroNome__c, Sobrenome__c, ChaveContaFinanceira__c, ChaveCartao__c, AccountId from LiveChatTranscript where id=: idTranscript];
        ContaFinanceira__c[] contaFinanc = [Select id, NumeroConta__c, NomeCliente__r.Name, NomeCliente__r.Id from ContaFinanceira__c where NumeroConta__c =: transcript.ChaveContaFinanceira__c];
        Asset[] ativo = [Select id from Asset where NumeroCartao__c =: transcript.ChaveCartao__c];
        
        if(contaFinanc.size() > 0){
            if(transcript.ChaveContaFinanceira__c == contaFinanc[0].NumeroConta__c){
                transcript.AccountId = contaFinanc[0].NomeCliente__r.Id;
                transcript.ContaFinanceira__c = contaFinanc[0].Id;   
                
                if(ativo.size() > 0) {
                    if (ativo[0].Id != null) {
                        transcript.Cartao__c = ativo[0].Id;
                    }
                }
                
                try {
                    Database.update(transcript);  
                } catch (DmlException dml) {
                    System.debug('The following exception has occurred: ' + dml.getMessage());  
                } 
                
            }
        } else {
            Account[] acc = [Select Id from Account where CPF__c =: transcript.CPF__c];
            RecordType recordTp = [Select Id from RecordType where DeveloperName =: 'BCSF_RT_PAC_ClientePessoalCarrefour' and SobjectType =: 'Account'];
            if(acc.size() > 0) { 
                if(transcript.AccountId == null) {
                    transcript.AccountId = acc[0].Id;
                }
                
                if(ativo.size() > 0 && ativo[0].Id != null) {
                    transcript.Cartao__c = ativo[0].Id;
                }
                
                try {
                    Database.update(transcript);  
                } catch (DmlException dml) {
                    System.debug('The following exception has occurred: ' + dml.getMessage());  
                } 
                
            } else {
                if(transcript.CPF__c != null && transcript.PrimeiroNome__c != null && transcript.Sobrenome__c != null){
                    Account accNew = new Account();
                    accNew.CPF__c = transcript.CPF__c;
                    accNew.FirstName = transcript.PrimeiroNome__c;
                    accNew.LastName = transcript.Sobrenome__c;
                    accNew.RecordTypeId = recordTp.Id;
                    
                    try {
                        Database.insert(accNew);
                        transcript.AccountId = accNew.Id;
                        Database.update(transcript);
                    } catch (DmlException dml) {
                        System.debug('The following exception has occurred: ' + dml.getMessage());
                    } 
                }
            }
        }
    }
}