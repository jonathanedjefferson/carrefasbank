public class AlcadasEncargosTarifasAnuidadeDAO {
  
    public static List<AlcadasEncargosTarifasAnuidade__mdt> getAlcadaByAreaPrincipal(String areaPrincipal){
        List<AlcadasEncargosTarifasAnuidade__mdt> listAlcada = [SELECT 
                                                                    Id 
                                                                FROM AlcadasEncargosTarifasAnuidade__mdt 
                                                                WHERE AreaPrincipal__c = :areaPrincipal];

        return listAlcada;
    }
}