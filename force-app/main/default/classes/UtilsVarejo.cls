public class UtilsVarejo {
    public static Boolean validarCnpj(String cnpj){
        try {
            cnpj = cnpj.replaceAll('[^0-9]', ''); 
            if (cnpj.length() == 13) cnpj = '0'+cnpj;

            if (cnpj.length() != 14) return false;

            // VERIFICANDO SE TODOS OS DÍGITOS SÃO IGUAIS
            String itemAnterior = cnpj.Split('')[0];
            Integer cont = 0;
            for (String item: cnpj.Split('')) {
                if (item.Equals(itemAnterior)) {
                    cont++;
                }else{
                    break;
                }
                itemAnterior = item;
            }
            if (cont == 14) {
                return false;
            }


            Integer sm, i, r, num, peso, dig13, dig14;
            List<String> cnpjString = cnpj.split('');
            sm = 0;
            peso = 2;

            for (i=11; i>=0; i--) {
                num = Integer.valueOf(cnpjString[i]);
                sm = sm + (num * peso);
                peso = peso + 1;
                if (peso == 10)
                peso = 2;
            }

            r = math.mod(sm, 11);

            if ((r == 0) || (r == 1)){
                dig13 = 0;
            }else{
                dig13 = Integer.valueOf(11-r);
            } 

            // Calculo do 2º Digito Verificador
            sm = 0;
            peso = 2;
            for (i=12; i>=0; i--) {
                num = Integer.valueOf(cnpjString[i]);
                sm = sm + (num * peso);
                peso = peso + 1;
                if (peso == 10){
                    peso = 2;
                }
            }

            r = math.mod(sm, 11);

            if ((r == 0) || (r == 1)){
                dig14 = 0;
            }else{
                dig14 = Integer.valueOf(11-r);
            }

            
            // Verifica se os dígitos calculados conferem com os dígitos informados.
            if (dig13 == Integer.valueOf(cnpjString[12]) && dig14 == Integer.valueOf(cnpjString[13])){
                return true;
            }

            return false ;
       } catch (Exception error) {
            System.debug('UtilsVarejo.validarCnpj() ERROR: ' + error.getMessage());
            return false;
        }
    }


    public static Boolean validarCpf(String cpf){
        try {
            Integer[] multiplicador1 = new Integer[] {10, 9, 8, 7, 6, 5, 4, 3, 2};
            Integer[] multiplicador2 = new Integer[] {11, 10, 9, 8, 7, 6, 5, 4, 3, 2};
            cpf = cpf.replaceAll('[^0-9]', ''); 
            
            if (cpf.length() != 11){
                return false;
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
                return false;
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
            
            Boolean documentoValido = cpf.EndsWith(digito);            
            return documentoValido;
        } catch (Exception error) {
            System.debug('UtilsVarejo.validarCpf() ERROR: ' + error.getMessage());
            return false;
        }
    }
}