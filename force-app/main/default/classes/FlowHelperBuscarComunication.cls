public with sharing class FlowHelperBuscarComunication {
    @invocableMethod(label='BuscarArquivoComunicado')
    public static List<Output> ArquivoDinamico(List<Input> inputs){
        List<Output> retorno = new List<Output>();
        Map<Id, Id> idsMap = new Map<Id, Id>();

        // Step 2: Query ContentVersion objects
        List<ContentVersion> contentVersionList = [
            SELECT Id, ContentDocumentId, VersionData, Title 
            FROM ContentVersion 
            WHERE Title = :inputs[0].contentVersionTitle
        ];

        List<ContentDistribution> lstContentDistribution = new List<ContentDistribution>();

        // Create outputs
        for (ContentVersion cv : contentVersionList) {
            Output output = new Output();
            output.idFile = cv.Id;
            retorno.add(output);

            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser=true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload=true;
            cd.PreferencesExpires=true;
            datetime expiryTime = datetime.now().addMinutes(120);
            cd.ExpiryDate = expiryTime;
            
            lstContentDistribution.add(cd);
        }

        insert lstContentDistribution;

        return retorno;
    }

    public class Input {
        @InvocableVariable(required = true)
        public String contentVersionTitle;
    }

    public class Output {
        @InvocableVariable(required = true)
        public Id idFile;
    }
}