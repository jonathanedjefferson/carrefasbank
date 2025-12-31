public class AntecipacaoParcelasBO {

    public static Case criarCaso(String accountId, String status, String assunto, String evento, String origem, String contaFinanceiraId, String unidadeNegocio, String tipo, String canal, String prioridade){
      RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = status;
        cs.Assunto__c = assunto;
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = tipo;
        cs.CanalEntrada__c = canal;
        cs.Priority = prioridade;

        insert cs;
        
        return CaseDAO.getInstance().getById(cs.Id);
    }

}