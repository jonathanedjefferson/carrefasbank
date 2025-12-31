global class BatchSetProfessionRank implements Database.Batchable<ParametroConsultaProfissao__c>, Database.AllowsCallouts {

    private static final Integer ID_EMPRESA = 1;
    private static final String CANAL = 'Cockpit';
    private static final String CPF = '12345678910';
    private List<ParametroConsultaProfissao__c> rankedProfessions;

    global Iterable<ParametroConsultaProfissao__c> start(Database.BatchableContext bc) {
        List<ParametroConsultaProfissao__c> lLstOcupation = CreateProfessionHelper.getExistingOcupation();

        return lLstOcupation;
    }

    global void execute(Database.BatchableContext bc, List<ParametroConsultaProfissao__c> contextData) {
        Map<String, Integer> lMapProfessionByRank = new Map<String, Integer>();
        List<Integer> lLstProfessionCodes = new List<Integer>();
        this.rankedProfessions = new List<ParametroConsultaProfissao__c>();

        for (ParametroConsultaProfissao__c ocupacao : contextData) {
            BCSF_AquisicaoDeCartaoTO.responseWrapper response = BCSF_AquisicaoDeCartao.buscarProfissoes(CANAL, ID_EMPRESA, Integer.valueOf(ocupacao.Codigo__c), null, 1, 8, CPF);
            if (response.statusCode != 200) {
                continue;
            }
    
            BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper body = (BCSF_AquisicaoDeCartaoTO.buscarProfissaoResponseWrapper) response.body;
            List<BCSF_AquisicaoDeCartaoTO.Dados> professions = (List<BCSF_AquisicaoDeCartaoTO.Dados>) body.dados;
            
            //Uma profissão pode aparecer ao mesmo tempo em mais de uma ocupação, mas em ranks diferentes
            for (Integer i = 0 ; i < professions.size(); i++) {
                lMapProfessionByRank.put(String.valueOf(professions[i].valor) + String.valueOf(ocupacao.Codigo__c), i);
                lLstProfessionCodes.add(professions[i].valor);
            }
        }

       List<ParametroConsultaProfissao__c> lLstProfessions = CreateProfessionHelper.getExistingProfession(lLstProfessionCodes);
       for (ParametroConsultaProfissao__c profession : lLstProfessions) {
            Integer rank = lMapProfessionByRank.get(String.valueOf(profession.Codigo__c) + String.valueOf(profession.Ocupacao__c));
            if (rank == null) {
                continue;
            }
            
            profession.Rank__c = rank;
       }

       this.rankedProfessions.addAll(lLstProfessions);

       if (!this.rankedProfessions.isEmpty()) {
            update this.rankedProfessions;
       }
    }

    global void finish(Database.BatchableContext bc) {
       
    }
}