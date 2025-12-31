public with sharing class CasoDAO {
    
    private static final CasoDAO instance = new CasoDAO();

    public static CasoDAO getInstance() {
      return instance;
    }

    public Case createCase(
        String ownerId, String recordTypeId, String status, String assunto, 
        String evento, String type, String priority, String canal, String origem, 
        String contaFinanceiraId, String accountId, String unidadeNegocio){
               
        Case cs = new Case();
        cs.OwnerId = ownerId;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = recordTypeId;
        cs.Status = status;
        cs.Assunto__c = assunto;
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = type;
        cs.CanalEntrada__c = canal;
        cs.Priority = priority;
        cs.CriarCasoPorComponente__c = true;

        insert cs;

        return CasoDAO.getInstance().getCase(cs.id);
    }

    public Case insertCase(Case caso){
        insert caso;
        return CasoDAO.getInstance().getCase(caso.id);
    }

    public Case createCaseContestacaoCompra(
        String ownerId, String recordTypeId, String status, String assunto, 
        String evento, String type, String priority, String canal, String origem, 
        String contaFinanceiraId, String accountId, String unidadeNegocio, String consultaEthoca,
        String tipoReclamacao, String descricao, List<LancamentoContestadoBO.LancamentoContestado> transacoesContestadas){
        
        Case cs = new Case();
        cs.OwnerId = ownerId;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = recordTypeId;
        cs.Status = status;
        cs.Assunto__c = assunto;
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = type;
        cs.CanalEntrada__c = canal;
        cs.Priority = priority;
        cs.CriarCasoPorComponente__c = true;
        cs.ConsultaEthoca__c = consultaEthoca;
        cs.Description = descricao;

        if(tipoReclamacao != null){
            cs.TipoReclamacao__c = tipoReclamacao;
        }
        
        Database.SaveResult saveResult = Database.insert(cs);

        if(!saveResult.isSuccess()) {
            throw new AuraHandledException('Não foi possível concluir a criação do caso. Motivo: ' + saveResult.getErrors()[0].getMessage());
        }
    
        List<Database.SaveResult> srLancamentos = LancamentoContestadoDAO.createLancamentosContestados(cs, transacoesContestadas);
        
        if(!srLancamentos.isEmpty() && !srLancamentos[0].isSuccess()) {
            throw new AuraHandledException('Não foi possível concluir o processo. Motivo: ' + srLancamentos[0].getErrors()[0].getMessage());
        }
            
        return CasoDAO.getInstance().getCase(cs.id);
    }

    public Case getCase(String caseId) {
        List<Case> lst = [
            SELECT 
                Id,
                CaseNumber,
                Evento__c,
                Assunto__c,
                Status,
                CreatedDate,
                ClosedDate,
                PrazoConclusao__c
            FROM 
                Case 
            WHERE 
                Id = :caseId
        ];

        return lst.isEmpty() ? null : lst[0];
    }

    public Case getCaseByNumber(String numeroProcotolo) {
        List<Case> lst = [
            SELECT 
                Id,
                CaseNumber,
                Evento__c,
                Assunto__c,
                Status,
                CreatedDate,
                ClosedDate,
                DataPrevistaFechamento__c
            FROM 
                Case 
            WHERE 
                CaseNumber = :numeroProcotolo
        ];

        return lst.isEmpty() ? null : lst[0];
    }


    public List<Case> getCasesLast30Days(List<String> origins, List<String> status, List<String> types, String contaFinanceiraId, Integer quantidade, Integer offset) {
        return [
            SELECT 
                Id,
                CaseNumber,
                CreatedDate
            FROM 
                Case 
            WHERE 
                Origin IN :origins
                AND Status IN :status
                AND Type IN :types
                AND CreatedDate > N_DAYS_AGO:30
                AND ContaFinanceira__c = :contaFinanceiraId
            ORDER BY CreatedDate DESC
            LIMIT :quantidade
            OFFSET :offset
        ];
    }
}