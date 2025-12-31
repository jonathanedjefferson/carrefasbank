public with sharing class FlowCadastrarUsuarioHSM {
    @invocableMethod(label='Cadastrar optIn')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            CadastrarUsuarioHSMTO.resposneWrapper resultado = CadastrarUsuarioHSM.makeAPIRequest(item.phone, item.name, item.acronymLoja);
            Output newOutput = new Output();
            newOutput.statusCode = resultado.statusCode;
            newOutput.createdAt = resultado.data.createdAt;

            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Telefone' required=true)
        public String phone;
        @InvocableVariable(label='Nome' required=false)
        public String name;
        @InvocableVariable(label='acronymLoja' required=true)
        public String acronymLoja;  
    }

    public class Output {
        @InvocableVariable 
        public Integer statusCode;
        @InvocableVariable
        public String createdAt;
    }
}