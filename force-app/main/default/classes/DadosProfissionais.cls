public  class DadosProfissionais {
    
    private static final String OCUPACAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Ocupacao').getRecordTypeId();
    private static final String CATEGORIA_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Categoria').getRecordTypeId();
    private static final String PROFISSAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Profissao').getRecordTypeId();
    private static final Integer MAX_LENGTH_STRING_OPTION = 24;

    @InvocableMethod(label='Consulta Dados Profissionais')
    public static List<OutputData> manageActions(List<InputData> lLstInputs){
        InputData input = lLstInputs.get(0);
        List<OutputData> lLstOutputData = processAction(input);

        return lLstOutputData; 
    }

    private static List<OutputData> processAction(InputData input) {
        OutputData output = new OutputData();

        switch on input.actionName {
            when 'BuscarModelosDeContratacao' {
                List<String> lLstOcupacoes = getOcupationsLabel();
                output.listOptions = lLstOcupacoes;
            }
            when 'BuscarEmpresaOcupacao' {
                Boolean hasEmpresa = isEmpresaOcupation(input.codOcupacao);
                output.hasEmpresa = hasEmpresa;
            }
            when 'BuscarDadosSelecionados' {

                Decimal codSelecionado = -1;
                if(String.isNotBlank(input.labelProfissao)){
                    codSelecionado = getProfessionCodigo(input.labelProfissao, input.codOcupacao);
                } else if(String.isNotBlank(input.labelCategoria)){
                    codSelecionado = getCategoryCodigo(input.labelCategoria, input.codOcupacao);
                } else if(String.isNotBlank(input.labelOcupacao)){
                    codSelecionado = getOcupationCodigo(input.labelOcupacao);
                }
                output.codSelecionado = codSelecionado;
            }
            when 'BuscarProfissaoPrincipais' {
                List<String> lLstRankedProfessionsId = getRankedProfessions(input.codOcupacao);
                output.listOptions = lLstRankedProfessionsId;
            }
            when 'BuscarCategorias' {
                Map<String, Object> lMapCategoryData = getCategories(input.pagina, input.quantidade, input.codOcupacao);
                List<String> listOptions = (List<String>) lMapCategoryData.get('queryResult');

                Boolean hasNextPage = (Integer) lMapCategoryData.get('queryCount') > (input.pagina + 1) * input.quantidade;
                output.nextPageNumber = hasNextPage ? input.pagina + 1 : 0;
                if(hasNextPage){
                    listOptions.add('Mais opções');
                    listOptions.add('Voltar');
                } else {
                    listOptions.add('Voltar a lista inicial');
                }
                
                output.listOptions = listOptions;
            }
            when 'BuscarProfissaoCategoria' {
                Map<String, Object> lMapProfessionData = getProfessionByCategory(input.pagina, input.quantidade, input.codOcupacao, input.codCategoria);
                List<String> listOptions = (List<String>) lMapProfessionData.get('queryResult');

                Boolean hasNextPage = (Integer) lMapProfessionData.get('queryCount') > (input.pagina + 1) * input.quantidade;
                output.nextPageNumber = hasNextPage ? input.pagina + 1 : 0;
                if(hasNextPage){
                    listOptions.add('Mais opções');
                }
                listOptions.add('Voltar');
                output.listOptions = listOptions;
            }
        }

        return new List<OutputData>{output};
    }

    private static List<String> getOcupationsLabel() {
        List<String> result = new List<String>();
        List<ParametroConsultaProfissao__c> lLstOcupation = [SELECT Name, PossuiEmpresa__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :OCUPACAO_RECORDTYPE_ID];

        for (ParametroConsultaProfissao__c ocupacao : lLstOcupation) {
            result.add(ocupacao.Name);
        }

        return result;
    }

    private static Map<String, Object> getCategories(Integer page, Integer quantity, Decimal codOcupacao) {
        Map<String, Object> response = new Map<String, Object>();
        List<String> lLstCategoriesName = new List<String>();

        Integer offSet = page * quantity;
        String query = 'SELECT Name FROM ParametroConsultaProfissao__c ';
        String countQuery = 'SELECT count() FROM ParametroConsultaProfissao__c ';
        String whereClause = 'WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID AND Ocupacao__c =: codOcupacao LIMIT: quantity OFFSET: offSet';
        String whereClauseCountQuery = 'WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID AND Ocupacao__c =: codOcupacao';

        List<ParametroConsultaProfissao__c> lLstCategories = Database.query(query + whereClause);

        for (ParametroConsultaProfissao__c category : lLstCategories) {
            lLstCategoriesName.add(category.Name);
        }

        response.put('queryResult', lLstCategoriesName);
        response.put('queryCount', Database.countQuery(countQuery + whereClauseCountQuery));

        return response;
    }

    private static List<String> getRankedProfessions(Decimal codOcupacao) {
        List<String> result = new List<String>();

        if(codOcupacao != null){
            List<ParametroConsultaProfissao__c> lLstProfessions = [SELECT Id, Codigo__c, Name, Rank__c 
                FROM ParametroConsultaProfissao__c
                WHERE RecordTypeId = :PROFISSAO_RECORDTYPE_ID  AND Ocupacao__c =: codOcupacao 
                ORDER BY Rank__c DESC NULLS LAST
                LIMIT 7];

            for (ParametroConsultaProfissao__c profession : lLstProfessions) {

                profession.Name = profession.Name;
                if(profession.Name.length() > MAX_LENGTH_STRING_OPTION){
                    result.add(profession.Name.substring(0, MAX_LENGTH_STRING_OPTION));
                } else {
                    result.add(profession.Name);
                }
            }

            Integer countCategories = [SELECT count() FROM ParametroConsultaProfissao__c 
                WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID AND Ocupacao__c =: codOcupacao];
            if(countCategories > 1){
                result.add('Escolher por categoria');
            }
            
            result.add('Voltar');
        }

        return result;
    }

    private static Map<String, Object> getProfessionByCategory(Integer page, Integer quantity, Decimal ocupationId, Decimal categoryId ) {
        Map<String, Object> response = new Map<String, Object>();

        List<String> lLstProfessionsName = new List<String>();
        Integer offSet = page * quantity;
        String query = 'SELECT Name FROM ParametroConsultaProfissao__c ';
        String countQuery = 'SELECT count() FROM ParametroConsultaProfissao__c ';
        String whereClause = 'WHERE RecordTypeId = :PROFISSAO_RECORDTYPE_ID AND Ocupacao__c =: ocupationId AND Categoria__c =: categoryId ' + 
            'LIMIT: quantity OFFSET: offSet';
        String whereClauseCountQuery = 'WHERE RecordTypeId = :PROFISSAO_RECORDTYPE_ID AND Ocupacao__c =: ocupationId AND Categoria__c =: categoryId';

        List<ParametroConsultaProfissao__c> lLstProfessions = Database.query(query + whereClause);

        for (ParametroConsultaProfissao__c profession : lLstProfessions) {
            lLstProfessionsName.add(profession.Name);
        }

        response.put('queryResult', lLstProfessionsName);
        response.put('queryCount', Database.countQuery(countQuery + whereClauseCountQuery));

        return response;
    }

    private static Decimal getOcupationCodigo(String labelOcupacao){
        List<ParametroConsultaProfissao__c> lListOcupactions = [SELECT Codigo__c FROM ParametroConsultaProfissao__c 
            WHERE Name =: labelOcupacao AND RecordTypeId = :OCUPACAO_RECORDTYPE_ID LIMIT 1];
        if(lListOcupactions.size() > 0){
            return lListOcupactions.get(0).Codigo__c;
        } else {
            return -1;
        }
    }

    private static Boolean isEmpresaOcupation(Decimal codOcupacao){
        List<ParametroConsultaProfissao__c> lListOcupactions = [SELECT PossuiEmpresa__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :OCUPACAO_RECORDTYPE_ID AND Codigo__c =: codOcupacao LIMIT 1];
        if(lListOcupactions.size() > 0){
            return lListOcupactions.get(0).PossuiEmpresa__c;
        } else {
            return false;
        }
    }

    private static Decimal getCategoryCodigo(String labelCategoria, Decimal codOcupacao){
        List<ParametroConsultaProfissao__c> lListCategories = [SELECT Codigo__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :CATEGORIA_RECORDTYPE_ID AND Name =: labelCategoria AND Ocupacao__c =: codOcupacao LIMIT 1];
        if(lListCategories.size() > 0){
            return lListCategories.get(0).Codigo__c;
        } else {
            return -1;
        }
    }
    private static Decimal getProfessionCodigo(String labelProfissao, Decimal codOcupacao){
        List<ParametroConsultaProfissao__c> lListCategories = [SELECT Codigo__c FROM ParametroConsultaProfissao__c 
            WHERE RecordTypeId = :PROFISSAO_RECORDTYPE_ID AND Name =: labelProfissao AND Ocupacao__c =: codOcupacao LIMIT 1];
        if(lListCategories.size() > 0){
            return lListCategories.get(0).Codigo__c;
        } else {
            return -1;
        }
    }


    public class InputData {
        @InvocableVariable
        public String actionName;
        @InvocableVariable
        public String labelOcupacao;
        @InvocableVariable
        public String labelCategoria;
        @InvocableVariable
        public String labelProfissao;
        @InvocableVariable
        public Decimal codOcupacao;
        @InvocableVariable
        public Decimal codCategoria;
        @InvocableVariable
        public Integer pagina;
        @InvocableVariable
        public Integer quantidade;
    }

    public class OutputData {
        @InvocableVariable
        public List<String> listOptions;
        @InvocableVariable
        public Boolean hasEmpresa;
        @InvocableVariable
        public Integer nextPageNumber;
        @InvocableVariable
        public Decimal codSelecionado;
    }
}