public with sharing class GetFileFaturaHelper {
    @invocableMethod(label='Get Arquivo da Fatura')
    public static List<OutputFatura> GetFileFatura(List<Input> inputs) {
        List<OutputFatura> listRetorno = new List<OutputFatura>();

        for (Input item: inputs) {
            BCSF_CLS_CalloutFaturasV1.outputDownloadFatura retorno = BCSF_CLS_CalloutFaturasController.downloadFaturaEncripted(item.numeroConta, item.idEmpresa, String.valueOf(item.idFatura), item.cpf, item.canal);
            OutputFatura obj = new OutputFatura();

            if(retorno.statusReponse == 'OK'){
                obj.idFile = InsertFile(retorno);
                obj.StatusApi = retorno.statusReponse;
            }else{
                obj.StatusApi = retorno.statusReponse;
            }

            listRetorno.add(obj);
            break;
        }

        return listRetorno;
    }

    public static Id InsertFile(BCSF_CLS_CalloutFaturasV1.outputDownloadFatura file){
        
        Blob baseFile = EncodingUtil.base64Decode(file.conteudo);
        String identificador = GuidUtil.NewGuid();

        ContentVersion itemContent = new ContentVersion(
					Title = 'Fatura.pdf',
					PathOnClient = 'Fatura.pdf',
					VersionData = baseFile, 
					origin = 'H',
                    IsMajorVersion = true
				);

        insert itemContent;

        System.debug(itemContent);

        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Fatura.pdf';
        cd.ContentVersionId = itemContent.Id;
        cd.PreferencesAllowViewInBrowser=true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload=true;
        cd.PreferencesExpires=true;
        datetime expiryTime = datetime.now().addMinutes(120);
        cd.ExpiryDate = expiryTime;
        insert cd;
               
        return itemContent.Id;
    }

    public class Input {
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String idEmpresa;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String mesRefFatura;
        @InvocableVariable(required = true)
        public String canal;
        @InvocableVariable(required = true)
        public Integer idFatura;
    }

    public class OutputFatura{
        @InvocableVariable
        public Id idFile;
        @InvocableVariable
        public String StatusApi;
    }
}