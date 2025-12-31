public class AlteracaoVencimentoController {
    @AuraEnabled
    public static AlteracaoVencimentoBO.ContaFinanceiraTO getContaFinanceira(String contaFinanceiraId){
        return AlteracaoVencimentoBO.tratarContaFinanceira(contaFinanceiraId);
    }
    
    @AuraEnabled
    public static AlteracaoVencimentoBO.AssetTO tratarAsset(String contaFinanceiraId){
        return AlteracaoVencimentoBO.tratarAsset(contaFinanceiraId);
    }

    @AuraEnabled
    public static AlteracaoVencimentoBO.DataVencimentoTO getDataVencimentoFatura(String cpf, String numeroConta, String canal, String idEmpresa){
        return AlteracaoVencimentoBO.getDataVencimentoFatura(cpf, numeroConta, canal, idEmpresa);
    }

    @AuraEnabled
    public static AlteracaoVencimentoBO.DataVencimentoTO getDataVencimentoAtualizadaFatura(String cpf, String numeroConta, String canal, String idEmpresa){
        return AlteracaoVencimentoBO.getDataVencimentoAtualizadaFatura(cpf, numeroConta, canal, idEmpresa);
    }

    @AuraEnabled
    public static AlteracaoVencimentoBO.AlterarVencimentoTO alterarVencimento(String cpf, String numeroConta, String canal, String area, String sistema, String idEmpresa, String novoDiaVencimento){
        return AlteracaoVencimentoBO.alterarDataVencimento(cpf, numeroConta, canal, area, sistema, idEmpresa, novoDiaVencimento);
    }

    @AuraEnabled
    public static case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String origem, String canal){
        return AlteracaoVencimentoBO.criarCaso(contaFinanceiraId, accountId, unidadeNegocio, origem, canal);
    }
}