public class BCSF_AquisicaoDeCartaoValidacao {
    @invocableMethod(label='Gerenciar Validações')
    public static List<OutputData> manageActions(List<InputData> lLstInputs){
        InputData input = lLstInputs.get(0);
        List<OutputData> lLstOutputData = processAction(input);

        return lLstOutputData; 
    }

    private static List<OutputData> processAction(InputData input) {
        OutputData output = new OutputData();

        switch on input.actionName {
            when 'ValidarEmail' {
                if (String.isBlank(input.email)) {
                    output.message = 'O campo Email não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String emailRegex = '(?i)^[A-Z0-9._%+-]+@[A-Z0-9.-]+(\\.[A-Z]{2,})+$';
                output.valido = Pattern.compile(emailRegex).matcher(input.email).matches();
            }
            when 'ValidarNome' {
               if (String.isBlank(input.nome)) {
                    output.message = 'O campo Nome não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String normalizedText = input.nome.trim().replaceAll('\\s+', ' ');
                List<String> inputList = normalizedText.split(' ');

                output.valido = inputList.size() >= 2;
                for(String parteNome : inputList){
                    if(parteNome.length() < 2){
                        output.valido = false;
                        break;
                    }
                }
            }
            when 'ValidarNomeMae' {
                if (String.isBlank(input.nomeMae)) {
                     output.message = 'O campo Nome não foi atribuido corretamente';
                     output.valido = false;
                     return new List<OutputData>{output};
                 }
 
                 String normalizedText = input.nomeMae.trim().replaceAll('\\s+', ' ');
                 List<String> inputList = normalizedText.split(' ');
 
                 output.valido = inputList.size() >= 2;
             }
            when 'ValidarData' {
                if (String.isBlank(input.data)) {
                    output.message = 'O campo Data não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String dateText = input.data.trim();
                Pattern datePattern = Pattern.compile('^\\d{2}/\\d{2}/\\d{4}$');
                Matcher matcher = datePattern.matcher(dateText);
                
                output.valido = matcher.matches();
            }
            when 'ValidarCEP' {
                if (String.isBlank(input.CEP)) {
                    output.message = 'O campo CEP não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String cleanCep = input.CEP.replaceAll('\\D', '');

                if (cleanCep.length() != 8) {
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                output.valido = Pattern.matches('^[0-9]{8}$', cleanCep);
            }
            when 'ValidarNumero' {
                if (String.isBlank(input.numeroEndereco)) {
                    output.message = 'O campo Número não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String cleanNumero = input.numeroEndereco.replaceAll('\\D', '');
                output.valido = Pattern.matches('^[0-9]+$', cleanNumero);
            }
            when 'ValidarEndereco' {
                if (String.isBlank(input.endereco)) {
                    output.message = 'O campo Endereço não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String normalizedText = input.endereco.trim().replaceAll('\\s+', ' ');
                List<String> inputList = normalizedText.split(' ');

                output.valido = inputList.size() >= 2;
            }
            when 'ValidarComplemento' {
                if (String.isBlank(input.complemento)) {
                    output.message = 'O campo Complemento não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String normalizedText = input.complemento.trim().replaceAll('\\s+', ' ');
                output.valido = !String.isBlank(normalizedText);
            }
            when 'ValidarCidade' {
                if (String.isBlank(input.cidade)) {
                    output.message = 'O campo Cidade não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String normalizedText = input.cidade.trim().replaceAll('\\s+', ' ');
                output.valido = !String.isBlank(normalizedText);
            }
            when 'ValidarBairro' {
                if (String.isBlank(input.bairro)) {
                    output.message = 'O campo Bairro não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                String normalizedText = input.bairro.trim().replaceAll('\\s+', ' ');
                output.valido = !String.isBlank(normalizedText);
            }
            when 'ValidarCNPJ' {
                if (String.isBlank(input.cnpjEmpresa)) {
                    output.message = 'O campo CNPJ não foi atribuido corretamente';
                    output.valido = false;
                    return new List<OutputData>{output};
                }

                // TODO: validar CNPJ
                output.valido = true;
            }
            when else {
                output.message = 'A ação com o nome ' + input.actionName + ' não existe';
                output.valido = false;
            }
        }

        return new List<OutputData>{output};
    }

    public class InputData {
        @InvocableVariable
        public String actionName;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String nome;
        @InvocableVariable
        public String nomeMae;
        @InvocableVariable
        public String data;
        @InvocableVariable
        public String CEP;
        @InvocableVariable
        public String endereco;
        @InvocableVariable
        public String numeroEndereco;
        @InvocableVariable
        public String complemento;
        @InvocableVariable
        public String bairro;
        @InvocableVariable
        public String cidade;
        @InvocableVariable
        public String cnpjEmpresa;
    }

    public class OutputData {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean valido;
    }
}