@isTest
public class CalendarioCarinaFrasesBatchTest {
    
    @TestSetup
    static void setup(){  

        String conteudoArquivo ='Data;Dia da semana; Onde; Fraseologia; Frase; Tema;\r\n';
        conteudoArquivo += '01/01/2023;segunda-feira;qualquer;teste;uma;dois';

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Teste Carga01';
        contentVersion.PathOnClient = 'TesteCarga.csv';
        contentVersion.VersionData = Blob.valueOf(conteudoArquivo);
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;

        CalendarioCarinaFrasesSaudacao__c ofertas = new CalendarioCarinaFrasesSaudacao__c();
            ofertas.DataString__c = '01/01/2023';
            ofertas.DiaSemana__c = 'segunda-feira';
            ofertas.Onde__c = 'qualquer';
            ofertas.Fraseologia__c = 'teste';
            ofertas.Frase2__c = 'uma';
            ofertas.Tema__c = 'dois';
        insert ofertas;
    }
    @isTest
    public static void testeFileLead(){
      
        Id getId = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'Teste Carga01' AND  isLatest=true].ContentDocumentId;   

        Test.startTest();
        Database.executeBatch(new CalendarioCarinaFrasesBatch(getId));
        Test.stopTest();

        Integer totalLead = [SELECT Count() FROM CalendarioCarinaFrasesSaudacao__c WHERE DataString__c = '01/01/2023'];
        CalendarioCarinaFrasesSaudacao__c ofertas = [SELECT id 
                                            FROM CalendarioCarinaFrasesSaudacao__c 
                                            WHERE DataString__c = '01/01/2023'];  

        System.assertEquals(1, totalLead, 'Não conseguiu inserir as ofertas.');
    }
}