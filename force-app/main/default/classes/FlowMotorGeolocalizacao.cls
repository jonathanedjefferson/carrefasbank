public with sharing class FlowMotorGeolocalizacao {
    @invocableMethod(label='Verificar Carrefour mais próximo')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            MotorGeoLocalizacaoTO.resposneWrapper resultado = MotorGeoLocalizacao.makeAPIRequest(item.CEP, item.categoria);
            Output newOutput = new Output();
            newOutput.statusCode = resultado.statusCode;
            if(resultado.address != null) {
                //resultado.address.whatsappText = (resultado.address.whatsappText).replaceAll('\n', '<br/>');
                newOutput.whatsappText = resultado.address.whatsappText;
                newOutput.quantidadeLojas = resultado.quantidadeLojas;
            }

            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Categoria' required=true)
        public String categoria;
        @InvocableVariable(label='CEP' required=true)
        public String CEP;
    }

    public class Output {
        @InvocableVariable 
        public String whatsappText;
        @InvocableVariable
        public Integer statusCode;
        @InvocableVariable
        public Integer quantidadeLojas;
    }
}