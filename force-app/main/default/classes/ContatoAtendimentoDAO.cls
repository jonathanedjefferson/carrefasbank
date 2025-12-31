public class ContatoAtendimentoDAO {
    public static List<ContaFinanceira__c> getContaFinanceiraBySetNumConta(Set<String> setId){
        return [
            SELECT
                Id,
                Email__c,
                Telefone__c,
                IdConta__c,
                NomeCliente__c,
                Bairro__c,
                CEP__c,
                Cidade__c,
                Complemento__c,
                Rua__c,
                Estado__c,
                Numero__c,
                CelularSeguro__c
            FROM 
                ContaFinanceira__c
            WHERE
            IdConta__c IN :setId
        ];
    }

    public static List<ContaFinanceira__c> getContaFinanceiraForFallBack(){
        return [
            SELECT 
                Id, 
                Telefone__c, 
                Email__c 
            FROM 
                ContaFinanceira__c 
            WHERE 
                Telefone__c != null OR 
                Email__c != null
        ];
    }
}