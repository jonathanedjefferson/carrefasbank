public class PontoContatoEmailTelefoneDAO {
    public static List<ContaFinanceira__c> getContaFinanceiraBySetId(Set<Id> setId){
        List<ContaFinanceira__c> listContaFinanceira = [
            SELECT
                Id,
                Email__c,
                Telefone__c
            FROM 
                ContaFinanceira__c
            WHERE
                Id IN :setId
        ];

        return listContaFinanceira;
    }
}