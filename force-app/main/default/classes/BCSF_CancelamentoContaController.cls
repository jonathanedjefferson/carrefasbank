public class BCSF_CancelamentoContaController {
    @AuraEnabled
    public static BCSF_CancelamentoContaBO.AvaliacaoAnualTO getContaFinanceira(String contaFinanceiraId){
        return BCSF_CancelamentoContaBO.tratarContaFinanceira(contaFinanceiraId);
    }
    @AuraEnabled
    public static case criarCaso(String statusCancelamento, String  requisitoCancelamento, String contaFinanceiraId, String accountId, String unidadeNegocio,  String origem, String canal, String evento, String assunto){
        return BCSF_CancelamentoContaBO.criarCaso(statusCancelamento, requisitoCancelamento, contaFinanceiraId, accountId, unidadeNegocio, Origem, Canal, evento, assunto);
    }
    @AuraEnabled
    public static CancelamentoConta.OutputStatusCancelamento getStatusCancelamentoConta(String canal, String area){
        return CancelamentoConta.ListStatusCancelamentoConta(canal, area);
    }
    
    @AuraEnabled
    public static Boolean cancelamentoConta(String numeroConta, String novoStatus, String idEmpresa, String cpf, String sistema, String canal, String area){
        return CancelamentoConta.CancelarConta(numeroConta, novoStatus, idEmpresa, cpf, sistema, canal, area);
    }
    @AuraEnabled
    public static void atualizarContaFinanceira(String contaFinanceiraId, String novoStatus){
        BCSF_CancelamentoContaBO.atualizarContaFinanceira(contaFinanceiraId, novoStatus);
    }
    
}