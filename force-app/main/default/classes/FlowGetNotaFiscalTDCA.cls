public with sharing class FlowGetNotaFiscalTDCA {
    @InvocableMethod(label='TDCA: Obter Nota Fiscal Pelo ConsigmentCode')
    public static List<Output> getNFTDCA (List<Input> listInputs){
        Output retorno = new Output();
        List<Output> listRetorno = new List<Output>();

        try {
            for (Input item: listInputs) {
                GetInvoiceResponseWrapper resultAPI = TDCAManager.getInvoice(item.orderId, item.consigmentCode, item.brand);

                if (resultAPI != null) {
                    retorno.invoiceLink = resultAPI.invoiceLink != null ? resultAPI.invoiceLink : null;
                    retorno.invoiceKey = resultAPI.invoiceKey   != null ? resultAPI.invoiceKey  : null;
                    
                    if (resultAPI.encodedInvoice != null) {
                        // Converte o conteúdo do arquivo para Base64
                        Blob fileBody = EncodingUtil.base64Decode(resultAPI.encodedInvoice);
        
                        // Cria o registro de ContentVersion
                        ContentVersion cv = new ContentVersion();
                        cv.Title = 'VarejoNF.pdf';
                        cv.PathOnClient = 'VarejoNF.pdf';
                        cv.VersionData = fileBody;
                        cv.origin = 'H';
                        cv.IsMajorVersion = true;
        
                        // Insere o arquivo
                        insert cv;

                        // Retorna o ID do ContentDocument
                        ContentVersion retornoCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                        retorno.contentDocumentId = retornoCV.ContentDocumentId;
                        retorno.contentVersionId = cv.Id;

                        ContentDistribution cd = new ContentDistribution();
                        cd.Name = cv.Title;
                        cd.ContentVersionId = retornoCV.Id;
                        cd.PreferencesAllowViewInBrowser = true;
                        cd.PreferencesLinkLatestVersion = true;
                        cd.PreferencesNotifyOnVisit = false;
                        cd.PreferencesPasswordRequired = false;
                        cd.PreferencesAllowOriginalDownload = true;
                        cd.PreferencesExpires = true;
                        datetime expiryTime = datetime.now().addMinutes(120);
                        cd.ExpiryDate = expiryTime;
                        insert cd;
                    }

                    retorno.StatusAPI = 'OK';
                }else{
                    retorno.StatusAPI = 'ERROR';
                }
                
                listRetorno.add(retorno);
                break;
            }
        } catch (Exception e) {
            System.debug('FlowGetNotaFiscalTDCA ERROR: ' + e.getMessage());

            retorno.StatusAPI = 'FALHA NA CLASSE APEX';
            listRetorno.add(retorno);
            return listRetorno;
        }

        return listRetorno;
    }

    public class Input{
        @InvocableVariable
        public String orderId;

        @InvocableVariable
        public String consigmentCode;

        @InvocableVariable
        public String brand;
    }

    public class Output{
        @InvocableVariable
        public String invoiceLink;
        
        @InvocableVariable
        public String invoiceKey;

        @InvocableVariable
        public String contentDocumentId;

        @InvocableVariable
        public String contentVersionId;

        @InvocableVariable
        public String StatusAPI;
    }
}