public class BCSF_CarinaPhraseCalendarBO {
    //Esse método tem o intuito de valídar se o CSV contém datas duplicadas
    public static List<Calendario_Frases_Saudacoes__c> validateDateCSV(Id idContentDocument) {
        List<Calendario_Frases_Saudacoes__c> cFrasesList = convertCsvRecord(idContentDocument);
        Set<Date> existingDates = new Set<Date>();
        List<Calendario_Frases_Saudacoes__c> validRecords = new List<Calendario_Frases_Saudacoes__c>();
        
        // VALIDANDO SE EXISTE DATA DUPLICADA NO ARQUIVO .CSV
        for (Calendario_Frases_Saudacoes__c cf : cFrasesList) {
            if (existingDates.contains(cf.Data__c)) {
                return new List<Calendario_Frases_Saudacoes__c>(); // Retorna lista vazia se houver datas duplicadas
            } else {
                existingDates.add(cf.Data__c);
                validRecords.add(cf); 
            }
        }

        // VALIDANDO SE EXISTE ALGUM REGISTRO DENTRO DA BASE COM ALGUMA DATA DO ARQUIVO .CSV
        List<Calendario_Frases_Saudacoes__c> listExistentes = BCSF_CarinaPhraseCalendarDAO.getCalendarioFrasesByData(existingDates);
        for (Calendario_Frases_Saudacoes__c itemValid: validRecords) {
            for (Calendario_Frases_Saudacoes__c itemExist: listExistentes) {
                if (itemExist.Data__c == itemValid.Data__c) {
                    itemValid.Id = itemExist.Id;
                    break;               
                }
            }
        }

        return validRecords; // Retorna a lista de registros válidos se não houver datas duplicadas
    }

    public static void updateEmojiPhrase(List <Calendario_Frases_Saudacoes__c> listaItens) {
        List<Emoji_Calendario__c> emojis = [SELECT Id, Name, Emoji__c FROM Emoji_Calendario__c];
        for(Calendario_Frases_Saudacoes__c calendarioItem: listaItens) {
            String frase = calendarioItem.Frase__c;
            for(Emoji_Calendario__c item: emojis) {
                frase = frase.replace(item.Name, item.Emoji__c);
            }
            calendarioItem.Frase__c = frase;
        }
    }

    public static List<Calendario_Frases_Saudacoes__c> convertCsvRecord(Id contentDocumentId){
        ContentVersion objVersion = BCSF_CarinaPhraseCalendarDAO.getVersionByContentDocument(contentDocumentId);
        List<Calendario_Frases_Saudacoes__c> newRecords = new List<Calendario_Frases_Saudacoes__c>();
        List<String> csvLines = objVersion.VersionData.toString().split('\r\n');
        
        for (Integer i = 1; i < csvLines.size(); i++) {
            String csvRecord = csvLines[i];
            String[] csvRecordData = csvRecord.split(';');
            
            Calendario_Frases_Saudacoes__c frases = new Calendario_Frases_Saudacoes__c();
            frases.Data__c = Date.newInstance(Integer.valueOf(csvRecordData[0].split('/')[2]), Integer.valueOf(csvRecordData[0].split('/')[1]), Integer.valueOf(csvRecordData[0].split('/')[0]));
            frases.DataString__c = csvRecordData[0];
            frases.DiaSemana__c = csvRecordData[1];
            frases.Onde__c = csvRecordData[2];
            frases.Fraseologia__c = csvRecordData[3];
            frases.Frase__c = csvRecordData[4];
            frases.Tema__c = csvRecordData[5];
            newRecords.add(frases);
        }  
        return newRecords;
    }    
}