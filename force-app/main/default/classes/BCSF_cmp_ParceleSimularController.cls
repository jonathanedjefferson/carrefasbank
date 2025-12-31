public class BCSF_cmp_ParceleSimularController {
    
    @AuraEnabled
    public static  BCSF_ReimpressaoSenhaBO.ContaFinanceiraTO getContaFinanceira(String contaFinanceiraId){
        return BCSF_ReimpressaoSenhaBO.tratarContaFinanceira(contaFinanceiraId);
    }
    
    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputListarPerfis getPerfis(String numeroConta, String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.listarPerfis(numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputDefault alterarPerfil(String nomePerfil, String numeroConta, String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.alterarPerfil(nomePerfil, numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputModalidades modalidadeParcele(String numeroConta ,String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.modalidadeParcele(numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputSimulacao simularSaldoTotal(String dataEntrada, String valorEntrada, String numeroConta ,String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.simularSaldoTotal(dataEntrada, valorEntrada, numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputSimulacao simularFaturaFechada(String dataEntrada, String valorEntrada, String numeroConta ,String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.simularFaturaFechada(dataEntrada, valorEntrada, numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputSimulacao simularSaldoParcial(String transacoes, String dataEntrada, String valorEntrada, String numeroConta ,String cpf, String canal, String idEmpresa){
        List<IntegracaoParceleFacilTO.Transacao> listTransacoes = (List<IntegracaoParceleFacilTO.Transacao>) JSON.deserialize(transacoes, List<IntegracaoParceleFacilTO.Transacao>.class);
        return IntegracaoParceleFacil.simularSaldoParcial(listTransacoes, dataEntrada, valorEntrada, numeroConta, cpf, canal, idEmpresa);
    }
    
    @auraEnabled
    public static IntegracaoParceleFacilTO.OutputContratar contratarSaldoTotal(String formaPagamento, String valorEntrada, String dataPagamento,String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        IntegracaoParceleFacilTO.FormaPagamento pagamento = (IntegracaoParceleFacilTO.FormaPagamento) JSON.deserialize(formaPagamento, IntegracaoParceleFacilTO.FormaPagamento.class);
        IntegracaoParceleFacilTO.Valor valor = (IntegracaoParceleFacilTO.Valor) JSON.deserialize(valorEntrada, IntegracaoParceleFacilTO.Valor.class);
        return IntegracaoParceleFacil.contratarSaldoTotal(pagamento, valor, dataPagamento, tipoPagamento, numeroConta, cpf, canal, idEmpresa);
    }

    @auraEnabled
    public static IntegracaoParceleFacilTO.OutputContratar contratarSaldoParcial(String formaPagamento, String transacoes, String valorEntrada, String dataPagamento,String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        IntegracaoParceleFacilTO.FormaPagamento pagamento = (IntegracaoParceleFacilTO.FormaPagamento) JSON.deserialize(formaPagamento, IntegracaoParceleFacilTO.FormaPagamento.class);
        IntegracaoParceleFacilTO.Valor valor = (IntegracaoParceleFacilTO.Valor) JSON.deserialize(valorEntrada, IntegracaoParceleFacilTO.Valor.class);
        List<IntegracaoParceleFacilTO.Transacao> listTransacoes = (List<IntegracaoParceleFacilTO.Transacao>) JSON.deserialize(transacoes, List<IntegracaoParceleFacilTO.Transacao>.class);
        return IntegracaoParceleFacil.contratarSaldoParcial(pagamento, listTransacoes, valor, dataPagamento, tipoPagamento, numeroConta, cpf, canal, idEmpresa);
    }

    @auraEnabled
    public static IntegracaoParceleFacilTO.OutputContratar contratarFaturaFechada(String formaPagamento, String valorEntrada, String dataPagamento,String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        IntegracaoParceleFacilTO.FormaPagamento pagamento = (IntegracaoParceleFacilTO.FormaPagamento) JSON.deserialize(formaPagamento, IntegracaoParceleFacilTO.FormaPagamento.class);
        IntegracaoParceleFacilTO.Valor valor = (IntegracaoParceleFacilTO.Valor) JSON.deserialize(valorEntrada, IntegracaoParceleFacilTO.Valor.class);
        return IntegracaoParceleFacil.contratarFaturaFechada(pagamento, valor, dataPagamento, tipoPagamento, numeroConta, cpf, canal, idEmpresa);
    }

    @auraEnabled
    public static IntegracaoParceleFacilTO.OutputDefault enviarEmail(String parceleId, String email, String tipoPagamento ,String numeroConta, String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.enviarEmail(parceleId, email, tipoPagamento, numeroConta, cpf, canal, idEmpresa);
    }

    @auraEnabled
    public static IntegracaoParceleFacilTO.OutputPagamentoEntrada pagamentoEntrada(String pagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        IntegracaoParceleFacilTO.InputPagamentoEntrada pague = (IntegracaoParceleFacilTO.InputPagamentoEntrada) JSON.deserialize(pagamento,  IntegracaoParceleFacilTO.InputPagamentoEntrada.class);
        return IntegracaoParceleFacil.pagamentoEntrada(pague, numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputGetPerfil getPerfil(String numeroConta, String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.getPerfil(numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputListarParcelePendente listarParcelePendente(String numeroConta, String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.listarParcelePendente(numeroConta, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoParceleFacilTO.OutputListarContratados listarParceleContratados(String numeroConta, String cpf, String canal, String idEmpresa){
        return IntegracaoParceleFacil.listarParceleContratados(numeroConta, cpf, canal, idEmpresa);
    }

    @auraEnabled
    public static Case criarCaso(String casoType, String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal) {
        return BCSF_cmp_ParceleSimularBO.criarCaso(casoType, contaFinanceiraId, accountId, unidadeNegocio, Origem, Canal);
    }
}