public with sharing class BCSF_AvaliacaoEmergencialController {
    
    @AuraEnabled
    public static string Consultar(String cpf, String numeroConta, String area, String canal){
        return BCSF_AvaliacaoEmergencial.consultarDadosAvaliacao(cpf, numeroConta, area, canal);
    }

    @AuraEnabled
    public static string Gravar(String cpf, String numeroConta, String area, String canal, String idEmpresa, String Operacao){
        return BCSF_AvaliacaoEmergencial.gravarDadosAvaliacaoAdesao(cpf, numeroConta, area, canal, idEmpresa, Operacao);
    }

    /*
    @AuraEnabled
    public static string ConsultarTaxas(String cpf, String numeroConta, String area, String canal, String produto, String dataConta){
        return BCSF_AvaliacaoEmergencial.consultarTaxasAvaliacao(cpf, numeroConta, area, canal, produto, dataConta);
    }
    */
    @AuraEnabled
    public static string ConsultarTermo(String cpf, String numeroConta, String area, String canal, String tipo){
        return BCSF_AvaliacaoEmergencial.consultarTermoAvaliacao(cpf, numeroConta, area, canal, tipo);
    }

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getAssetTitular(String contaFinanceiraId){
        return AssetBO.getAssetTitular(contaFinanceiraId);
    }
}