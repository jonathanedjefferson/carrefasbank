public with sharing class FlowVerificarUsuarioHSM {
    @invocableMethod(label='Verificar optIn por telefone')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            VerificarUsuarioHSMTO.resposneWrapper resultado = VerificarUsuarioHSM.makeAPIRequest(item.phone);
            Output newOutput = new Output();
            newOutput.statusCode = resultado.statusCode;
            newOutput.optIn = resultado.optin;

            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Telefone' required=true)
        public String phone;
    }

    public class Output {
        @InvocableVariable 
        public Integer statusCode;
        @InvocableVariable
        public String optIn;
    }
}