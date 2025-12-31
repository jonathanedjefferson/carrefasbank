public without sharing class BCSF_SegundaViaCartaoController {

    @AuraEnabled
    public static ReemissaoCartao.OutputListCartoesParaReemissao getListCartoes(String canal, String area, String cpf, String numeroConta, String idEmpresa){
        return ReemissaoCartao.ListCartoesParaReemissao(canal, area, cpf, numeroConta, idEmpresa);
    }
    @AuraEnabled
    public static ReemissaoCartao.ReemitirCartaoOutput ReemitirCartao(String idEmpresa, String sistema,  String canal,  String area, String cpf,  String numeroConta, String numeroCartaoSerno, String novoStatus){
        return ReemissaoCartao.ReemitirCartao(idEmpresa, sistema, canal, area, cpf, numeroConta, numeroCartaoSerno, novoStatus);
    }
    @AuraEnabled
    public static ReemissaoCartao.ReemitirCartaoOutput ReemitirCartaoComAlteracaoNomeReduzido(String idEmpresa, String sistema,  String canal,  String area, String cpf,  String numeroConta, String numeroCartaoSerno, String novoStatus, String nomeReduzido){
        return ReemissaoCartao.ReemitirCartaoComAlteracaoNomeReduzido(idEmpresa, sistema, canal, area, cpf, numeroConta, numeroCartaoSerno, novoStatus, nomeReduzido);
    }
    @AuraEnabled
    public static Case createCaseNomeReduzido(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, Boolean isBraile, Boolean isNomeReduzido){
        return BCSF_SegundaViaCartaoBO.createCase(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, isBraile, isNomeReduzido);
    }
    @AuraEnabled
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, Boolean isBraile){
        return BCSF_SegundaViaCartaoBO.createCase(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, isBraile);
    }
    @AuraEnabled
    public static void updateAtivo(String contaFinanceiraId, String cartaoOfuscado, String newStatus){
        BCSF_SegundaViaCartaoBO.updateAtivo(contaFinanceiraId, cartaoOfuscado, newStatus);
    }
    @AuraEnabled
    public static ReemissaoCartao.OutputStatusReemissaoRastreio getListRastreioCartao(String canal, String area, String cpf, String numeroConta, String idEmpresa){
        return ReemissaoCartao.ListRastreioCartaoReemitido(canal, area, cpf, idEmpresa, numeroConta);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getAssetTitular(String idContaFinanceira) {
        return AssetBO.getAssetTitular(idContaFinanceira);
    }
    
    @AuraEnabled
    public static void createCaseCodigoRastreio(String origem, String idOperador, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal){
        BCSF_SegundaViaCartaoBO.createCaseCodigoRastreio(origem, idOperador, contaFinanceiraId, accountId, unidadeNegocio, canal);
    }
}