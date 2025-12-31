public  class AntecipacaoParcelasController {
    
    @AuraEnabled
    public static AntecipacaoParcelasTO.RetornoListarParcelamentos listarParcelamentos(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, Boolean incluirParcelas, String categoria, String periodoInicial, String periodoFinal){
        return AntecipacaoParcelas.listarParcelamentos(canal, cpf, unidadeNegocio, numeroConta, cpfDrtOperador, perfilOperador, incluirParcelas, categoria, periodoInicial, periodoFinal);
    }

    @AuraEnabled
    public static AntecipacaoParcelasTO.RetornoObterParcelamento obterParcelamento(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String idParcelamento){
        return AntecipacaoParcelas.obterParcelamento(canal, cpf, unidadeNegocio, numeroConta, cpfDrtOperador, perfilOperador, idParcelamento);
    }

    @AuraEnabled
    public static AntecipacaoParcelasTO.RotornoSimulacaoAntecipacaoMultipla simularAntecipacoes(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String parcelamentos){
        List<AntecipacaoParcelasTO.SimulacaoParcelamentoBody> listaAntecipacoes = (List<AntecipacaoParcelasTO.SimulacaoParcelamentoBody>) JSON.deserialize(parcelamentos, List<AntecipacaoParcelasTO.SimulacaoParcelamentoBody>.class);
        return AntecipacaoParcelas.simularAntecipacoes(canal, cpf, unidadeNegocio, numeroConta, cpfDrtOperador, perfilOperador, listaAntecipacoes);
    }
    
    @AuraEnabled
    public static AntecipacaoParcelasTO.RetornoAntecipacao anteciparParcelas(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String parcelamentos, String tipoPagamento, Boolean incluirPdfBoleto){
         List<AntecipacaoParcelasTO.AntecipacaoParcelamentoBody> listaAntecipacoes = (List<AntecipacaoParcelasTO.AntecipacaoParcelamentoBody>) JSON.deserialize(parcelamentos, List<AntecipacaoParcelasTO.AntecipacaoParcelamentoBody>.class);
        return AntecipacaoParcelas.anteciparParcelas(canal, cpf, unidadeNegocio, numeroConta, cpfDrtOperador, perfilOperador, listaAntecipacoes, tipoPagamento, incluirPdfBoleto);
    }

    @AuraEnabled
    public static AntecipacaoParcelasTO.RetornoPagamentoAvulso obterDadosPagamentoAvulso(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String antecipacaoId, String tipoPagamento, Decimal valor, Boolean incluirPdfBoleto){
        return AntecipacaoParcelas.obterDadosPagamentoAvulso(canal, cpf, unidadeNegocio, numeroConta, cpfDrtOperador, perfilOperador, antecipacaoId, tipoPagamento, valor, incluirPdfBoleto);
    }
    @AuraEnabled
    public static AntecipacaoParcelasTO.RetornoEnvioEmail enviarEmailAlternativo(String canal, String cpf, String unidadeNegocio, String numeroConta, String cpfDrtOperador, String perfilOperador, String antecipacaoMultiplaId, String  emailDestinatario, String tipoPagamento){
        return AntecipacaoParcelas.enviarEmailAlternativo(canal, cpf, unidadeNegocio, numeroConta, cpfDrtOperador, perfilOperador, antecipacaoMultiplaId, emailDestinatario, tipoPagamento);
    }

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira obterContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static Case criarCaso(String accountId, String status, String assunto, String evento, String origem, String contaFinanceiraId, String unidadeNegocio, String tipo, String canal, String prioridade){
        return AntecipacaoParcelasBO.criarCaso(accountId, status, assunto, evento, origem, contaFinanceiraId, unidadeNegocio, tipo, canal, prioridade);
    }

}