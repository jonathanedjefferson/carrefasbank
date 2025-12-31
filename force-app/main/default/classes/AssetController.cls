public class AssetController {

    @AuraEnabled
    public static List<AssetBO.AssetTO> getAllAtivos(String recordId){
        return AssetBO.getAllAssets(recordId, 11);
    }

    @AuraEnabled
    public static List<ChaveLigaDesligaBO.ChaveTO> getAllButtonsAssets(){
        return ChaveLigaDesligaBO.getChaveLigaDesligaLike('buttonAssets_%');
    }
     
}