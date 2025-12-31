public without sharing class BCSF_ConsultarPropostaController {

    @AuraEnabled
    public static IntegracaoConsultarPropostas.OutPutConsultarPropostas consultarPropostas(String cpf, String status, String modalidade, String dataInicio, String dataFim, String canal) {
        return IntegracaoConsultarPropostas.ConsultarPropostas(cpf, status, modalidade, dataInicio, dataFim, canal);
    }

    @AuraEnabled
    public static IntegracaoConsultarPropostas.OutputHistoricoProposta consultarHistoricoProposta(String numeroProposta, String cpf, String canal) {
        return IntegracaoConsultarPropostas.ConsultarHistoricoProposta(numeroProposta, cpf, canal);
    }
    
    @AuraEnabled
    public static PerfisConsultaProsposta__mdt getAcessoPerfil(String label) {
        return BCSF_ConsultarPropostaDAO.getInstance().getAcessoPerfil(label);
    }

    @AuraEnabled
    public static List<ParametrosConsultaProposta__mdt> getListParametrosProposta() {
        return BCSF_ConsultarPropostaDAO.getInstance().getListParametrosProposta();
    }

    @AuraEnabled
    public static Case criarCasoConsulta(String nomeCliente, String accountId, String cpf, String origem, String canal) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = String.isEmpty(accountId) ?  null : accountId;
        cs.RecordTypeId = rt.Id;
        cs.CPFContato__c = cpf;
        cs.NomeContato__c = nomeCliente;
        cs.Assunto__c = 'Cartão';
        cs.Evento__c = 'Consulta de proposta';
        cs.Origin = origem;
        cs.CanalEntrada__c = canal;
        cs.CriarCasoPorComponente__c = true;

        insert cs;

        return BCSF_ConsultarPropostaDAO.getInstance().getCase(cs.id);
    }

    @AuraEnabled
    public static Case criarCasoPropostaRecusada(String nomeCliente, String accountId, String cpf, String origem, String canal, String descricao) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = String.isEmpty(accountId) ?  null : accountId;
        cs.RecordTypeId = rt.Id;
        cs.CPFContato__c = cpf;
        cs.NomeContato__c = nomeCliente;
        cs.Assunto__c = 'Cartão';
        cs.Evento__c = 'Recusa de crédito';
        cs.Origin = origem;
        cs.Description = descricao;
        cs.CanalEntrada__c = canal;
        cs.CriarCasoPorComponente__c = true;

        insert cs;

        return BCSF_ConsultarPropostaDAO.getInstance().getCase(cs.id);
    }
}