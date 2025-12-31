public class ObterEnderecoCliente {
    @invocableMethod(label='Obter endereço cliente')
    public static List<OutputValores> ObterEnderecoCliente(List<InputValores> inputs){

        ContaFinanceira__c contaCliente = null;
        for (InputValores requestInput: inputs) {
            contaCliente = ContaFinanceiraDAO.getInstance().getDadosEndereco(requestInput.numeroConta);
        }

        StringBuilder endereco = new StringBuilder('');
        if(contaCliente != null && String.isNotBlank(contaCliente.CEP__c)){

            String logradouro =  contaCliente.Rua__c + ' ' + contaCliente.Numero__c;
            if(String.isNotBlank(contaCliente.Complemento__c)){
                logradouro += ' ' + contaCliente.Complemento__c;
            }

            String bairro =  contaCliente.Bairro__c;
            String cidade =  contaCliente.Cidade__c;
            String estado =  contaCliente.Estado__c;
            String cep =  contaCliente.CEP__c;
            Integer length = 0;
            Integer characterCode;
            String currentCharacter;

            if (String.isNotBlank(logradouro)) {
                String[] dadosLogradouro = logradouro.split(' ');
                for (String dado : dadosLogradouro) {
                    if (String.isNotBlank(dado)) {
                        length = dado.length();
                        endereco.add(' ');

                        characterCode = dado.charAt(0);
                        currentCharacter = String.fromCharArray(new Integer[]{ characterCode });
                        endereco.add(currentCharacter);

                        for (Integer i = 0; i < length - 1; i++) {
                            endereco.add('•');
                        }
                    }
                }
            }

            if (String.isNotBlank(bairro)) {
                String[] dadosBairro = bairro.split(' ');
                endereco.add(' -');
                for (String dado : dadosBairro) {
                    if (String.isNotBlank(dado)) {
                        length = dado.length();
                        endereco.add(' ');

                        characterCode = dado.charAt(0);
                        currentCharacter = String.fromCharArray(new Integer[]{ characterCode });
                        endereco.add(currentCharacter);
                        for (Integer i = 0; i < length - 1; i++) {
                            endereco.add('•');
                        }
                    }
                }

                String enderecoCliente = endereco.getStringValue();
                // retira o último •
                enderecoCliente = enderecoCliente.substring(0, enderecoCliente.length() - 1);

                // Adiciona a última letra da última palavra do bairro
                String ultimaParteBairro = dadosBairro[dadosBairro.size() - 1];

                characterCode = ultimaParteBairro.charAt(ultimaParteBairro.length() - 1);
                currentCharacter = String.fromCharArray(new Integer[]{ characterCode });

                endereco = new StringBuilder(enderecoCliente);
                endereco.add(currentCharacter);
            }

            if (String.isNotBlank(cep)) {
                cep = cep.replaceAll('[^0-9.]', '');
                cep = cep.leftPad(8, '0');
                endereco.add(' •••••-');
                endereco.add(cep.substring(5));
            }

            if (String.isNotBlank(cidade)) {
                endereco.add(' - ');
                endereco.add(cidade);
            }

            if (String.isNotBlank(estado)) {
                endereco.add(' - ');
                endereco.add(estado);
            }
        }

        List<OutputValores> listRetorno = new List<OutputValores>();
        OutputValores objRetorno = new OutputValores();
        String enderecoCliente = endereco.getStringValue();
        if(String.isBlank(enderecoCliente)){
            enderecoCliente = ' ';
        } else {
            enderecoCliente = enderecoCliente.substring(1);
        }
        objRetorno.endereco = enderecoCliente;

        listRetorno.add(objRetorno);
        return listRetorno;
    }

    public class InputValores{
        @InvocableVariable(label='Número da conta' required = true)
        public String numeroConta;
    }

    public class OutputValores{
        @InvocableVariable(label='Endereço cliente')
        public String endereco;
    }

}