public with sharing class bcsf_cmp_SegurosController {
    
    @AuraEnabled()
    public static IntegracaoSeguros.OutputElegibilidadeProdutos getSeguros(String idEmpresa, String canal, String cpf, String numeroConta, List<String> listIdDeProdutos) {
        return IntegracaoSeguros.ElegibilidadeProdutos(idEmpresa, canal, cpf, numeroConta, listIdDeProdutos);
    }
    
    @AuraEnabled()
    public static IntegracaoSeguros.OutputAdesaoSeguro adesaoSeguros(String idEmpresa, String canal, String cpf, String body) {
        return IntegracaoSeguros.adesaoProdutos(idEmpresa, canal, cpf, body);
    }

    @AuraEnabled()
    public static IntegracaoSeguros.OutputAdesaoSeguro adesaoSegurosWhatsApp(String idEmpresa, String canal, String cpf, String body) {
        return IntegracaoSeguros.adesaoProdutosWhatsApp(idEmpresa, canal, cpf, body);
    }
    
    @AuraEnabled()
    public static Knowledge__kav searchArticles(String title) {
        return bcsf_cmp_SegurosBO.getArtigos(title);
    }

    @AuraEnabled()
    public static Account getAccount(String accountId) {
        return bcsf_cmp_SegurosBO.getAccount(accountId);
    }

    @AuraEnabled()
    public static Case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal) {
        return bcsf_cmp_SegurosBO.criarCaso(contaFinanceiraId, accountId, unidadeNegocio, Origem, Canal);
    }

    @AuraEnabled()
    public static Case criarCasoCancelamento(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal, String observacao, String outroMotivo, String seguro) {
        bcsf_cmp_SegurosBO.segurosCaso seguroObj = (bcsf_cmp_SegurosBO.segurosCaso) System.JSON.deserialize(seguro, bcsf_cmp_SegurosBO.segurosCaso.class);
        return bcsf_cmp_SegurosBO.criarCasoCancelamento(contaFinanceiraId, accountId, unidadeNegocio, Origem, Canal, observacao, outroMotivo, seguroObj);
    }

    @AuraEnabled()
    public static Case criarCasosContestar(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal, String seguros) {
        List<bcsf_cmp_SegurosBO.segurosCaso> segurosObj = (List<bcsf_cmp_SegurosBO.segurosCaso>) System.JSON.deserialize(seguros, List<bcsf_cmp_SegurosBO.segurosCaso>.class);
        return bcsf_cmp_SegurosBO.criarCasosContestar(contaFinanceiraId, accountId, unidadeNegocio, Origem, Canal, segurosObj);
    }

    @AuraEnabled()
    public static IntegracaoSeguros.OutputConsultarSeguros getSegurosContratados(String idEmpresa, String cpf, String canal) {
        return IntegracaoSeguros.consultarSeguros(idEmpresa, cpf, canal);
    }

    @AuraEnabled()
    public static IntegracaoSeguros.OutputMotivosCancelamento getMotivosCancelamento(String idEmpresa, String cpf, String canal) {
        return IntegracaoSeguros.motivosCancelamento(idEmpresa, cpf, canal);
    }

    @AuraEnabled()
    public static IntegracaoSeguros.OutputHistoricoSeguro historicoCobranca(String nameAdesao, String idAdesao, String idEmpresa, String cpf, String canal) {
        return IntegracaoSeguros.historicoCobranca(nameAdesao, idAdesao, idEmpresa, cpf, canal);
    }

    @AuraEnabled()
    public static IntegracaoSeguros.OutputCancelarSeguros cancelarSeguro(String contrato) {
        IntegracaoSeguros.InputCancelamento contratoObj = (IntegracaoSeguros.InputCancelamento) System.JSON.deserialize(contrato, IntegracaoSeguros.InputCancelamento.class);
        return IntegracaoSeguros.cancelamentoSeguro(contratoObj);
    }
}