public without sharing class BCSF_ModoEnvioFaturaController {
    @AuraEnabled
    public static  BCSF_ModoEnvioFaturaBO.ContaFinanceiraTO getContaFinanceira(String contaFinanceiraId){
        return BCSF_ModoEnvioFaturaBO.tratarContaFinanceira(contaFinanceiraId);
    }
    @AuraEnabled
    public static case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String origem, String canal,String evento, String tipoEnvio){
        return BCSF_ModoEnvioFaturaBO.criarCaso(contaFinanceiraId, accountId, unidadeNegocio, origem, canal,evento, tipoEnvio);
    }
    @AuraEnabled
    public static AlterarModoEnvioFatura.OutputTiposEnvioFatura GetTiposEnvioFatura(String canal, String cpf, String idEmpresa){
        return AlterarModoEnvioFatura.GetTiposEnvioFatura(canal, cpf, idEmpresa);
    }
    @AuraEnabled
    public static AlterarModoEnvioFatura.OutputUpdateEmailEnvioFatura UpdateEmailEnvioFatura(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String emailToUpdate){
        return AlterarModoEnvioFatura.UpdateEmailEnvioFatura(idEmpresa, sistema, canal, area, cpf, numeroConta, emailToUpdate);
    }
    @AuraEnabled
    public static AlterarModoEnvioFatura.OutputUpdateModoEnvioFatura UpdateTipoEnvioFatura(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String tipoEnvioFatura, Boolean alteracaoCadastral){
        return AlterarModoEnvioFatura.UpdateTipoEnvioFatura(idEmpresa, sistema, canal, area, cpf, numeroConta, tipoEnvioFatura, alteracaoCadastral);
    }
    @AuraEnabled
    public static void atualizaEmail(String contaFinanceiraId, String email){
        BCSF_ModoEnvioFaturaBO.atualizaEmail(contaFinanceiraId, email);
    }
}