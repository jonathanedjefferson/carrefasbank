public class CalendarioCarinaFrasesBatch implements Database.Batchable<CalendarioCarinaFrasesSaudacao__c>, Database.Stateful{

    private String contentDocumentId;
    public CalendarioCarinaFrasesBatch(String contentDocumentId){
       this.contentDocumentId = contentDocumentId;
    }

    public Iterable<CalendarioCarinaFrasesSaudacao__c> start(Database.BatchableContext context) {
        ContentVersion objVersion = [SELECT Id, VersionData, title FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];
    
        List<CalendarioCarinaFrasesSaudacao__c> newRecords = new List<CalendarioCarinaFrasesSaudacao__c>();
		List<CalendarioCarinaFrasesSaudacao__c> recordsToUpdate = new List<CalendarioCarinaFrasesSaudacao__c>();
        System.debug(objVersion.VersionData.toString());
        List<String> csvLines = objVersion.VersionData.toString().split('\r\n');
        
        //Seleciona todos os objetos e faz um map de <objeto, data>
        Map<CalendarioCarinaFrasesSaudacao__c, String> mapObjetoPorData = new Map<CalendarioCarinaFrasesSaudacao__c, String>();
        List<CalendarioCarinaFrasesSaudacao__c> objetosEncontrados = [SELECT Id, Tema__c, Frase2__c, Fraseologia__c, Onde__c, DiaSemana__c, DataString__c FROM CalendarioCarinaFrasesSaudacao__c];
        for (CalendarioCarinaFrasesSaudacao__c objeto : objetosEncontrados) {
            String data = objeto.DataString__c;
            mapObjetoPorData.put(objeto, data);
        }

        //Ignora a primeira linha (cabeçalho) iniciando o loop do índice 1
        for (Integer i = 1; i < csvLines.size(); i++) {
            String csvRecord = csvLines[i];
            String[] csvRecordData = csvRecord.split(';');
            
            //Verifica se já existe um objeto com essa data na org
            if (mapObjetoPorData.values().contains(csvRecordData[0])) {
                CalendarioCarinaFrasesSaudacao__c itemAtualizar = new CalendarioCarinaFrasesSaudacao__c();

                for (CalendarioCarinaFrasesSaudacao__c objeto : mapObjetoPorData.keySet()) {
                    String dataNoMapa = mapObjetoPorData.get(objeto);
                    if (dataNoMapa != null && dataNoMapa == (csvRecordData[0])) {
                        itemAtualizar = objeto;
                    }
                }

                itemAtualizar.DiaSemana__c = csvRecordData[1];
                itemAtualizar.Onde__c = csvRecordData[2];
                itemAtualizar.Fraseologia__c = csvRecordData[3];
                itemAtualizar.Frase2__c = csvRecordData[4];
                itemAtualizar.Tema__c = csvRecordData[5];
                recordsToUpdate.add(itemAtualizar);
            } else {
                CalendarioCarinaFrasesSaudacao__c ofertas = new CalendarioCarinaFrasesSaudacao__c();
                System.debug('tamanho lista: ' + csvRecordData.size());
                for(Integer test = 0; test < csvRecordData.size(); test++) {
                    System.debug('item coisa: ' + csvRecordData[test]);
                }
                ofertas.DataString__c = csvRecordData[0];
                ofertas.DiaSemana__c = csvRecordData[1];
                ofertas.Onde__c = csvRecordData[2];
                ofertas.Fraseologia__c = csvRecordData[3];
                ofertas.Frase2__c = csvRecordData[4];
                ofertas.Tema__c = csvRecordData[5];
                newRecords.add(ofertas);
            }
        }      

        if(recordsToUpdate != null) {
            System.debug('já existem');
            update recordsToUpdate;
        }

        System.debug('resultado');
        System.debug(newRecords);
        return newRecords;
    }  
      
    public void execute(Database.BatchableContext context, List<CalendarioCarinaFrasesSaudacao__c> scope){
        if(scope != null) {
            insert scope;
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('Batch executado.');
    }
}