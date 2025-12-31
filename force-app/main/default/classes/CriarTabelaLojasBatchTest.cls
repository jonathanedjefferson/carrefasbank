@isTest
public class CriarTabelaLojasBatchTest {
    
    @TestSetup
    static void setup(){  

        String conteudoArquivo ='Formato;Nome Loja; CNPJ; Sigla | Número;\r\n';
        conteudoArquivo += 'ATACADÃO;VILA GUILHERME;63960004350;721;';

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Teste Carga01';
        contentVersion.PathOnClient = 'TesteCarga.csv';
        contentVersion.VersionData = Blob.valueOf(conteudoArquivo);
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;
    }
    @isTest
    public static void testeFileLead(){
      
        Id getId = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'Teste Carga01' AND  isLatest=true].ContentDocumentId;   

        Test.startTest();
        CriarTabelaLojasController.uploadFile(getId);
        Test.stopTest();
        
        List<BaseLojas__c> baseLojas = [SELECT Id FROM BaseLojas__c];

        System.assertEquals(1, baseLojas.size(), 'O objeto não foi criado corretamente.');
    }
}