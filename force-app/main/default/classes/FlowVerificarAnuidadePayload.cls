public with sharing class FlowVerificarAnuidadePayload {
    @invocableMethod(label='Verificar anuidade Sams Club')
    public static List<Output> chamarAPIVerificarAnuidade(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            VerificarAnuidadePayloadTO.resposneWrapper resultado = VerificarAnuidadePayload.makeAPIRequest(item.codigoMembership);
            Output newOutput = new Output();
            newOutput.Success = resultado.success;
            newOutput.Payload = resultado.payload;
            newOutput.Error = resultado.error;
            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Código membership' required=true)
        public String codigoMembership;
    }

    public class Output{
        @InvocableVariable
        public String Success;
        @InvocableVariable
        public String Payload;
        @InvocableVariable
        public String Error;
    }
    
}