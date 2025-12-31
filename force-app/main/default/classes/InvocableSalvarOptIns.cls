public with sharing class InvocableSalvarOptIns {

    @InvocableMethod(label='Salvar Opt-in' description='Retorna o status da requisição')
    public static List<Output> invocableSalvarOptIns(List<Input> Input){

        List<Output> outputs = new List<Output>() ;
        Varejo_Api_Callout__mdt meta = Varejo_Api_Callout__mdt.getInstance('SalvarOptins');

        for (Input req : Input) {
            Integer statusCode = SalvarOptInCallout.execute(req, meta);
            outputs.add(new Output(statusCode));
        }
        return outputs;
    }

    public class Input {
        @InvocableVariable(label='Cpf' required=true)
        public String cpf;
        @InvocableVariable(label='Bandeira' required=true)
        public String bandeira;
        @InvocableVariable(label='Versão' required=true)
        public String versao;
        @InvocableVariable(label='Push Notification' required=true)
        public Boolean pushnotification;
        @InvocableVariable(label='Email' required=true)
        public Boolean email;
        @InvocableVariable(label='SMS' required=true)
        public Boolean sms;
        @InvocableVariable(label='Telefone' required=true)
        public Boolean telefone;
        @InvocableVariable(label='Thirdparty' required=true)
        public Boolean thirdparty;
    
    }

    public class Output{
        @InvocableVariable(label='StatusCode')
        public Integer statusCode;

        public Output(Integer statusCode){
            this.statusCode = statusCode;
        }
    }
}