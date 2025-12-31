public class ContestacaoCompraController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static List<IdentificaCockpit.Cartao> getListCartoes(String numeroConta, String idEmpresa, String cpf, String canal){
        List<IdentificaCockpit.Cartao> toReturn = null;
        
        IdentificaCockpit.ResponseAPIContaFinanceira response = IdentificaCockpit.identificaNumeroConta(numeroConta, idEmpresa, cpf, canal);
        
        if(response != null && 
            response.data != null &&
            response.data.clientePorConta != null &&
            response.data.clientePorConta.contaCartao != null &&
            response.data.clientePorConta.contaCartao.contratos != null && 
            response.data.clientePorConta.contaCartao.contratos.size() > 0) {
                toReturn = response.data.clientePorConta.contaCartao.contratos[0].cartoes;
        }

        return toReturn;
    }

    @AuraEnabled
    public static AutorizacoesOnUsOffUs.OutputAutorizacoes getListTransacoes(
        String cpf, String numeroConta, String unidadeNegocio, 
        String canal, String numeroCartaoSerno, String dataInicial, String dataFinal,
        String tamanhoPagina, String pagina) {

        AutorizacoesOnUsOffUs.OutputAutorizacoes toReturn = AutorizacoesOnUsOffUs.GetAutorizacoesOnUsOffUs(cpf, numeroConta, 
            null, unidadeNegocio, canal, numeroCartaoSerno, dataInicial, dataFinal, tamanhoPagina, pagina);

        return toReturn;
    }

    @AuraEnabled
    public static String bloquearCartao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno, String novoStatus){
        return BloqueioCartao.BloquearCartaoContestacao(idEmpresa, sistema, canal, area, cpf, numeroConta, numeroCartaoSerno, novoStatus);
    }

    @AuraEnabled
    public static Case createCase(String evento, String canal, String origem, String contaFinanceiraId, 
        String accountId, String unidadeNegocio, String tipoReclamacao, 
        String consultaEthoca, String descricao, String transacoesContestadasJson){

            RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
            List<LancamentoContestadoBO.LancamentoContestado> transacoesContestadas = 
                (List<LancamentoContestadoBO.LancamentoContestado>) System.JSON.deserialize(transacoesContestadasJson, List<LancamentoContestadoBO.LancamentoContestado>.class);

            List<String> tipoReclamacaoIntercambio = new List<String>{'Re-discorda parecer', 'Re-Solicita parecer Análise', 'Reanalise UIND', 'Não reconhece compra na lista'};
            Group fila;
            if('Não reconhece compra'.equals(evento)){
                fila = GroupDAO.getInstance().getGroupById('queue', 'RPAContestacao');
            } else {
                if(tipoReclamacaoIntercambio.contains(tipoReclamacao)){
                    fila = GroupDAO.getInstance().getGroupById('queue', 'Intercambio');
                } else {
                    fila = GroupDAO.getInstance().getGroupById('queue', 'PrevencaoFraude');
                }
            }

            return CasoDAO.getInstance().createCaseContestacaoCompra(fila.Id, rt.Id, 'New', 'Intercâmbio fraude', 
            evento, 'Solicitação', 'Medium', canal, origem, contaFinanceiraId, 
            accountId, unidadeNegocio, consultaEthoca, tipoReclamacao, descricao, transacoesContestadas);
    }

    /**
     * @description Método para marcação das transações no sistema da Paytrue.
     */
    @AuraEnabled
    public static List<ContestacaoCompras.OutputMarcarTransacao> marcarTransacoes(String canal, String idEmpresa, String cpf, String tipoReclamacao,
         String transacoesContestadasJson){

        List<LancamentoContestadoBO.LancamentoContestado> transacoesContestadas = 
            (List<LancamentoContestadoBO.LancamentoContestado>) System.JSON.deserialize(transacoesContestadasJson, List<LancamentoContestadoBO.LancamentoContestado>.class);

        // Uso indevido de numeração
        String tipoFraude = '10'; 
        String dataFraudeReportada = Datetime.now().format('yyyyMMddHHmmss');

        List<ContestacaoCompras.OutputMarcarTransacao> execucaoMarcacaoTransacoes = ContestacaoCompras.MarcarTransacaoPaytrue(
            canal, idEmpresa, cpf, dataFraudeReportada, tipoFraude, transacoesContestadas);

            return execucaoMarcacaoTransacoes;
    }
    
}