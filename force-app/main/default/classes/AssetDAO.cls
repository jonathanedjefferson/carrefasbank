public class AssetDAO {

    private static final AssetDAO instance = new AssetDAO();

    public static AssetDAO getInstance() {
      return instance;
    }

    public List<Asset> getAllAssets(String contaFinanceiraId, Integer maxResults) {
        List<Asset> lst = [
            SELECT 
                Id, 
                Name,
                NumeroCartao__c,
                TipoTitularidade__c,
                NomeReduzido__c,
                CartaoSernoId__c,
                TipoCartao__c,
                Contactless__c,
                Status,
                CartaoPrimario__c,
                toLabel(Situacao__c)
            FROM 
                Asset
            WHERE 
                ContaFinanceira__r.id = :contaFinanceiraId
            LIMIT :maxResults
        ];
        
        return lst;
    }

    public List<Asset> getAllAssetsByStatus(String contaFinanceiraId, String status) {
        List<Asset> lst = [
            SELECT 
                Id, 
                NumeroCartao__c,
                TipoTitularidade__c,
                NomeReduzido__c,
                CartaoSernoId__c,
                TipoCartao__c,
                Contactless__c,
                Status
            FROM 
                Asset
            WHERE 
                ContaFinanceira__r.id = :contaFinanceiraId
                AND Status = :status
        ];
        
        return lst;
    }

    public Asset getAssetTitular(String contaFinanceiraId) {
        Asset asset = [
            SELECT 
                Id,
                NumeroCartao__c,
                NomeReduzido__c,
                CartaoSernoId__c,
                Status,
                DataValidadeCartao__c,
                ProductDescription
            FROM 
                Asset
            WHERE 
                ContaFinanceira__r.id = :contaFinanceiraId
                AND TipoTitularidade__c = 'TITULAR'
                AND CartaoPrimario__c  = true
            ORDER BY createdDate DESC
            LIMIT 1
        ];
        
        return asset;
    }

    public List<Asset> getAssets(String contaFinanceiraId, String tipoCartao, String tipoTitularidade) {
        List<Asset> assets = [
            SELECT 
                Id,
                NumeroCartao__c,
                NomeReduzido__c,
                CartaoSernoId__c,
                Status,
                ProductDescription,
                CartaoPrimario__c
            FROM 
                Asset
            WHERE 
                ContaFinanceira__r.id = :contaFinanceiraId
                AND TipoCartao__c  = :tipoCartao
                AND TipoTitularidade__c = :tipoTitularidade
        ];
        
        return assets;
    }

    /**
     * Atualiza todos os cartões da conta financeira para Cartão Primário igual a falso, e define o cartão informado como primário.
     */
    public Boolean updateAssetPrimario(String contaFinanceiraId, String cartaoSernoId) {
        List<Asset> assets = [
            SELECT 
                Id,
                CartaoSernoId__c,
                CartaoPrimario__c
            FROM 
                Asset
            WHERE 
                ContaFinanceira__r.id = :contaFinanceiraId
        ];

        for(Asset asset : assets){
            asset.CartaoPrimario__c = cartaoSernoId.equals(asset.CartaoSernoId__c);
        }

        update assets;
        return true;
    }
}