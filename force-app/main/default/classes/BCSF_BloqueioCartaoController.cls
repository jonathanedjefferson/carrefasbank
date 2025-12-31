public without sharing class BCSF_BloqueioCartaoController {
    @AuraEnabled
    public static List<BloqueioCartao.OutputListCartoesParaBloqueio> getListCartoes(String canal, String area, String cpf, String numeroConta){
        return BloqueioCartao.ListCartoesParaBloqueio(canal, area, cpf, numeroConta);
    }

    @AuraEnabled
    public static BloqueioCartao.OutputStatusBloqueio listStatusBloqueioCartao(String canal, String area){
        return BloqueioCartao.ListStatusBloqueioCartao(canal, area);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getCartaoTitular(String contaFinanceiraId){
        return AssetBO.getAssetTitular(contaFinanceiraId);
    }

    @AuraEnabled
    public static String getTipoBloqueioCartao(String statusCartao){
        String toReturn = 'STATUS_DEFINITIVO';
        
        List<String> status = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('FalecidoStatusProvisorio');
        if(status != null && status.contains(statusCartao)){
            toReturn = 'STATUS_PROVISORIO';
        }

        return toReturn;
    }

    @AuraEnabled
    public static Boolean bloquearCartao(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String numeroCartaoSerno, String novoStatus){
        return BloqueioCartao.BloquearCartao(idEmpresa, sistema, canal, area, cpf, numeroConta, numeroCartaoSerno, novoStatus);
    }

    @AuraEnabled
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        if(unidadeNegocio == '1'){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatCarrefour');
        }else if(unidadeNegocio == '2'){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatAtacadao');
        }else if(unidadeNegocio == '6'){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatSamsClub');
        }


        Case cs = new Case();
        cs.OwnerId = gr.Id;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Bloqueio';
        cs.Evento__c = 'Bloqueio de cartão de crédito';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return [SELECT CaseNumber FROM Case WHERE Id = :cs.Id];
    }

    @AuraEnabled
    public static Case createCaseFalecimento(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String telefoneContato){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        gr = BloqueioCartaoDAO.getQueue('Queue', 'RPAFalecido');

        Case cs = new Case();
        cs.OwnerId = gr.Id;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Em tratativa';
        cs.Assunto__c = 'Bloqueio';
        cs.Evento__c = 'Falecimento';
        cs.TelefoneRetorno__c = telefoneContato ;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Solicitação';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return [SELECT CaseNumber FROM Case WHERE Id = :cs.Id];
    }

    @AuraEnabled
    public static void updateAtivo(String contaFinanceiraId, String cartaoOfuscado, String newStatus){
        List<String> crtList = cartaoOfuscado.split('\\.');

        List<Asset> listCartoes = BloqueioCartaoDAO.getAtivos(contaFinanceiraId);

        for(Asset item: listCartoes){
            if(item.NumeroCartao__c.contains(crtList[0]) && item.NumeroCartao__c.contains(crtList[3])){
                item.Status = newStatus;
                item.Situacao__c = 'I';
                update item;
                
                break;
            }
        }
    }

    @AuraEnabled
    public static InfoStatus__c getInfoStatus(String status){
        return BloqueioCartaoDAO.getInfoStatus(status);
    }
}