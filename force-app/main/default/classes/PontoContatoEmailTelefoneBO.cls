public class PontoContatoEmailTelefoneBO {
    public static void UpdateEmailContaFinanceira(Set<Id> setContaFinanceira, Map<Id, String> mapIdEmail){
        List<ContaFinanceira__c> listContaFinanceira = PontoContatoEmailTelefoneDAO.getContaFinanceiraBySetId(setContaFinanceira);
        List<ContaFinanceira__c> listUpdate = new List<ContaFinanceira__c>();

        for (ContaFinanceira__c item: listContaFinanceira) {
            if (mapIdEmail.containsKey(item.Id)) {
                item.Email__c = mapIdEmail.get(item.Id);
                listUpdate.add(item);
            }
        }

        update listUpdate;
    }

    public static void UpdateTelefoneContaFinanceira(Set<Id> setContaFinanceira, Map<Id, String> mapIdTelefone){
        List<ContaFinanceira__c> listContaFinanceira = PontoContatoEmailTelefoneDAO.getContaFinanceiraBySetId(setContaFinanceira);
        List<ContaFinanceira__c> listUpdate = new List<ContaFinanceira__c>();
        // REGEX PARA VALIDAÇÃO DO TELEFONE CELULAR
        String telefoneRegexCom55 = '([5]{2})([0-9]{2})([9]{1})([0-9]{8})';
        String telefoneRegexSem55 = '([0-9]{2})([9]{1})([0-9]{8})';

        for (ContaFinanceira__c item: listContaFinanceira) {
            if (mapIdTelefone.containsKey(item.Id)) {
                String telefone = mapIdTelefone.get(item.Id);

                // VALIDAÇÃO COM 55 
                Pattern telefonePatternCom55 = Pattern.compile(telefoneRegexCom55);
                Matcher telefoneMatcherCom55 = telefonePatternCom55.matcher(telefone);
                Boolean resultCom55 = telefoneMatcherCom55.matches();
                
                // VALIDAÇÃO SEM 55 
                Pattern telefonePatternSem55 = Pattern.compile(telefoneRegexSem55);
                Matcher telefoneMatcherSem55 = telefonePatternSem55.matcher(telefone);
                Boolean resultSem55 = telefoneMatcherSem55.matches();

                if (resultCom55) {
                    System.debug('----------------------- COM 55 -----------------------');
                    item.Telefone__c = mapIdTelefone.get(item.Id);
                    listUpdate.add(item);
                }else if(resultSem55){
                    System.debug('----------------------- SEM 55 -----------------------');
                    item.Telefone__c = '55'+mapIdTelefone.get(item.Id);
                    listUpdate.add(item);
                }

                System.debug('Telefone: '+ item.Telefone__c);
            }
        }

        update listUpdate;
    }

    public static void FallBackTotal(){
        List<ContaFinanceira__c> listContaFinanceira = [SELECT Id, Telefone__c, Email__c FROM ContaFinanceira__c WHERE Telefone__c != null OR Email__c != null];

        for (ContaFinanceira__c item: listContaFinanceira) {
            item.Telefone__c = null;
            item.Email__c = null;
        }

        update listContaFinanceira;
    }
}