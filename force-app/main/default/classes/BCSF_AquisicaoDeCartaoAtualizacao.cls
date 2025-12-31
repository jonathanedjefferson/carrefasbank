public class BCSF_AquisicaoDeCartaoAtualizacao {
    @invocableMethod(label='Gerenciar Atualizações')
    public static List<OutputData> manageActions(List<InputData> lLstInputs){
        InputData input = lLstInputs.get(0);
        List<OutputData> lLstOutputData = processAction(input);

        return lLstOutputData; 
    }

    private static List<OutputData> processAction(InputData input) {
        OutputData output = new OutputData();
        BCSF_AquisicaoDeCartaoTO.responseWrapper response;

        switch on input.actionName {
            when 'AtualizarDadosDeContato' { //204
                response = BCSF_AquisicaoDeCartao.atualizarDadosContato(input.idProposta, input.idEmpresa, 
                    input.optinWhatsapp, input.email, 'Whatsapp', input.cpf);
                
                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when 'AtualizarDadosPessoais' { //204

                Boolean pep = input.pep == 'S' ? true : false;
                String genero = input.genero == 'Masculino' ? 'M' : 'F';
                String dataNascimento = input.dataNascimento;
                if(String.isNotBlank(dataNascimento)){
                    dataNascimento = Util.formatYYYYMMDD(dataNascimento, '/', '-');
                }

                response = BCSF_AquisicaoDeCartao.atualizarDadosPessoais(input.nome, genero, dataNascimento,
                    input.nomeMae, pep, input.idProposta, input.idEmpresa, 'Whatsapp', input.cpf);

                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when 'AtualizarDadosProfissionais' { //204
                response = BCSF_AquisicaoDeCartao.atualizarDadosProfissionais(input.idProfissao, input.idOcupacao, input.cnpjEmpresa,
                    input.idProposta, input.idEmpresa, 'Whatsapp', input.cpf);

                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when 'AtualizarDadosDeEndereco' { //204
                response = BCSF_AquisicaoDeCartao.atualizarDadosDeEndereco(input.cep, input.logradouro, input.bairro, input.cidade,
                    input.estado, input.numero, input.complemento, input.idEmpresa, input.idProposta, 'Whatsapp', input.cpf);

                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }
                
                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when else {
                output.message = 'A ação com o nome ' + input.actionName + ' não existe';
                output.statusCode = 500;
            }
        }

        return new List<OutputData>{output};
    }

    public class InputData {
        @InvocableVariable
        public String actionName;
        @InvocableVariable
        public Integer idEmpresa;
        @InvocableVariable
        public String idProposta;
        @InvocableVariable
        public String cpf;
        @InvocableVariable
        public Boolean optinWhatsapp;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String nome;
        @InvocableVariable
        public String genero;
        @InvocableVariable
        public String dataNascimento;
        @InvocableVariable
        public String nomeMae;
        @InvocableVariable
        public String pep;
        @InvocableVariable
        public Decimal idOcupacao;
        @InvocableVariable
        public Decimal idProfissao;
        @InvocableVariable
        public String cnpjEmpresa;
        @InvocableVariable
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
        public String numero;
        @InvocableVariable
        public String complemento;
    }

    public class OutputData {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Integer statusCode;
    }
}