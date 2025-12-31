public class TipoEnvioFaturaDAO {
    
    private static final TipoEnvioFaturaDAO instance = new TipoEnvioFaturaDAO();

    public static TipoEnvioFaturaDAO getInstance() {
      return instance;
    }
    
    public Tipo_Envio_Fatura__mdt getDescricaoByCodigoTipoEnvioFatura(String codigoTipoEnvio) {
        List<Tipo_Envio_Fatura__mdt> listTipos =  [
            SELECT  
                Label
            FROM 
                Tipo_Envio_Fatura__mdt
            WHERE
                Codigo_Tipo__c =: codigoTipoEnvio
        ];
        
        return listTipos.isEmpty() ? null : listTipos [0];
    }
}