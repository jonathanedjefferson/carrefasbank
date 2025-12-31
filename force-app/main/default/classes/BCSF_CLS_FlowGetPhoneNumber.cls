global with sharing class BCSF_CLS_FlowGetPhoneNumber {
    @InvocableMethod
    global static List<String> getFormatedNumber(List<String> numberWithText){
        List<String> listRetorno = new List<String>();
        String retorno = '';

        for (String item: numberWithText) {
            if (item.contains('+55')) {
                retorno = String.valueOf(numberWithText[0].split('\\+55')[1]);
            }else{
                List<String> listNumero = numberWithText[0].split('55');
                // CASO TENHA 55 NO MEIO DO NUMERO. EX: 5511970705570
                for (Integer i = 1; i < listNumero.size(); i++) {
                    if (i == 1) {
                        retorno += listNumero[i];
                    } else if(i > 1){
                        retorno += '55' + listNumero[i];
                    }
                }
            }    
            listRetorno.add(retorno);       
            break;
        }

        return listRetorno;
    }
}