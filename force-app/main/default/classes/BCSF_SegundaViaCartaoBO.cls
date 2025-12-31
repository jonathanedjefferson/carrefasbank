public without sharing class BCSF_SegundaViaCartaoBO {

    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, Boolean isBraile, Boolean isNomeReduzido){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        String evento;
        String status = isBraile? 'New': 'Closed';
        String tipo = isBraile? 'Solicitação': 'Execução';

        if(isBraile){
            if(isNomeReduzido){
                evento = 'Segunda via de cartão - Braile com alteração no nome reduzido';
            }else{
                evento = 'Segunda via de cartão - Braile';
            }
        }else{
            if(isNomeReduzido){
                evento = 'Segunda via de cartão com alteração no nome reduzido';
            }else {
                evento ='Segunda via de cartão';
            }
        }

        if(unidadeNegocio == '1' && !isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatCarrefour');
        }else if(unidadeNegocio == '2' && !isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatAtacadao');
        }else if(unidadeNegocio == '6' && !isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatSamsClub');
        }else if(unidadeNegocio != null  && isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSFOperacoes');
        }


        Case cs = new Case();
        cs.OwnerId = gr.Id;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = status;
        cs.Assunto__c = 'Cartão';
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = tipo;
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return BCSF_ReimpressaoSenhaDAO.getInstance().getCase(cs.id);
    }

    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, Boolean isBraile){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        String evento = isBraile ? 'Segunda via de cartão - Braile' : 'Segunda via de cartão';
        String status = isBraile? 'New': 'Closed';
        String tipo = isBraile? 'Solicitação': 'Execução';


        if(unidadeNegocio == '1' && !isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatCarrefour');
        }else if(unidadeNegocio == '2' && !isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatAtacadao');
        }else if(unidadeNegocio == '6' && !isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatSamsClub');
        }else if(unidadeNegocio != null  && isBraile){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSFOperacoes');
        }


        Case cs = new Case();
        cs.OwnerId = gr.Id;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = status;
        cs.Assunto__c = 'Cartão';
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = tipo;
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return BCSF_ReimpressaoSenhaDAO.getInstance().getCase(cs.id);
    }

    public static void createCaseCodigoRastreio(String origem, String idOperador, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal){
        
        RecordType rt = null;
        if(canal == 'Chat'){
            rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
            origem = 'Pós Vendas'; //Sempre pós vendas quando derivado do Chat.
        } else if(canal == 'Voz' && origem == 'pos_vendas' ){
            rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_PosVenda');
            origem = 'Pós Vendas';
        } else if(canal == 'Voz' && origem == 'SAC' ){
            rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_SAC');
        } else {
            // Dados padrões para cenários onde o canal e voz estão vazios.
            canal = 'Voz';
            origem = 'Pós Vendas';
            rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        }
        
        Case cs = new Case();
        cs.OwnerId = idOperador;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Cartão';
        cs.Evento__c = 'Código de rastreio do cartão';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Informação';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;
    }

    public static void updateAtivo(String contaFinanceiraId, String cartaoOfuscado, String newStatus){
        List<String> crtList = cartaoOfuscado.split('\\.');

        List<Asset> listCartoes = BloqueioCartaoDAO.getAtivos(contaFinanceiraId);
        Asset retorno = new Asset();
        for(Asset item: listCartoes){
            if(item.NumeroCartao__c.contains(crtList[0]) && item.NumeroCartao__c.contains(crtList[3])){
                item.Status = newStatus;
                item.Situacao__c = 'I';
                item.CartaoPrimario__c = false;
                retorno = item;
                break;
            }
        }
        update retorno;
    }
}