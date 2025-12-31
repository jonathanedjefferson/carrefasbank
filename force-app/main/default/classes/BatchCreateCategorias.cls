global class BatchCreateCategorias implements Database.Batchable<ParametroConsultaProfissao__c>, Database.AllowsCallouts {

    private static final Integer ID_EMPRESA = 1;
    private static final String CANAL = 'Cockpit';
    private static final String CPF = '12345678910';

    global Iterable<ParametroConsultaProfissao__c> start(Database.BatchableContext bc) {
        //Consulta todas as categorias existentes que não estão maracadas com o Deletar = true
        List<ParametroConsultaProfissao__c> lLstCategoriesToDelete = CreateProfessionHelper.getAllCategories();
        CreateProfessionHelper.setParamsToDelete(lLstCategoriesToDelete);

        List<ParametroConsultaProfissao__c> lLstOcupation = CreateProfessionHelper.getExistingOcupation();
        return lLstOcupation;
    }

    global void execute(Database.BatchableContext bc, List<ParametroConsultaProfissao__c> contextData) {
        ParametroConsultaProfissao__c currentOcupation = contextData[0];

        BCSF_AquisicaoDeCartaoTO.responseWrapper response = BCSF_AquisicaoDeCartao.buscarCategorias(CANAL, ID_EMPRESA, Integer.valueOf(currentOcupation.Codigo__c), 1, 1000, CPF);
        if (response.statusCode != 200) {
            return;
        }

        BCSF_AquisicaoDeCartaoTO.buscarCategoriasResponseWrapper body = (BCSF_AquisicaoDeCartaoTO.buscarCategoriasResponseWrapper) response.body;
        List<BCSF_AquisicaoDeCartaoTO.Dados> categorias = (List<BCSF_AquisicaoDeCartaoTO.Dados>) body.dados;
        
        CreateProfessionHelper.createNewCategories(categorias, Integer.valueOf(currentOcupation.Codigo__c));
    }

    global void finish(Database.BatchableContext bc) {
        CreateProfessionHelper.createConstantValues();
        //Realizar a exclusão de todos as categorias marcadas com Deletar = true
        CreateProfessionHelper.deletePreviousRecords('Categoria');

        BatchCreateProfessions lBatch = new BatchCreateProfessions(0);
        Database.executeBatch(lBatch, 200);
    }
}