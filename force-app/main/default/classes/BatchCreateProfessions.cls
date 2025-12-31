global class BatchCreateProfessions implements Database.Batchable<ParametroConsultaProfissao__c>, Database.AllowsCallouts, Database.Stateful {
    public Integer currentOcupationIndex = 0;
    public ParametroConsultaProfissao__c ocupacao;
    public List<ParametroConsultaProfissao__c> lLstOcupation;
    private static final Integer ID_EMPRESA = 1;
    private static final String CANAL = 'Cockpit';
    private static final String CPF = '12345678910';

    public BatchCreateProfessions(Integer ocupationIndex) {
        if (this.lLstOcupation == null) {
            this.lLstOcupation = CreateProfessionHelper.getExistingOcupation();
        }

        this.currentOcupationIndex = ocupationIndex;
        this.ocupacao = this.lLstOcupation[this.currentOcupationIndex];
    }

    global Iterable<ParametroConsultaProfissao__c> start(Database.BatchableContext bc) {
        //Buscar todas as profissões vinculadas a ocupação da execução do contexto que não estão maracadas com Deletar = true
        List<ParametroConsultaProfissao__c> lLstProfissoesToDelete = CreateProfessionHelper.gerProfessionByOcupation(Integer.valueOf(this.ocupacao.Codigo__c));
        CreateProfessionHelper.setParamsToDelete(lLstProfissoesToDelete);

        List<ParametroConsultaProfissao__c> lLstCategories = CreateProfessionHelper.getCategoriesByOcupation(Integer.valueOf(this.ocupacao.Codigo__c));
        return lLstCategories;
    }

    global void execute(Database.BatchableContext bc, List<ParametroConsultaProfissao__c> contextData) {
        List<ParametroConsultaProfissao__c> newProfessions = new List<ParametroConsultaProfissao__c>();

        for (ParametroConsultaProfissao__c category : contextData) {
            BCSF_AquisicaoDeCartaoTO.responseWrapper response = BCSF_AquisicaoDeCartao.buscarProfissoes(CANAL, ID_EMPRESA, Integer.valueOf(this.ocupacao.Codigo__c), Integer.valueOf(category.Codigo__c), 1, 1000, CPF);
            if (response.statusCode != 200) {
                continue;
            }
    
            BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper body = (BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper) response.body;
            List<BCSF_AquisicaoDeCartaoTO.Dados> professions = (List<BCSF_AquisicaoDeCartaoTO.Dados>) body.dados;
            
            newProfessions.addAll(CreateProfessionHelper.createNewProfessions(professions, Integer.valueOf(this.ocupacao.Codigo__c), Integer.valueOf(category.Codigo__c)));
        }

        if (!newProfessions.isEmpty()) {
            insert newProfessions;
        }

    }

    global void finish(Database.BatchableContext bc) {
        //Percorre Ocupacao -> Reseta Pagina e Resetar Categoria
        if (this.currentOcupationIndex < this.lLstOcupation.size() - 1) {
            this.currentOcupationIndex++; 
            BatchCreateProfessions lBatch = new BatchCreateProfessions(this.currentOcupationIndex);
            Database.executeBatch(lBatch, 200);
            return;
        }

        //Realiza a exclusão das prifissões antigas que foram maracadas com o Deletar = true
        CreateProfessionHelper.deletePreviousRecords('Profissao');

        // //Ao final realizar a chamada para ordenar ranquear as principais profissões
        BatchSetProfessionRank lBatchRank = new BatchSetProfessionRank();
        Database.executeBatch(lBatchRank, 200);
    }
}