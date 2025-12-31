public without sharing class BCSF_DesbloqueioCartaoBO {
    
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Desbloqueio';
        cs.Evento__c = 'Desbloqueio de cartão de crédito';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return [SELECT CaseNumber FROM Case WHERE Id = :cs.Id];
    }

    public static void updateAtivo(String contaFinanceiraId, String cartaoOfuscado, String newStatus){
        List<String> crtList = cartaoOfuscado.split('\\.');

        List<Asset> listCartoes = BloqueioCartaoDAO.getAtivos(contaFinanceiraId);

        for(Asset item: listCartoes){
            if(item.NumeroCartao__c.contains(crtList[0]) && item.NumeroCartao__c.contains(crtList[3])){
                item.Status = newStatus;
                item.Situacao__c = 'A';
                update item;
                
                break;
            }
        }
    }
}