public with sharing class AssetBO {

    public static List<AssetTO> getAllAssets(String contaFinanceiraId, Integer maxResults){
        List<Asset> listAssets = AssetDAO.getInstance().getAllAssets(contaFinanceiraId, maxResults);
        List<AssetTO> toReturn = new List<AssetTO>();

        AssetTO assetTO;
        for(Asset asset : listAssets){
            assetTO = new AssetTO();

            assetTO.AssetId = asset.Id == null?'--': asset.Id;
            assetTO.NomeAtivo = asset.Name == null?'--': asset.Name;
            assetTO.NumeroSernoId = asset.CartaoSernoId__c == null?'--': asset.CartaoSernoId__c;
            assetTO.NumeroCartao = asset.NumeroCartao__c == null?'--': asset.NumeroCartao__c;
            assetTO.NomeReduzido = asset.NomeReduzido__c == null?'--': asset.NomeReduzido__c;
            assetTO.TipoCartao = asset.TipoCartao__c == null?'--': asset.TipoCartao__c;
            assetTO.Status = asset.Status == null?'--': asset.Status;
            assetTO.Contactless = asset.Contactless__c == null? false: asset.Contactless__c;
            assetTO.IsCartaoPrimario = asset.CartaoPrimario__c == null? false: asset.CartaoPrimario__c;
            assetTO.URL = '/lightning/r/' + asset.Id + '/view';
            assetTO.TitularidadeDescritivo = asset.TipoTitularidade__c == null ? '--': asset.TipoTitularidade__c;
            assetTO.Situacao = asset.Situacao__c == null ? '--' : asset.Situacao__c;

            if('DEPENDENTE'.equals(assetTO.TitularidadeDescritivo)){
                assetTO.TitularidadeDescritivo = 'Adicional';
            } else if ('TITULAR'.equals(assetTO.TitularidadeDescritivo)) {
                assetTO.TitularidadeDescritivo = 'Titular';
            }
            
            toReturn.add(assetTO);
        }

        return toReturn;
    }

    public static List<AssetTO> getAllAssetsByStatus(String contaFinanceiraId, String status){
        List<Asset> listAssets = AssetDAO.getInstance().getAllAssetsByStatus(contaFinanceiraId, status);
        List<AssetTO> toReturn = new List<AssetTO>();

        AssetTO assetTO;
        for(Asset asset : listAssets){
            assetTO = new AssetTO();

            assetTO.AssetId = asset.Id == null?'--': asset.Id;
            assetTO.NumeroSernoId = asset.CartaoSernoId__c == null?'--': asset.CartaoSernoId__c;
            assetTO.NumeroCartao = asset.NumeroCartao__c == null?'--': asset.NumeroCartao__c;
            assetTO.NomeReduzido = asset.NomeReduzido__c == null?'--': asset.NomeReduzido__c;
            assetTO.TipoCartao = asset.TipoCartao__c == null?'--': asset.TipoCartao__c;
            assetTO.Status = asset.Status == null?'--': asset.Status;
            assetTO.Contactless = asset.Contactless__c == null? false: asset.Contactless__c;
            assetTO.TitularidadeDescritivo = asset.TipoTitularidade__c == null? '--': asset.TipoTitularidade__c;

            if('DEPENDENTE'.equals(assetTO.TitularidadeDescritivo)){
                assetTO.TitularidadeDescritivo = 'Adicional';
            } else if ('TITULAR'.equals(assetTO.TitularidadeDescritivo)) {
                assetTO.TitularidadeDescritivo = 'Titular';
            }

            toReturn.add(assetTO);
        }

        return toReturn;
    }

    public static AssetTO getAssetTitular(String contaFinanceiraId){
        Asset asset = AssetDAO.getInstance().getAssetTitular(contaFinanceiraId);
        AssetTO toReturn = null;

        if(asset != null){
            toReturn = new AssetTO();
            toReturn.AssetId = asset.Id == null?'--': asset.Id;
            toReturn.NumeroSernoId = asset.CartaoSernoId__c == null?'--': asset.CartaoSernoId__c;
            toReturn.NumeroCartao = asset.NumeroCartao__c == null?'--': asset.NumeroCartao__c;
            toReturn.NomeReduzido = asset.NomeReduzido__c == null?'--': asset.NomeReduzido__c;
            toReturn.Status = asset.Status == null?'--': asset.Status;
            toReturn.TipoProduto = asset.ProductDescription == null?'--': asset.ProductDescription;

            if(asset.DataValidadeCartao__c == null){
                toReturn.DataValidade = '--';
            } else {
                String dataExpiracao;
                if(asset.DataValidadeCartao__c.month() < 10) {
                    dataExpiracao = '0' + asset.DataValidadeCartao__c.month() + '/';
                } else {
                    dataExpiracao = asset.DataValidadeCartao__c.month() + '/';
                }
                toReturn.DataValidade = dataExpiracao + asset.DataValidadeCartao__c.year();
            }
        }

        return toReturn;
    }

    public static List<AssetTO> getAssets(String contaFinanceiraId, String tipoCartao, String tipoTitularidade){
        List<Asset>  assets = AssetDAO.getInstance().getAssets(contaFinanceiraId, tipoCartao, tipoTitularidade);
        List<AssetTO> toReturn = new List<AssetTO>();

        for(Asset asset : assets){
            AssetTO assetTO = new AssetTO();
            assetTO.AssetId = asset.Id == null?'--': asset.Id;
            assetTO.NumeroSernoId = asset.CartaoSernoId__c == null?'--': asset.CartaoSernoId__c;
            assetTO.NumeroCartao = asset.NumeroCartao__c == null?'--': asset.NumeroCartao__c;
            assetTO.NomeReduzido = asset.NomeReduzido__c == null?'--': asset.NomeReduzido__c;
            assetTO.Status = asset.Status == null?'--': asset.Status;
            assetTO.TipoProduto = asset.ProductDescription == null?'--': asset.ProductDescription;
            assetTO.IsCartaoPrimario = asset.CartaoPrimario__c == null? false: asset.CartaoPrimario__c;
            toReturn.add(assetTO);
        }

        return toReturn;
    }

    public static Boolean updateAssetPrimario(String contaFinanceiraId, String cartaoSernoId){
        return AssetDAO.getInstance().updateAssetPrimario(contaFinanceiraId, cartaoSernoId);
    }
    

    public class AssetTO{
        @AuraEnabled
        public String AssetId{get; set;}
        @AuraEnabled
        public String NomeAtivo{get; set;}
        @AuraEnabled
        public String NumeroSernoId{get; set;}
        @AuraEnabled
        public String NumeroCartao{get; set;}
        @AuraEnabled
        public String NomeReduzido{get; set;}
        @AuraEnabled
        public String TitularidadeDescritivo{get; set;}
        @AuraEnabled
        public String TipoCartao{get; set;}
        @AuraEnabled
        public Boolean Contactless{get; set;}
        @AuraEnabled
        public String Status{get; set;}
        @AuraEnabled
        public Boolean IsCartaoPrimario{get; set;}
        @AuraEnabled
        public String Url{get; set;}
        @AuraEnabled
        public String Situacao{get; set;}
        @AuraEnabled
        public String DataValidade{get; set;}
        @AuraEnabled
        public String DataEmissao{get; set;}
        @AuraEnabled
        public String TipoProduto{get; set;}
    }
}