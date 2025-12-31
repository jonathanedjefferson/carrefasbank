public class Util {
    public static HttpResponse executarHttpRequest(String strEndPoint, String strMethod, Map<String, String> mapHeaders, String strBody, Integer intTimeout){
        System.debug('HEADERS: '+ mapHeaders);
        
        HttpRequest objHttpRequest = new HttpRequest();

        objHttpRequest.setEndpoint(strEndPoint);
        objHttpRequest.setMethod(strMethod);
        objHttpRequest.setTimeout(intTimeout);

        //Gera body = '' apenas para o método POST
        if(strMethod == 'POST' || strMethod == 'PUT')
            objHttpRequest.setBody(strBody != null ? strBody : '');
        else if(String.isNotBlank(strBody))
            objHttpRequest.setBody(strBody);

        for(String strHeaderKey : mapHeaders.keySet()){
            objHttpRequest.setHeader(strHeaderKey, mapHeaders.get(strHeaderKey));
        }

        return new Http().send(objHttpRequest);
    }

    public static Boolean validaCelular(String numeroCelular, IdentificaClienteTO.TelefoneTO phone){
        String numeroPhoneComDDD = phone.ddd + phone.numero;
        
        return (numeroCelular == phone.numero || numeroCelular == numeroPhoneComDDD);
    }

    public static String formataNumeroCelular(String numeroCelular){
        Integer ddd = 2;
        Integer numeroSemDigitoNove = 8;
        Integer numeroComDDD = ddd + numeroSemDigitoNove;

        if(numeroCelular.length() == numeroComDDD) return addNoveNoMeio(numeroCelular);

        if(numeroCelular.length() == numeroSemDigitoNove) return addNoveNoInicio(numeroCelular);

        return numeroCelular;
    }

    private static String addNoveNoMeio(String numeroComDDD){
        String ddd = numeroComDDD.substring(0,2);
        String numeroSemDDD = numeroComDDD.substring(2);

        return ddd + addNoveNoInicio(numeroSemDDD);
    }

    private static String addNoveNoInicio(String numeroSemDDD){
        return '9' + numeroSemDDD;
    }
    
    public static String mascararEmail(String email){
        String emailMascarado = '';
        
        if(String.isNotBlank(email)){
            String[] emailSplit = email.split('@');
            String[] listCaracteres = emailSplit[0].split('');
    
            Integer cont = 1;
    
            for (String caracter: listCaracteres) {
                if (cont > 3) {
                    emailMascarado += '*';
                }else{
                    emailMascarado += caracter;
                }
                cont++;
            }
    
            emailMascarado += '@' + emailSplit[1];
        }
        
        return emailMascarado;
    }

    public static String mascararTelefone(String numeroTelefone){
        String telefoneMascarado = '';
        
        if(String.isNotBlank(numeroTelefone) && numeroTelefone.length() >= 4){
            telefoneMascarado = '(**) *****-';
            String finalTelefone = numeroTelefone.substring(numeroTelefone.length() - 4, numeroTelefone.length());
            telefoneMascarado += finalTelefone;
        }
        
        return telefoneMascarado;
    }

    public static String formatDDMM(Integer day, Integer month, String delimiter){
        String dayString = '' + day;
        String monthString = '' + month;
        String toReturn = dayString.leftPad(2, '0') + delimiter + monthString.leftPad(2, '0');
        return toReturn;
    }
    
    public static String formatYYYYMMDD(String data, String delimiter, String toDelimiter){
    
        String toReturn = '';
        if(String.isNotBlank(data)){
            String[] dataSplit = data.trim().split(delimiter);
            if(dataSplit.size() == 3){
                toReturn = dataSplit[2] + toDelimiter + dataSplit[1] + toDelimiter + dataSplit[0];
            }
        }
        
        return toReturn;
    }

    public static String formatMMDD(String data, String delimiter, String toDelimiter){
    
        String toReturn = '';
        if(String.isNotBlank(data)){
            String[] dataSplit = data.trim().split(delimiter);
            if(dataSplit.size() == 3){
                toReturn = dataSplit[2] + toDelimiter + dataSplit[1];
            }
        }
        
        return toReturn;
    }

    public static String formatYYYYMMDD(Date data, String delimiter){
        String dia = data.day()<10?'0'+data.day():String.valueOf(data.day());
        String mes = data.month()<10?'0'+data.month():String.valueOf(data.month());
        String ano = String.valueOf(data.year());
        String dataFormatada = ano + delimiter + mes + delimiter + dia;
        return dataFormatada;
    }

    public static String formatCelular(String numeroCelular){

        if(String.isBlank(numeroCelular)){
            return '--';
        }

        // remoção 55
        if(numeroCelular.startsWith('55')){
            numeroCelular = numeroCelular.substring(2);
        }

        String dddCelular = '';
        if(numeroCelular.length() == 10 || numeroCelular.length() == 11) {
            // ddd + número com/sem nono dígito
            dddCelular = '(' + numeroCelular.substring(0, 2) + ') ';
            numeroCelular = numeroCelular.substring(2);
        }
        
        String numeroPre = numeroCelular.substring(0 , numeroCelular.length() - 4); //9900-8899
        String numeroPos = numeroCelular.substring(numeroCelular.length() - 4);
        String numeroFormatado = dddCelular + numeroPre + '-' + numeroPos;

        return numeroFormatado;
    }

    public static String formatCEP(String cep){
        if(String.isNotBlank(cep) && cep.length() == 8){
            String pre = cep.substring(0, cep.length() - 3);
            String pos = cep.substring(cep.length() - 3);
            cep = pre.leftPad(5, '0') + '-' + pos;
        }
        return cep;
    }
    
    public static Date stringToDate(String data, String delimiter){
    
        Date toReturn = null;
        if(String.isNotBlank(data)){
            String[] dataSplit = data.trim().split(delimiter);
            if(dataSplit.size() == 3 && dataSplit[0].isNumeric()
                && dataSplit[1].isNumeric() && dataSplit[2].isNumeric()){
                toReturn = Date.newInstance(Integer.valueOf(dataSplit[2]), Integer.valueOf(dataSplit[1]), Integer.valueOf(dataSplit[0]));
            }
        }
        
        return toReturn;
    }
    
    public static String getDateAcordo(Integer days){
        Date today = Date.today();
        Date start =  today.addDays(days);
        Integer day = start.day();
        Integer month = start.month();
        String toReturn =  String.valueOf(day).leftPad(2, '0')  + '/' + String.valueOf(month).leftPad(2, '0')  + '/' + start.year();        
        return toReturn;
    }
    
    public static boolean isValidDateAcordo(Integer dayStart, Integer dayEnd, String dataAcordo){
        Date today = Date.today();
        Date dateStart =  today.addDays(dayStart);
        Date dateEnd =  today.addDays(dayEnd);
        Date dateAcordo = Util.stringToDate(dataAcordo, '/');
        
        boolean toReturn = dateStart <= dateAcordo &&  dateAcordo <= dateEnd;
        return toReturn;
    }

    public static String formatarCPF(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna o CPF original se não tiver 11 dígitos
        }
        String retorno = cpf.substring(0, 3) + '.' + cpf.substring(3, 6) + '.' + cpf.substring(6, 9) + '-' + cpf.substring(9, 11);
        return retorno;
    }

    public static String formatRG(String rg) {
        String formattedRG = '';
        if (rg != null) {
            // Remove qualquer caractere que não seja um dígito
            String cleaned = rg.replaceAll('\\D', '');
            
            if (cleaned.length() != 9) {
                return rg; // Retorna o RG original se não tiver 9 dígitos
            }
            
            // Formata o RG conforme o padrão XX.XXX.XXX-X
            formattedRG = cleaned.substring(0, 2) + '.' + cleaned.substring(2, 5) + '.' + cleaned.substring(5, 8) + '-' + cleaned.substring(8);
        }
        return formattedRG;
    }

    public static String formatarData(Date data){
        String dia = data.day()<10?'0'+data.day():String.valueOf(data.day());
        String mes = data.month()<10?'0'+data.month():String.valueOf(data.month());
        String ano = String.valueOf(data.year());
        String dataFormatada = dia+'/'+mes+'/'+ano;
        return dataFormatada;
    }

    public static String obterDDDTelefone(String telefone){
        String telefoneLimpo = telefone.replaceAll('[^0-9]', '');
        String ddd;
        if(telefone.length() >= 13){
            // com código do país  + DDD 2 dígitos + Número de telefone 9 diígitos
            ddd = telefoneLimpo.substring(telefoneLimpo.length() - 11, telefoneLimpo.length() - 9);
        } else if(telefone.length() >= 12){
            // com código do país de 2  + DDD 2 dígitos + Número de telefone 8 diígitos
            ddd = telefoneLimpo.substring(telefoneLimpo.length() - 10, telefoneLimpo.length() - 8);
        }else if(telefoneLimpo.length() >= 10){
            // DDD + Número de telefone
            ddd = telefoneLimpo.substring(0, 2);
        }
        return ddd;
    }
    public static String obterNumeroTelefone(String telefone){
        String telefoneLimpo = telefone.replaceAll('[^0-9]', '');
        String numeroTelefone;
        if(telefone.length() >= 13){
            // com código do país  + DDD 2 dígitos + Número de telefone 9 diígitos
            numeroTelefone  = telefoneLimpo.substring(telefoneLimpo.length() - 9);
        } else if(telefone.length() >= 12){
            // com código do país de 2  + DDD 2 dígitos + Número de telefone 8 diígitos
            numeroTelefone  = telefoneLimpo.substring(telefoneLimpo.length() - 8);
        }else if(telefoneLimpo.length() >= 10){
            // DDD + Número de telefone
            numeroTelefone = telefoneLimpo.substring(2);
        } else{
            // Sem ddd
            numeroTelefone = telefoneLimpo;
        }
        return numeroTelefone;
    }       

    public static String formatDateString(String data, String delimiter, String toDelimiter){
    
        String toReturn = null;
        if(String.isNotBlank(data)){
            String[] dataSplit = data.trim().split(delimiter);
            if(dataSplit.size() == 3 && dataSplit[0].isNumeric()
                && dataSplit[1].isNumeric() && dataSplit[2].isNumeric()){
                toReturn =  dataSplit[1] + toDelimiter + dataSplit[2] + toDelimiter + dataSplit[0];
            }
        }
        
        return toReturn;
    }

    public static String obterSobrenome(String nomeCompleto){
        List<String> nomesDivididos = nomeCompleto.split(' ');
        List<String> sobrenomeCompleto = new List<String>();
        String sobrenome;
        if(nomesDivididos.size() > 1){
            for(Integer i = 1; i < nomesDivididos.size(); i++){
                sobrenomeCompleto.add(nomesDivididos[i]);
            }
        }
        sobrenome = !sobrenomeCompleto.isEmpty() ?  String.join(sobrenomeCompleto, ' ') : null;
        return sobrenome;
    }

    public static String formatDateDDMMYYYY(Date data, String delimitador){
        String dia = String.valueOf(data.day()).leftPad(2, '0');
        String mes = String.valueOf(data.month()).leftPad(2, '0');
        String ano = String.valueOf(data.year());

        return dia + delimitador + mes + delimitador + ano;
    }
}