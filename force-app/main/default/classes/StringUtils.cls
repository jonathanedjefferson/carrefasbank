// Classe para métodos de manipulação de String

public class StringUtils {

    public static String getCurrencyFormat(Decimal x){
        String y = String.valueOf(x);
        String z = '.';
        String valorDecimal = '';
        if(y.indexOf(z) > 0){
            valorDecimal = y.substring(y.indexOf(z));
            valorDecimal = valorDecimal.replace('.', ',');
            y = y.substring(0, y.indexOf(z));
        }

        if(x - Decimal.valueOf(y) == 0) {
            return String.valueOf(x.format()) + ',00';
        } else if (valorDecimal.length() == 2){
            String valorFormatado =  String.valueOf(x.format());
            return valorFormatado.replace(valorDecimal, valorDecimal + '0');
        } else {
            return String.valueOf(x.format());
        }
    }

    public static String getPorcentFormat(Decimal x){
        return getCurrencyFormat(x) + '%';
    }
}