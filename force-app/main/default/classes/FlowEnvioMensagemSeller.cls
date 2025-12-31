public with sharing class FlowEnvioMensagemSeller {
    @invocableMethod(label='Enviar mensagem ao seller')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            EnvioMensagemSellerTO resultado = EnvioMensagemSeller.makeAPIRequest(item.consigmentCode, item.bodyMessage);
            Output newOutput = new Output();
            newOutput.statusCode = resultado.statusCode;
            newOutput.message_id = resultado.message_id;
            newOutput.thread_id = resultado.thread_id;

            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='consigmentCode' required=true)
        public String consigmentCode;
        @InvocableVariable(label='bodyMessage' required=true)
        public String bodyMessage;
    }

    public class Output {
        @InvocableVariable
        public String message_id;
        @InvocableVariable
        public String thread_id;
        @InvocableVariable
        public Integer statusCode;
    }
}