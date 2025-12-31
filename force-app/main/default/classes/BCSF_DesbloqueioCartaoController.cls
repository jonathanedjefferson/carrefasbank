public with sharing class BCSF_DesbloqueioCartaoController {

    @AuraEnabled
    public static List<DesbloqueioCartao.OutputListCartoesParaDesbloqueio> getListCartoes(String canal, String area, String cpf, String numeroConta){
        return DesbloqueioCartao.ListCartoesParaDesbloqueio(canal, area, cpf, numeroConta);
    }

    @AuraEnabled
    public static Boolean desbloquearCartao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno){
        return DesbloqueioCartao.DesbloquearCartao(idEmpresa, sistema, canal, area, cpf, numeroConta, numeroCartaoSerno);
    }

    @AuraEnabled
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal){
       return BCSF_DesbloqueioCartaoBO.createCase(origem, contaFinanceiraId, accountId, unidadeNegocio, canal);
    }

    @AuraEnabled
    public static void updateAtivo(String contaFinanceiraId, String cartaoOfuscado, String newStatus){
        BCSF_DesbloqueioCartaoBO.updateAtivo(contaFinanceiraId, cartaoOfuscado, newStatus);
    }
}