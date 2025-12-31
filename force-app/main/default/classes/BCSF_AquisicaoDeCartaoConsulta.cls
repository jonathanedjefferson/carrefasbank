//As respostas no output estão mapeadas para devolver o objeto inteiro de resposta
//As respostas vão precisar ser mapeadas e ajustadas de acordo com o uso dentro do fluxo pelo Bot
public class BCSF_AquisicaoDeCartaoConsulta {
    private static final String OCUPACAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Ocupacao').getRecordTypeId();
    private static final String CATEGORIA_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Categoria').getRecordTypeId();
    private static final String PROFISSAO_RECORDTYPE_ID = Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Profissao').getRecordTypeId();

    @invocableMethod(label='Gerenciar Consultas')
    public static List<OutputData> manageActions(List<InputData> lLstInputs){
        InputData input = lLstInputs.get(0);
        List<OutputData> lLstOutputData = processAction(input);

        return lLstOutputData; 
    }

    private static List<OutputData> processAction(InputData input) {
        OutputData output = new OutputData();
        BCSF_AquisicaoDeCartaoTO.responseWrapper response;
        BCSF_AquisicaoDeCartaoTO.listResponseWrapper lLstReponse;

        switch on input.actionName {
            when 'BuscarEnderecoPorCEP' {
                response = BCSF_AquisicaoDeCartao.buscarEnderecoPorCEP(input.idEmpresa, input.cep, 'Whatsapp', input.cpf);

                if (response.statusCode != 200) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                BCSF_AquisicaoDeCartaoTO.buscarEnderecoPorCEPResponseWrapper responseBody = 
                    (BCSF_AquisicaoDeCartaoTO.buscarEnderecoPorCEPResponseWrapper) response.body;
                output.statusCode = response.statusCode;
                output.message = response.message;
                output.cep = responseBody.cep;
                output.logradouro = responseBody.logradouro;
                output.bairro = responseBody.bairro;
                output.cidade = responseBody.cidade;
                output.estado = responseBody.estado;
            }
            when 'BuscarDiasDeVencimento' {
                response = BCSF_AquisicaoDeCartao.buscarDiasDeVencimento(input.idEmpresa, 'Whatsapp', input.cpf);

                if (response.statusCode != 200) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }
                
                BCSF_AquisicaoDeCartaoTO.buscarDiasDeVencimentoResponseWrapper responseBody = (BCSF_AquisicaoDeCartaoTO.buscarDiasDeVencimentoResponseWrapper) response.body;
                output.statusCode = response.statusCode;
                output.message = response.message;
                output.listDiasVencimentoLabel = new List<String>();
                String listDiasVencimentoLabelString = '';
                String listDiasVencimentoValues = '';
                
                for (BCSF_AquisicaoDeCartaoTO.Dados diasDeVencimento : responseBody.dados) {
                    output.listDiasVencimentoLabel.add(diasDeVencimento.descricao);
                    listDiasVencimentoLabelString += diasDeVencimento.descricao + ';';
                    listDiasVencimentoValues += String.valueOf(diasDeVencimento.valor) + ';';
                }
                output.listDiasVencimentoLabelString = listDiasVencimentoLabelString;
                output.listDiasVencimentoValues = listDiasVencimentoValues;
            }
            when 'BuscarValorLista' {
               output.selectedValue = getValueOnList(input.listLabels, input.listValues, input.selectedLabel);
            }
            when else {
                output.message = 'A ação com o nome ' + input.actionName + ' não existe';
                output.statusCode = 500;
            }
        }

        return new List<OutputData>{output};
    }

    private static String getValueOnList(String lLstLabelsString, String lLstValuesString, String selectedValue) {
        List<String> lLstLabels = lLstLabelsString.split(';');
        List<String> lLstValues = lLstValuesString.split(';');
        Integer index = lLstLabels.indexOf(selectedValue);

        return lLstValues.get(index) != null && index < lLstValues.size() ? lLstValues.get(index) : '';
    }


    public class InputData {
        @InvocableVariable
        public String actionName;
        @InvocableVariable
        public Integer idEmpresa;
        @InvocableVariable
        public String cpf;
        @InvocableVariable
        public Integer idOcupacao;
        @InvocableVariable
        public Integer idCategoria;
        @InvocableVariable
        public Integer pagina;
        @InvocableVariable
        public Integer quantidade;
        @InvocableVariable
        public String cep;
        @InvocableVariable
        public String listLabels;
        @InvocableVariable
        public String listValues;
        @InvocableVariable
        public String selectedLabel;
    }

    public class OutputData {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Integer statusCode;
        public String cep;
        @InvocableVariable
        public String logradouro;
        @InvocableVariable
        public String bairro;
        @InvocableVariable
        public String cidade;
        @InvocableVariable
        public String estado;
        @InvocableVariable
        public List<String> listDiasVencimentoLabel;
        @InvocableVariable
        public String listDiasVencimentoLabelString;
        @InvocableVariable
        public String listDiasVencimentoValues;
        @InvocableVariable
        public String selectedValue;
    }
}