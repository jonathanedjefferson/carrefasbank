public class IdentificaClienteChatDAO {
    public static LiveChatTranscript getTranscriptById(String idRoteavel){
        return [
            SELECT Id, Token__c, ChaveContaFinanceira__c
            FROM LiveChatTranscript 
            WHERE Id = :idRoteavel
        ];
    }

    public static MessagingSession getMessagingSessionById(String idRoteavel){
        return [
            SELECT Id, Token__c, ChaveContaFinanceira__c, MessagingEndUserId, IdSessaoApp__c
            FROM MessagingSession 
            WHERE Id = :idRoteavel
        ];
    }

    public static MessagingEndUser getMessagingUser(String messagingUserId){
        return [
            SELECT Id, AccountId
            FROM MessagingEndUser 
            WHERE Id = :messagingUserId
        ];
    }

    public static List<StatusContaCancelada__mdt> getStatusContaCanceladoByStatus(String status){
        return [
            SELECT Id 
            FROM StatusContaCancelada__mdt
            WHERE StatusConta__c = :status 
        ];
    }

    public static List<ContaFinanceira__c> getContaFinanceira(String UnidadeNegocio, String NumeroConta){
        return [
            SELECT 
                Id, 
                NomeCliente__r.Id,
                Telefone__c,
                Email__c
            FROM ContaFinanceira__c
            WHERE  
                UnidadeNegocio__c = :UnidadeNegocio AND
                NumeroConta__c = :NumeroConta
        ];
    }

    public static List<Account> getAccount(String cpf){
        return [
            SELECT Id
            FROM Account
            WHERE CPF__c = :cpf
        ];
    }

    public static List<Asset> getCartao(String AccountId, String IdContaFinanceira){
        return [
            SELECT Id, NumeroCartao__c
            FROM Asset
            WHERE
                AccountId = :AccountId AND
                ContaFinanceira__c = :IdContaFinanceira
        ];
    }

    public static RecordType getPersonRecordType(){
        return [
            SELECT Id
            FROM RecordType
            WHERE
                DeveloperName LIKE '%BCSF_RT_PAC_ClientePessoalCarrefour%' AND
                SobjectType = 'Account'
        ];
    }
}