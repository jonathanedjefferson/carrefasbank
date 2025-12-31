public with sharing class BCSF_AtivarInativarCartaoController {
    @AuraEnabled
    public static List<IdentificaCockpit.Contrato> ListarCartoes(String numeroConta, String idEmpresa, String cpf, String canal){
        return BCSF_AtivarInativarCartaoBO.ListarCartoes(numeroConta, idEmpresa, cpf, canal);
    }
    
    @AuraEnabled
    public static Boolean Ativar(String numeroCartaoSerno, String idEmpresa, String cpf, String numeroConta, String sistema, String canal, String area){
        return AtivarInativarCartao.AtivarCartao(numeroCartaoSerno, idEmpresa, cpf, numeroConta, sistema, canal, area);
    }

    @AuraEnabled
    public static Boolean Inativar(String numeroCartaoSerno, String idEmpresa, String cpf, String numeroConta, String sistema, String canal, String area){
        return AtivarInativarCartao.InativarCartao(numeroCartaoSerno, idEmpresa, cpf, numeroConta, sistema, canal, area);
    }

    @AuraEnabled
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String tipo){
        return BCSF_AtivarInativarCartaoBO.createCase(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, tipo);
    }
}