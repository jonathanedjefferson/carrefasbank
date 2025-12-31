public with sharing class GestaoLimiteController {
    
    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira obterContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getAssetTitular(String idContaFinanceira) {
        return AssetBO.getAssetTitular(idContaFinanceira);
    }

    @AuraEnabled
    public static Case criarCaso(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String evento){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Limites e Saldos', 
            evento, 'Execução', 'Medium', canal, origem, contaFinanceiraId, accountId, unidadeNegocio);
    }

    @AuraEnabled
    public static GestaoLimite.ResponseConsultarLimite consultarLimite(String canal, String cpf, String unidadeNegocio, String numeroConta, String pagina, String itensPorPagina) {
        
        GestaoLimite.RequestConsultarLimite request = new GestaoLimite.RequestConsultarLimite();
        request.canal = canal;
        request.cpf = cpf;
        request.numeroConta = numeroConta;
        request.itensPorPagina = itensPorPagina;
        request.pagina = pagina;
        request.unidadeNegocio = unidadeNegocio;
        return GestaoLimite.consultarLimite(request);
    }

    @AuraEnabled
    public static GestaoLimite.ResponseAlterarLimite aumentarLimite(String canal, String cpf, String unidadeNegocio, String numeroConta, String valorRendaComprovada, String valorLimiteSolicitado) {
        GestaoLimite.RequestAlterarLimite request = new GestaoLimite.RequestAlterarLimite();
        request.canal = canal;
        request.cpf = cpf;
        request.numeroConta = numeroConta;
        request.valorRendaComprovada = valorRendaComprovada;
        request.valorLimiteSolicitado = valorLimiteSolicitado;
        request.unidadeNegocio = unidadeNegocio;
        return GestaoLimite.aumentarLimite(request);
    }


    @AuraEnabled
    public static GestaoLimite.ResponseAlterarLimite reduzirLimite(String canal, String cpf, String unidadeNegocio, String numeroConta, String valorRendaComprovada, String valorLimiteSolicitado) {
        GestaoLimite.RequestAlterarLimite request = new GestaoLimite.RequestAlterarLimite();
        request.canal = canal;
        request.cpf = cpf;
        request.numeroConta = numeroConta;
        request.valorRendaComprovada = valorRendaComprovada;
        request.valorLimiteSolicitado = valorLimiteSolicitado;
        request.unidadeNegocio = unidadeNegocio;
        return GestaoLimite.reduzirLimite(request);
    }

}