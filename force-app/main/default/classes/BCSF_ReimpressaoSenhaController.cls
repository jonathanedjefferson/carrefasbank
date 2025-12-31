public class BCSF_ReimpressaoSenhaController {
    @AuraEnabled
    public static  BCSF_ReimpressaoSenhaBO.ContaFinanceiraTO getContaFinanceira(String contaFinanceiraId){
        return BCSF_ReimpressaoSenhaBO.tratarContaFinanceira(contaFinanceiraId);
    }
    @AuraEnabled
    public static case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String origem, String canal){
        return BCSF_ReimpressaoSenhaBO.criarCaso(contaFinanceiraId, accountId, unidadeNegocio, Origem, Canal);
    }
    @AuraEnabled
    public static List<ReimpressaoSenha.OutputListarCartoes> getListarCartoes(String numeroConta, String idEmpresa, String cpf, String canal, String area){
        return ReimpressaoSenha.ListarCartoes(numeroConta, idEmpresa, cpf, canal, area);
    }
    
    @AuraEnabled
    public static String ReimprimirSenha(String numeroConta, String numeroCartaoSerno, String idEmpresa, String cpf, String canal, String area, String sistema){
        return ReimpressaoSenha.ReimprimirSenha(numeroConta, numeroCartaoSerno, idEmpresa, cpf, canal, area, sistema);
    }
}