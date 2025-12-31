public class DebitoAutomaticoBO {

    private static final DebitoAutomaticoBO instance = new DebitoAutomaticoBO();

    public static DebitoAutomaticoBO getInstance() {
      return instance;
    }
    
    public List<Banco__mdt> getBancos(){
        return BancoDAO.getInstance().getAllDebitoAutomatico();
    }

    public static Case criarCaso(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String tipo, String assunto, String evento){
      RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

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

}