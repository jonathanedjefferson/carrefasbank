public with sharing class CreditoPessoalBO {

    public static Case criarCaso(Map<String, Object> inputs) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = rt.Id;

        cs.NomeCliente__c       =  (Id)      inputs.get('accountId');
        cs.Status               =  (String)  inputs.get('status');
        cs.Assunto__c           =  (String)  inputs.get('assunto');
        cs.Evento__c            =  (String)  inputs.get('evento');
        cs.Origin               =  (String)  inputs.get('origem');
        cs.ContaFinanceira__c   =  (Id)      inputs.get('contaFinanceiraId');
        cs.UnidadeNegocio__c    =  (String)  inputs.get('unidadeNegocio');
        cs.Type                 =  (String)  inputs.get('tipo');
        cs.CanalEntrada__c      =  (String)  inputs.get('canal');
        cs.Priority             =  (String)  inputs.get('prioridade');
        cs.description          =  (String)  inputs.get('descricao');

        insert cs;
        return CaseDAO.getInstance().getById(cs.Id);
    }
}