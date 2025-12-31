public class CreateProfessionHelper {

    private static final String OCUPACAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Ocupacao').getRecordTypeId();
    private static final String CATEGORIA_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Categoria').getRecordTypeId();
    private static final String PROFISSAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Profissao').getRecordTypeId();
   
    public static List<ParametroConsultaProfissao__c> getExistingOcupation() {
        List<ParametroConsultaProfissao__c> lLstOcupation = [SELECT Id, Codigo__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :OCUPACAO_RECORDTYPE_ID AND Deletar__c = false];

        return lLstOcupation.isEmpty() ? new List<ParametroConsultaProfissao__c>() : lLstOcupation;
    }

    public static List<ParametroConsultaProfissao__c> getCategoriesByOcupation(Integer ocupationId) {
        List<ParametroConsultaProfissao__c> lLstCategories = [SELECT Id, Codigo__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID AND Ocupacao__c =: ocupationId];

        return lLstCategories.isEmpty() ? new List<ParametroConsultaProfissao__c>() : lLstCategories;
    }

    public static List<ParametroConsultaProfissao__c> getAllCategories() {
        List<ParametroConsultaProfissao__c> lLstCategories = [SELECT Id, Codigo__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID AND Deletar__c = false];

        return lLstCategories.isEmpty() ? new List<ParametroConsultaProfissao__c>() : lLstCategories;
    }

    public static List<ParametroConsultaProfissao__c> getExistingProfession(List<Integer> lLstCodes) {
        List<ParametroConsultaProfissao__c> lLstProfessions = [SELECT Id, Codigo__c, Ocupacao__c FROM ParametroConsultaProfissao__c 
            WHERE Codigo__c IN: lLstCodes AND RecordTypeId = :PROFISSAO_RECORDTYPE_ID];

        return lLstProfessions.isEmpty() ? new List<ParametroConsultaProfissao__c>() : lLstProfessions;
    }

    public static List<ParametroConsultaProfissao__c> gerProfessionByOcupation(Integer ocupationId) {
        List<ParametroConsultaProfissao__c> lLstProfessions = [SELECT Id, Codigo__c, Ocupacao__c FROM ParametroConsultaProfissao__c 
            WHERE Ocupacao__c =: ocupationId AND RecordTypeId = :PROFISSAO_RECORDTYPE_ID AND Deletar__c = false];

        return lLstProfessions.isEmpty() ? new List<ParametroConsultaProfissao__c>() : lLstProfessions;
    }

    public static void createNewOcupations(List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper> lLstOcupationAPI) {
        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();

        for (BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper occupation : lLstOcupationAPI) {
            lLstParams.add(new ParametroConsultaProfissao__c (
                Name = occupation.descricao,
                Codigo__c = occupation.valor,
                PossuiEmpresa__c = occupation.possuiEmpresa,
                RecordTypeId = OCUPACAO_RECORDTYPE_ID
            ));
        }

        If (!lLstParams.isEmpty()) {
            insert lLstParams;
        }
    }

    public static void createConstantValues() {
        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();

        lLstParams.add(new ParametroConsultaProfissao__c (
            Name = 'Mais Opções',
            Codigo__c = -1,
            RecordTypeId = CATEGORIA_RECORDTYPE_ID
        ));

        lLstParams.add(new ParametroConsultaProfissao__c (
            Name = 'Voltar',
            Codigo__c = -2,
            RecordTypeId = CATEGORIA_RECORDTYPE_ID
        ));

        If (!lLstParams.isEmpty()) {
            insert lLstParams;
        }
    }

    public static void createNewCategories(List<BCSF_AquisicaoDeCartaoTO.Dados> categories, Integer ocupationCode) {
        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();

        for (BCSF_AquisicaoDeCartaoTO.Dados category : categories) {
            lLstParams.add(new ParametroConsultaProfissao__c (
                Name = category.descricao,
                Codigo__c = category.valor,
                Ocupacao__c = ocupationCode,
                RecordTypeId = CATEGORIA_RECORDTYPE_ID
            ));
        }

        If (!lLstParams.isEmpty()) {
            insert lLstParams;
        }
    }

    public static List<ParametroConsultaProfissao__c> createNewProfessions(List<BCSF_AquisicaoDeCartaoTO.Dados> professions, 
        Integer ocupationId, Integer categoryId) {

        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();

        for (BCSF_AquisicaoDeCartaoTO.Dados profession : professions) {
            lLstParams.add(new ParametroConsultaProfissao__c (
                Name = profession.descricao,
                Codigo__c = profession.valor,
                Ocupacao__c = ocupationId,
                Categoria__c = categoryId,
                RecordTypeId = PROFISSAO_RECORDTYPE_ID
            ));
        }

        return lLstParams;
    }

    public static void setParamsToDelete(List<ParametroConsultaProfissao__c> lLstParamsToDelete) {
        if (lLstParamsToDelete.isEmpty()) {
            return ;
        }

        for (ParametroConsultaProfissao__c param : lLstParamsToDelete) {
            param.Deletar__c = true;
        }

        update lLstParamsToDelete;
    }

    public static void deletePreviousRecords(String recordTypeName) {
        String recordTypeId = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        List<ParametroConsultaProfissao__c> lLstRecordsToDelete = [SELECT Id FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId =: recordTypeId AND Deletar__c = true];

        delete lLstRecordsToDelete;
    }
}