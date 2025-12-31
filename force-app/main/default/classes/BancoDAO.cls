public class BancoDAO {
    
    private static final BancoDAO instance = new BancoDAO();

    public static BancoDAO getInstance() {
      return instance;
    }

    public List<Banco__mdt> getAllDebitoAutomatico() {
        return [
            SELECT  
                Label,
                Codigo_Banco__c
            FROM 
                Banco__mdt
            WHERE
                Debito_Automatico__c = true
        ];
    }
    
    public Banco__mdt getBancoByCodigoBanco(String codigoBanco) {
        List<Banco__mdt> listBancos =  [
            SELECT  
                Label,
                Codigo_Banco__c
            FROM 
                Banco__mdt
            WHERE
                Codigo_Banco__c =: codigoBanco
        ];
        
        return listBancos .isEmpty() ? null : listBancos [0];
    }
}