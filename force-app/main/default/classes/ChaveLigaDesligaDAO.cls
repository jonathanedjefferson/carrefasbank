public with sharing class ChaveLigaDesligaDAO {
    private static final ChaveLigaDesligaDAO instance = new ChaveLigaDesligaDAO();

    public static ChaveLigaDesligaDAO getInstance() {
      return instance;
    }

    public List<ChaveLigaDesliga__mdt> getByDeveloperNameLike(String developerName ) {
        return [
            SELECT
                Label,  
                Ligado__c,
                DeveloperName
            FROM 
                ChaveLigaDesliga__mdt
            WHERE
                DeveloperName LIKE :developerName
            ORDER BY Label DESC
        ];
    }
}