public class CriarTabelaLojasBatch implements Database.Batchable<BaseLojas__c>, Database.Stateful{
    private String contentDocumentId;
    public CriarTabelaLojasBatch(String contentDocumentId){
       this.contentDocumentId = contentDocumentId;
    }

    public Iterable<BaseLojas__c> start(Database.BatchableContext context) {
        ContentVersion objVersion = [SELECT Id, VersionData, title FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];
        //Caso já existam registros desse objeto, deleta os registros existentes.
        List<BaseLojas__c> existingRecords = [SELECT Id FROM BaseLojas__c];
        if(existingRecords.size() > 0) {
            delete existingRecords;
        }

        List<BaseLojas__c> newRecords = new List<BaseLojas__c>();
        List<String> csvLines = objVersion.VersionData.toString().split('\r\n');
        //Ignora a primeira linha (cabeçalho) iniciando o loop do índice 1
        for (Integer i = 1; i < csvLines.size(); i++) {
            String csvRecord = csvLines[i];
            String[] csvRecordData = csvRecord.split(';');
            
            BaseLojas__c ofertas = new BaseLojas__c();
            ofertas.Formato__c = csvRecordData[0];
            ofertas.NomeLoja__c = csvRecordData[1];
            String cnpj = csvRecordData[2];
            Integer desiredLength = 13;
            
            if (cnpj.length() <= desiredLength) {
                while (cnpj.length() < desiredLength) {
                    cnpj = '0' + cnpj;
                }
            }
            
            ofertas.CNPJ__c = cnpj;            
            ofertas.Sigla__c = csvRecordData[3];
            newRecords.add(ofertas);
        }      

        return newRecords;
    }  
      
    public void execute(Database.BatchableContext context, List<BaseLojas__c> scope){
        if(scope != null) {
            insert scope;
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('Batch executado.');
    }
}