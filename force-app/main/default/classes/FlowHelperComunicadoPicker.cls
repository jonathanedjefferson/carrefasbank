public with sharing class FlowHelperComunicadoPicker {
    @invocableMethod(label='BuscarComunicado')
    public static List<Output> ArquivoDinamico(List<Input> inputs){
        List<Output> retorno = new List<Output>();
        Map<Id, Id> idsMap = new Map<Id, Id>();

        // Assuming inputs now only contain contentVersionId
        for(Input item: inputs) {
            idsMap.put(item.contentVersionId, item.contentVersionId);
        }

        // Step 1: Extract the IDs from the idsMap
        Set<Id> contentVersionIds = idsMap.keySet();

        // Step 2: Query ContentVersion objects
        List<ContentVersion> contentVersionList = [
            SELECT Id, ContentDocumentId, VersionData, Title 
            FROM ContentVersion 
            WHERE Id IN :contentVersionIds
        ];

        // Step 3: Create a map for ContentVersion and retrieve ContentDocumentIds
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersionList);
        Set<Id> contentDataIds = new Set<Id>();
        for (ContentVersion cv : contentVersionList) {
            contentDataIds.add(cv.ContentDocumentId);
        }

        // Step 4: Query ContentDocument objects
        List<ContentDocument> contentDataList = [
            SELECT Id, Title, CreatedDate 
            FROM ContentDocument 
            WHERE Id IN :contentDataIds
        ];
        Map<Id, ContentDocument> contentDataMap = new Map<Id, ContentDocument>(contentDataList);

        // Step 5: Create the map of <ContentDocument, ContentVersion>
        Map<ContentDocument, ContentVersion> contentDataToVersionMap = new Map<ContentDocument, ContentVersion>();

        for (ContentVersion cv : contentVersionList) {
            ContentDocument contentData = contentDataMap.get(cv.ContentDocumentId);
            if (contentData != null) {
                contentDataToVersionMap.put(contentData, cv);
            }
        }

        // Step 6: Process the map
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        for (ContentDocument contentData : contentDataToVersionMap.keySet()) {
            ContentVersion contentVersion = contentDataToVersionMap.get(contentData);
            Blob baseFile = contentVersion.VersionData;

            ContentVersion itemContent = new ContentVersion(
                Title = contentData.Title + '.pdf',
                PathOnClient = contentData.Title + '.pdf',
                VersionData = baseFile,
                Origin = 'H',
                IsMajorVersion = true
            );

            lstContentVersion.add(itemContent);
        }

        insert lstContentVersion;

        // Create outputs
        for (ContentVersion cv : lstContentVersion) {
            Output output = new Output();
            output.idFile = cv.Id;
            retorno.add(output);
        }

        return retorno;
    }

    public class Input {
        @InvocableVariable(required = true)
        public String contentVersionId;
    }

    public class Output {
        @InvocableVariable(required = true)
        public Id idFile;
    }
}