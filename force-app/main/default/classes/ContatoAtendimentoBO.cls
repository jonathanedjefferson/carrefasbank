public class ContatoAtendimentoBO {
    public static void UpdateContaFinanceira(Set<String> setNumConta, Map<String, String> mapIdEmail, Map<String, String> mapIdTelefone, Map<String, ContatoAtendimento__c> mapIdContatoAtend){
        List<ContaFinanceira__c> listContaFinanceira = ContatoAtendimentoDAO.getContaFinanceiraBySetNumConta(setNumConta);
        Map<id, ContaFinanceira__c> mapUpdateCt = new Map<id, ContaFinanceira__c>();
        Map<id, ContatoAtendimento__c> MapUpdateContAtend = new Map<id, ContatoAtendimento__c>();
        String telefoneRegexCom55 = '([5]{2})([0-9]{2})([9]{1})([0-9]{8})';
        String telefoneRegexSem55 = '([0-9]{2})([9]{1})([0-9]{8})';
        
        for (ContaFinanceira__c item: listContaFinanceira) {
            ContatoAtendimento__c ContAtend = mapIdContatoAtend.get(item.IdConta__c);
            ContAtend.ContaFinanceira__c = item.Id;
            ContAtend.NewValue__c = false;
            MapUpdateContAtend.put(ContAtend.Id, ContAtend);
            
            if (mapIdTelefone.containsKey(item.IdConta__c)) {
                String telefone = mapIdTelefone.get(item.IdConta__c);
                Boolean resultCom55 = false;
                Boolean resultSem55 = false;
                
                if (telefone != null) {
                    // VALIDAÇÃO COM 55 
                    Pattern telefonePatternCom55 = Pattern.compile(telefoneRegexCom55);
                    Matcher telefoneMatcherCom55 = telefonePatternCom55.matcher(telefone);
                    resultCom55 = telefoneMatcherCom55.matches();
                    
                    // VALIDAÇÃO SEM 55 
                    Pattern telefonePatternSem55 = Pattern.compile(telefoneRegexSem55);
                    Matcher telefoneMatcherSem55 = telefonePatternSem55.matcher(telefone);
                    resultSem55 = telefoneMatcherSem55.matches();
                }

                if (resultCom55) {
                    item.Telefone__c = mapIdTelefone.get(item.IdConta__c);
                }else if(resultSem55){            
                    item.Telefone__c = '55'+mapIdTelefone.get(item.IdConta__c);
                }
            }
            
            if (mapIdEmail.containsKey(item.IdConta__c)) {
                item.Email__c = mapIdEmail.get(item.IdConta__c);
            }

            try {
                item.Numero__c = (ContAtend.Numero__c == null || ContAtend.Numero__c == 'SN') ? null : String.valueOf(ContAtend.Numero__c);
            } catch (Exception e) {
                item.Numero__c = null;
                System.debug('ERROR: ' + e.getMessage());
            }
            
            item.Bairro__c = ContAtend.Bairro__c;
            item.CEP__c = ContAtend.CEP__c;
            item.Cidade__c = ContAtend.Cidade__c;
            item.Complemento__c = ContAtend.Complemento__c;
            item.Rua__c = ContAtend.Endereco__c;
            item.Estado__c = ContAtend.Estado__c;
            item.CelularSeguro__c = ContAtend.CelularSeguro__c;

            mapUpdateCt.put(item.Id ,item);
        }

        if (mapUpdateCt.size() > 0) {
            update mapUpdateCt.values();
        }
        if (MapUpdateContAtend.size() > 0) {
            update MapUpdateContAtend.values();
        }
    }

    public static void FallBackTotal(){
        List<ContaFinanceira__c> listContaFinanceira = ContatoAtendimentoDAO.getContaFinanceiraForFallBack();

        for (ContaFinanceira__c item: listContaFinanceira) {
            item.Telefone__c = null;
            item.Email__c = null;
        }

        update listContaFinanceira;
    }       
}