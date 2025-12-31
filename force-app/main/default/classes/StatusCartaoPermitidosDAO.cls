public class StatusCartaoPermitidosDAO {
    public static List<String> getStatusCartaoPermitido(String apiName){

        List<String> statusValidos = new List<String>();
        
        List<StatusCartaoPermitidos__mdt> statusValidos_MDT = [
                SELECT StatusPermitidos__c 
                FROM StatusCartaoPermitidos__mdt 
                WHERE DeveloperName = :apiName 
            ];
            
        
        if(statusValidos_MDT.size() > 0){
            statusValidos = statusValidos_MDT[0].StatusPermitidos__c.split(';');
        }
            
        return statusValidos;
    }
}