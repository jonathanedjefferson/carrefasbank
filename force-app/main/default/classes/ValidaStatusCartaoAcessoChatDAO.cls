public class ValidaStatusCartaoAcessoChatDAO {
    public static List<StatusCartaoPermitidoChat__mdt> getStatus(List<String> labelMetadado) {
        return [
            SELECT Id, ListaStatus__c, ComAcesso__c, SemAcessoAppChat__c, SemAcessoAppComAcessoChat__c
            FROM StatusCartaoPermitidoChat__mdt
            WHERE Label IN :labelMetadado
        ];
    }
}