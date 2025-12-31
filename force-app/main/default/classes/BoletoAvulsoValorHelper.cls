public class BoletoAvulsoValorHelper {

    @invocableMethod(label='Validar Valor')
    public static List<OutputValor> validarValorValor(List<InputValor> inputs){
        List<OutputValor> outputList = new List<OutputValor>();
        OutputValor output = new OutputValor();

        Decimal valorMin = Decimal.valueOf((inputs[0].valorMinimo));
        Decimal valorMax = Decimal.valueOf((inputs[0].valorMaximo));

        try{

            String valorDigitado = inputs[0].valor;
            valorDigitado = valorDigitado.replaceAll('[^0-9.,]', '');

            Pattern p = Pattern.compile('^([\\d.,]+)([.,]\\d{1,2})?$');
            Matcher m = p.matcher(valorDigitado);

            if(m.matches()){
                String parteInteira = m.group(1).replaceAll('[.,](?=\\d{3})', '');
                String parteDecimal = m.group(2) != null ? m.group(2) : '';

                String valorFormatado = parteInteira + parteDecimal;

                valorFormatado = valorFormatado.replace(',', '.');

                Decimal valorDecimal = Decimal.valueOf(valorFormatado);

                output.valor = String.valueOf(valorDecimal.setScale(2));
                output.valorValido = (valorDecimal < valorMin) == false && (valorDecimal > valorMax) == false ? true : false;
            } else{
                output.valorValido = false;
            }
    
        } catch (Exception e){
            output.valorValido = false;
        }
        
        outputList.add(output);
    
     
        return outputList; 
    }

    public class InputValor{
        @InvocableVariable(label='Valor digitado' required = true)
        public String valor;
        @InvocableVariable(label='Valor minimo' required = true)
        public String valorMinimo;
        @InvocableVariable(label='Valor maximo' required = true)
        public String valorMaximo;
    }

    public class OutputValor{
        @InvocableVariable (label='Valor')
        public String valor;
        @InvocableVariable(label='Valor valido')
        public Boolean valorValido;
    }
}