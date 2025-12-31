public class CpfValidation {
    @invocableMethod(label='Validar CPF')
    public static List<OutputValidacao> BotValidaCpf(List<String> cpf){
        List<OutputValidacao> listRetorno = new List<OutputValidacao>();
        for (String item: cpf) {
            listRetorno.add(ValidarCpf(item));
        }
        return listRetorno;
    }

    public static OutputValidacao ValidarCpf(String cpf){
        OutputValidacao retorno = new OutputValidacao();
        try {
            Integer[] multiplicador1 = new Integer[] {10, 9, 8, 7, 6, 5, 4, 3, 2};
            Integer[] multiplicador2 = new Integer[] {11, 10, 9, 8, 7, 6, 5, 4, 3, 2};
            cpf = cpf.Replace('.', '').Replace('-', '').Replace(' ', '');
            
            
            if (cpf.length() != 11){
                retorno.cpfValido = false;
                return retorno;
            }

            // VERIFICANDO SE TODOS OS DÍGITOS SÃO IGUAIS
            String itemAnterior = cpf.Split('')[0];
            Integer cont = 0;
            for (String item: cpf.Split('')) {
                if (item.Equals(itemAnterior)) {
                    cont++;
                }else{
                    break;
                }
                itemAnterior = item;
            }
            if (cont == 11) {
                retorno.cpfValido = false;
                return retorno;
            }
            
            // ############################## VALIDAÇÃO DO PRIMEIRO DIGITO ##############################
            // 1º PASSO: Multiplica-se os 9 primeiros dígitos pela sequência decrescente de números de 10 à 2 e soma os resultados.
            // 2º PASSO: Basta multiplicarmos esse resultado por 10 e dividirmos por 11.
            // O resultado que nos interessa na verdade é o RESTO da divisão. Se ele for igual ao primeiro dígito verificador (primeiro dígito depois do '-'), a primeira parte da validação está correta.
            // Se o resto da divisão for igual a 10, nós o consideramos como 0.

            String cpf09 = cpf.Substring(0, 9);
            List<String> tempCpf = cpf09.split('');
            Integer soma = 0;
            for (Integer i = 0; i < 9; i++){
                soma += Integer.ValueOf(tempCpf[i]) * multiplicador1[i];
            }
            
            Integer resto = Math.Mod(soma, 11);
            if (resto < 2){
                resto = 0;
            }else{
                resto = 11 - resto;
            }
            String digito = String.ValueOf(resto);
            
            
            // ############################## VALIDAÇÃO DO SEGUNDO DÍGITO ##############################
            // 1º PASSO: vamos considerar os 9 primeiros dígitos, mais o primeiro dígito verificador, e vamos multiplicar esses 10 números pela sequencia decrescente de 11 a 2
            // 2º PASSO: Seguindo o mesmo processo da primeira verificação, multiplicamos por 10 e dividimos por 11
            // O resultado que nos interessa na verdade é o RESTO da divisão. Se ele for igual ao segundo dígito verificador (primeiro dígito depois do '-'), a segunda parte da validação está correta.
            
            cpf09 = cpf09 + digito;
            tempCpf = cpf09.split('');
            
            soma = 0;
            for (Integer i = 0; i < 10; i++)
                soma += Integer.ValueOf(tempCpf[i]) * multiplicador2[i];
            
            resto = Math.Mod(soma, 11);
            if (resto < 2){
                resto = 0;
            }else{
                resto = 11 - resto;
            }
            digito = digito + String.ValueOf(resto);
            
            retorno.cpfValido = cpf.EndsWith(digito);
            retorno.cpfFormatado = retorno.cpfValido ? cpf : null;
            
            return retorno;
        } catch (Exception error) {
            System.debug('CpfValidation.ValidarCpf() ERROR: ' + error.getMessage());
            retorno.cpfValido = false;
            return retorno;
        }
    }

    public class OutputValidacao{
        @InvocableVariable
        public String cpfFormatado;
        @InvocableVariable
        public Boolean cpfValido;
    }
}