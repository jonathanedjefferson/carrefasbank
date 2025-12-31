public with sharing class BCSF_TransacoesOnUsOffUsBO {
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String tipo, String assunto, String evento){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = assunto;
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;
        
        return CaseDAO.getInstance().getById(cs.Id);
    }

    public static Case createCaseCancelamentoOffUs(String origem, String contaFinanceiraId, String accountId, 
        String unidadeNegocio, String canal, String assunto, String evento,
        String motivoCancelamento, String numeroAutorizacao, DateTime dataTransacao, Decimal valorCompra,
        String classificarRelatar, String recebeuProduto, String enderecoEntrega, Date dataEntrega,
        String mercadoriaDevolvida, Date dataDevolucao, String possuiVoucher, String fezEstorno,
        String estabelecimentoFechou, String fezContato, String qualCanal, Date dataContato,
        String protocoloEstabelecimento, String descricao){
            RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

            Group fila;
            if('Arrependimento'.equals(motivoCancelamento) || 'Mercadoria Não Recebida'.equals(motivoCancelamento)){
                fila = GroupDAO.getInstance().getGroupById('queue', 'RPADesacordoOffus');
            } else {
                fila = GroupDAO.getInstance().getGroupById('queue', 'INTDesacordoComercial');
            }

            Case cs = new Case();
            cs.OwnerId = fila.Id;
            cs.NomeCliente__c = accountId;
            cs.RecordTypeId = rt.Id;
            cs.Status = 'New';
            cs.Assunto__c = assunto;
            cs.Evento__c = evento;
            cs.Origin = origem;
            cs.ContaFinanceira__c = contaFinanceiraId;   
            cs.UnidadeNegocio__c = unidadeNegocio;  
            cs.Type = 'Solicitação';
            cs.CanalEntrada__c = canal;
            cs.Priority = 'Medium';

            cs.MotivoCancelamento__c = motivoCancelamento;
            cs.NumeroAutorizacao__c = numeroAutorizacao;
            cs.DataTransacao__c = dataTransacao;
            cs.ValorCompra__c = valorCompra;
            cs.ClassificarRelatar__c = classificarRelatar;
            cs.RecebeuProduto__c = recebeuProduto;
            cs.EnderecoEntrega__c = enderecoEntrega;
            cs.DataPrometidaEntrega__c = dataEntrega;
            cs.MercadoriaDevolvida__c = mercadoriaDevolvida;
            cs.DataDevolucao__c = dataDevolucao;
            cs.PossuiVoucher__c = possuiVoucher;
            cs.EstornoMais15Dias__c = fezEstorno;
            cs.EstabelecimentoFechou__c = estabelecimentoFechou;
            cs.ContatoRealizado__c = fezContato;
            cs.QualCanal__c = qualCanal;
            cs.DataContatoComEstabelecimento__c = dataContato;
            cs.ProtocoloNomeAtendente__c = protocoloEstabelecimento;
            cs.Description = descricao;

            insert cs;
            
            return CaseDAO.getInstance().getById(cs.Id);
    }

    public static Case createCaseCancelamentoOnfUs(String origem, String contaFinanceiraId, String accountId, 
        String unidadeNegocio, String canal, String assunto, String evento,
        String motivoCancelamento, String numeroAutorizacao, DateTime dataTransacao, Decimal valorCompra,
        Decimal valorCancelamento, Integer quantidadeParcelas, Date dataAjuste, String estabelecimento, String codigoPlano, String numeroCartao,
        String descricao, String nomeFila){
            RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
            Group fila;
            System.debug('nomeFila');
            System.debug(nomeFila);
            System.debug(origem);
            if(origem != null && origem.trim().equalsIgnoreCase('Lojas')){
                fila = GroupDAO.getInstance().getGroupById('queue', 'RPADesacordoOnUs');
            }else {
                switch on nomeFila {
                    when 'Carrefour' {
                        fila = GroupDAO.getInstance().getGroupById('queue', 'FinanceiroCCI');
                    }
                    when 'Atacadão' {
                        fila = GroupDAO.getInstance().getGroupById('queue', 'FinanceiroATC');
                    }
                    when 'Sams' {
                        fila = GroupDAO.getInstance().getGroupById('queue', 'FinanceiroSAMS');
                    }
                    when 'Ecommerce' {
                        fila = GroupDAO.getInstance().getGroupById('queue', 'Ecom');
                    }
                    when else {
                        fila = GroupDAO.getInstance().getGroupById(
                            'queue', 
                            'BCSF_QU_CAS_BOC_DESAC_COMERCIAL_ONUS'
                        );
                    }
                }
            }

            System.debug(fila);

            Case cs = new Case();
            cs.OwnerId = fila.Id;
            cs.NomeCliente__c = accountId;
            cs.RecordTypeId = rt.Id;
            cs.Status = 'New';
            cs.Assunto__c = assunto;
            cs.Evento__c = evento;
            cs.Origin = origem;
            cs.ContaFinanceira__c = contaFinanceiraId;   
            cs.UnidadeNegocio__c = unidadeNegocio;  
            cs.Type = 'Solicitação';
            cs.CanalEntrada__c = canal;
            cs.Priority = 'Medium';
            cs.NomeFila__c = nomeFila;
            cs.MotivoCancelamento__c = motivoCancelamento;
            cs.NumeroAutorizacao__c = numeroAutorizacao;
            cs.DataTransacao__c = dataTransacao;
            cs.ValorCompra__c = valorCompra;
            cs.ValorCancelamento__c = valorCancelamento;
            cs.QuantidadeParcelas__c = quantidadeParcelas;
            cs.DataAjuste__c = dataAjuste;
            cs.QualLoja__c = estabelecimento;
            cs.CodigoPlano__c = codigoPlano;
            cs.NumeroCartao__c = numeroCartao;
            cs.Description = descricao;

            insert cs;
            
            return CaseDAO.getInstance().getById(cs.Id);
    }
}