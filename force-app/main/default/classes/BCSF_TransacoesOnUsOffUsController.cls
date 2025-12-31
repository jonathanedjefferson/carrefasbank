public with sharing class BCSF_TransacoesOnUsOffUsController {
    @AuraEnabled
    public static IdentificaCockpit.ResponseAPIContaFinanceira getListCartoes(String numeroConta, String idEmpresa, String cpf, String canal){
        return IdentificaCockpit.identificaNumeroConta(numeroConta, idEmpresa, cpf, canal);
    }

    @AuraEnabled
    public static AutorizacoesOnUsOffUs.OutputAutorizacoes GetAutorizacoesOnUsOffUs(String CPF, String NumeroConta, String Token, String unidadeNegocio, String canal, String numeroCartaoSerno, String dataInicial, String dataFinal, string tamanhoPagina, String pagina){
        return AutorizacoesOnUsOffUs.GetAutorizacoesOnUsOffUs(CPF, NumeroConta, Token, unidadeNegocio, canal, numeroCartaoSerno, dataInicial, dataFinal, tamanhoPagina, pagina);
    }

    @AuraEnabled
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String tipo, String assunto, String evento){
        return BCSF_TransacoesOnUsOffUsBO.createCase(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, tipo, assunto, evento);
    }

    @AuraEnabled
    public static Case createCaseCancelamentoOffUs(String origem, String contaFinanceiraId, String accountId, 
        String unidadeNegocio, String canal, String assunto, String evento,
        String motivoCancelamento, String numeroAutorizacao, String dataTransacao, Decimal valorCompra,
        String classificarRelatar, String recebeuProduto, String enderecoEntrega, Date dataEntrega,
        String mercadoriaDevolvida, Date dataDevolucao, String possuiVoucher, String fezEstorno,
        String estabelecimentoFechou, String fezContato, String qualCanal, Date dataContato, String protocoloEstabelecimento, String descricao){

            Datetime dataTransacaoDatetime = null;
            if(String.isNotBlank(dataTransacao)){
                String[] dataHorario = dataTransacao.trim().split(' ');
                if(dataHorario.size() > 1){
                    String[] data = dataHorario[0].split('/');
                    String[] horario = dataHorario[1].split(':');
                    if(data.size() == 3  && horario.size() == 3){
                        dataTransacaoDatetime = Datetime.newInstanceGmt(Integer.valueOf(data[2]), Integer.valueOf(data[1]), Integer.valueOf(data[0]), 
                        Integer.valueOf(horario[0]), Integer.valueOf(horario[1]), Integer.valueOf(horario[2]));
                    }
                }
            }

            return BCSF_TransacoesOnUsOffUsBO.createCaseCancelamentoOffUs(origem, contaFinanceiraId, accountId, unidadeNegocio, canal, assunto, evento,
            motivoCancelamento,  numeroAutorizacao, dataTransacaoDatetime, valorCompra, classificarRelatar, recebeuProduto, enderecoEntrega, dataEntrega,
            mercadoriaDevolvida, dataDevolucao, possuiVoucher, fezEstorno, estabelecimentoFechou, fezContato, qualCanal, dataContato, protocoloEstabelecimento, descricao);
    }

    @AuraEnabled
    public static Case createCaseCancelamentoOnUs(String origem, String contaFinanceiraId, String accountId, 
        String unidadeNegocio, String canal, String assunto, String evento,
        String motivoCancelamento, String numeroAutorizacao, String dataTransacao, Decimal valorCompra,
        Decimal valorCancelamento, String quantidadeParcelas, Date dataAjuste, String estabelecimento, 
        String codigoPlano, String numeroCartao, String descricao, String nomeFila){

            Datetime dataTransacaoDatetime = null;
            if(String.isNotBlank(dataTransacao)){
                String[] dataHorario = dataTransacao.trim().split(' ');
                if(dataHorario.size() > 1){
                    String[] data = dataHorario[0].split('/');
                    String[] horario = dataHorario[1].split(':');
                    if(data.size() == 3  && horario.size() == 3){
                        dataTransacaoDatetime = Datetime.newInstanceGmt(Integer.valueOf(data[2]), Integer.valueOf(data[1]), Integer.valueOf(data[0]), 
                        Integer.valueOf(horario[0]), Integer.valueOf(horario[1]), Integer.valueOf(horario[2]));
                    }
                }
            }

            Integer numeroParcelas = 0;
            if(String.isNotBlank(quantidadeParcelas) && quantidadeParcelas.isNumeric()){
                numeroParcelas = Integer.valueOf(quantidadeParcelas);
            }

            return BCSF_TransacoesOnUsOffUsBO.createCaseCancelamentoOnfUs(origem, contaFinanceiraId, accountId, 
            unidadeNegocio, canal, assunto, evento, motivoCancelamento, numeroAutorizacao, dataTransacaoDatetime, valorCompra,
            valorCancelamento, numeroParcelas, dataAjuste, estabelecimento, codigoPlano, numeroCartao, descricao, nomeFila);
    }

}