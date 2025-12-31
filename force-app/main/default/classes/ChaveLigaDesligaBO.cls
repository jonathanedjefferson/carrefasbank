public class ChaveLigaDesligaBO {
    
    public static List<ChaveTO> getChaveLigaDesligaLike(String developerName){
        List<ChaveTO> toReturn = new List<ChaveTO>();
        List<ChaveLigaDesliga__mdt> chaves = ChaveLigaDesligaDAO.getInstance().getByDeveloperNameLike(developerName);
        
        ChaveTO chaveTO = null;
        for(ChaveLigaDesliga__mdt metadado : chaves){
            chaveTO = new ChaveTO();
            chaveTO.Label = metadado.Label == null ? '--': metadado.Label;
            chaveTO.IsLigado = metadado.Ligado__c == null ?  false: metadado.Ligado__c;
            chaveTO.DeveloperName = metadado.DeveloperName == null ?  '--': metadado.DeveloperName;
            toReturn.add(chaveTO);
        }

         return toReturn;
    }
    
    public class ChaveTO{
        @AuraEnabled
        public String Label{get; set;}
        @AuraEnabled
        public String DeveloperName{get; set;}
        @AuraEnabled
        public Boolean IsLigado{get; set;}
    }

}