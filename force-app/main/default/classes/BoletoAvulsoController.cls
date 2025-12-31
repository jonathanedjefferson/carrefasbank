public class BoletoAvulsoController {

    @AuraEnabled
    public static BoletoAvulso.OutputParametrosIniciais obterParametrosIniciais(String numeroConta, String cpf, String unidade, String canal, String sistema, String area, String loginOperador){
        return BoletoAvulso.obterParametrosIniciais(numeroConta, cpf, unidade, canal, sistema, area, loginOperador);
    }

    @AuraEnabled
    public static BoletoAvulso.OutputGerarBoleto gerarBoletoAvulso(String numeroConta, String cpf, String unidade, String canal, String email, Decimal valorBoleto, Integer tipoBoleto, String sistema, String area, String loginOperador){
        return BoletoAvulso.gerarBoletoAvulso(numeroConta, cpf, unidade, canal, email, valorBoleto, tipoBoleto, sistema, area, loginOperador);
    }

    @AuraEnabled
    public static BoletoAvulso.OutputEnviarBoleto enviarBoleto(String numeroConta, String cpf, String unidade, String canal, String email, List<String> idBoletos, String sistema, String area, String loginOperador){
        return BoletoAvulso.enviarBoleto(numeroConta, cpf, unidade, canal, email, idBoletos, sistema, area, loginOperador);
    }

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static Case criarCaso(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String tipo, String assunto, String evento){
        return BoletoAvulsoBO.criarCaso(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, tipo, assunto, evento);
    }

    @AuraEnabled
    public static Boolean atualizarEmail(String cpf, String unidade, String canal, String email, String numeroConta, String area, String sistema){
        return IntegrationAlteracaoCadastral.AlterarEmail(cpf, unidade, canal, email, numeroConta, area, sistema);
    }

}