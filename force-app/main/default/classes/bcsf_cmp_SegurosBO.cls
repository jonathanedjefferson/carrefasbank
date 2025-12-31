public without sharing class bcsf_cmp_SegurosBO {

    private static final String STANDARD_USER_NAME = 'duser@salesforce.com.bcsf%';

    public static Knowledge__kav getArtigos(String title) {
        return bcsf_cmp_SegurosDAO.getInstance().getArtigos(title);
    }

    public static Account getAccount(String accountId) {
        return bcsf_cmp_SegurosDAO.getInstance().getAccount(accountId);
    }

    public static Case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Seguros';
        cs.Evento__c = 'Adesão de seguro';
        cs.Origin = Origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = Canal;
        cs.Priority = 'Medium';
        cs.CriarCasoPorComponente__c = true;

        insert cs;

        return bcsf_cmp_SegurosDAO.getInstance().getCase(cs.id);
    }

    public static Case criarCasoCancelamento(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal, String observacao, String outroMotivo, segurosCaso seguro) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Seguros';
        cs.Evento__c = 'Cancelamento de seguro';
        cs.Contratos__c = seguro.contrato;
        cs.MotivoCancelamento__c = seguro.motivo;
        cs.Seguro__c = seguro.nome;
        cs.Origin = Origem;
        cs.Description = observacao;
        cs.Resolucao__c = outroMotivo;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = Canal;
        cs.Priority = 'Medium';
        cs.CriarCasoPorComponente__c = true;

        insert cs;

        return bcsf_cmp_SegurosDAO.getInstance().getCase(cs.id);
    }

    public static Case criarCasosContestar(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal, List<segurosCaso> seguros) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = BloqueioCartaoDAO.getQueue('Queue', 'RPASeguroContestacao');
        List<User> lLstStandardUserId = [SELECT Id FROM User WHERE UserName LIKE : STANDARD_USER_NAME LIMIT 1];

        List<Case> listCase = new List<Case>();
        Case cs = new Case();
        cs.OwnerId = !lLstStandardUserId.isEmpty() ? lLstStandardUserId.get(0).Id : UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Em tratativa';
        cs.Assunto__c = 'Seguros';
        cs.Evento__c = 'Contestação';
        cs.Origin = Origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Solicitação';
        cs.CanalEntrada__c = Canal;
        cs.Priority = 'Medium';
        cs.CriarCasoPorComponente__c = true;
        insert cs;

        for( segurosCaso seguro : seguros ) {
            Case csFilho = new Case();
            csFilho.OwnerId = gr.id;
            csFilho.NomeCliente__c = accountId;
            csFilho.RecordTypeId = rt.Id;
            csFilho.Status = 'Closed';
            csFilho.Assunto__c = 'Seguros';
            csFilho.Evento__c = 'Contestação';
            csFilho.Origin = Origem;
            csFilho.Contratos__c = seguro.contrato;
            csFilho.MotivoCancelamento__c = seguro.motivo;
            csFilho.Seguro__c = seguro.nome;
            csFilho.ParentId = cs.id;
            csFilho.ContaFinanceira__c = contaFinanceiraId;   
            csFilho.UnidadeNegocio__c = unidadeNegocio;  
            csFilho.Type = 'Solicitação';
            csFilho.CanalEntrada__c = Canal;
            csFilho.Priority = 'Medium';
            csFilho.CriarCasoPorComponente__c = true;
            listCase.add(csFilho);
        }
        insert listCase;

        return bcsf_cmp_SegurosDAO.getInstance().getCase(cs.id);
    }

    public class segurosCaso{
        public String nome;
        public String contrato;
        public String motivo;
    }
}