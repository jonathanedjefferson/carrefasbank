public class DebitoAutomaticoController {
    
    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static List<Banco__mdt> getBancos(){
        return DebitoAutomaticoBO.getInstance().getBancos();
    }

    @AuraEnabled
    public static DebitoAutomatico.OutputDebitoAutomatico consultarDebitoAutomatico(String cpf, String numeroConta, String nomeCorrentista, String idEmpresa, String canal){
        return DebitoAutomatico.ConsultarDebitoAutomatico(cpf, numeroConta, nomeCorrentista, idEmpresa, canal);
    }

    @AuraEnabled
    public static boolean cadastrarDebitoAutomatico(String cpf, String numeroConta, String nomeCorrentista, String codigoBanco,  String numeroAgencia, String numeroContaBancaria, String tipoPagamento, String idEmpresa, String canal) {  
        return DebitoAutomatico.CadastrarDebitoAutomatico(cpf, numeroConta, nomeCorrentista, codigoBanco, numeroAgencia, numeroContaBancaria, tipoPagamento, idEmpresa, canal);
    }  

    @AuraEnabled
    public static boolean removerDebitoAutomatico(String cpf, String numeroConta, String nomeCorrentista, String codigoBanco, String numeroAgencia, String numeroContaBancaria, String tipoPagamento, String idEmpresa, String canal) {
        return DebitoAutomatico.RemoverDebitoAutomatico(cpf, numeroConta, nomeCorrentista, codigoBanco, numeroAgencia, numeroContaBancaria, tipoPagamento, idEmpresa, canal);
    }

    @AuraEnabled
    public static Case criarCaso(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String tipo, String assunto, String evento){
        return DebitoAutomaticoBO.criarCaso(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, tipo, assunto, evento);
    }

}