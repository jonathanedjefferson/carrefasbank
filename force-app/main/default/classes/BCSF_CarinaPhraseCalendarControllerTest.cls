/************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:            *
*   - BCSF_CarinaPhraseCalendarController               86%             *
*   - BCSF_CarinaPhraseCalendarDAO                      100%            *
*   - BCSF_CarinaPhraseCalendarBO                       95%             *
*   - BCSF_CalendarioFrasesTrigger                      100%            *
*************************************************************************/

@isTest
public class BCSF_CarinaPhraseCalendarControllerTest {
    @TestSetup
    static void setup(){  
        String conteudoArquivo ='Data;Dia da semana; Onde; Fraseologia; Frase; Tema;\r\n';
        conteudoArquivo += '01/01/2023;terça-feira;qualquer;teste;uma;Tema Teste';

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Teste Carga01';
        contentVersion.PathOnClient = 'TesteCarga.csv';
        contentVersion.VersionData = Blob.valueOf(conteudoArquivo);
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;

        Calendario_Frases_Saudacoes__c ofertas = new Calendario_Frases_Saudacoes__c();
            ofertas.Data__c = Date.newInstance(2023, 01, 01);
            ofertas.DataString__c = '01/01/2023';
            ofertas.DiaSemana__c = 'segunda-feira';
            ofertas.Onde__c = 'qualquer';
            ofertas.Fraseologia__c = 'teste';
            ofertas.Frase__c = 'uma';
            ofertas.Tema__c = 'dois';
        insert ofertas;
    }
    
    @isTest
    public static void fileUploadTest(){
        Id getId = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'Teste Carga01' AND  isLatest = true].ContentDocumentId;   

        Test.startTest();
        BCSF_CarinaPhraseCalendarController.uploadFile(getId);
        Test.stopTest();

        Calendario_Frases_Saudacoes__c ofertas = [SELECT DiaSemana__c, Tema__c FROM Calendario_Frases_Saudacoes__c WHERE DataString__c = '01/01/2023'];  

        System.AssertEquals(ofertas.DiaSemana__c, 'terça-feira');
        System.AssertEquals(ofertas.Tema__c, 'Tema Teste');
    }

    @isTest
    public static void deleteFileTest(){
        Id getId = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'Teste Carga01' AND  isLatest = true].ContentDocumentId;   

        Test.startTest();
        BCSF_CarinaPhraseCalendarController.deleteFile(getId);
        Test.stopTest();

        System.AssertEquals(0,  [SELECT COUNT() FROM ContentDocument]);
    }
}