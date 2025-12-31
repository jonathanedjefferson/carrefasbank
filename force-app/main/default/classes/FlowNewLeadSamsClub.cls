public with sharing class FlowNewLeadSamsClub {
    @invocableMethod(label='Cadastrar novo lead Sams Club')
    public static List<Output> cadastrarNovoLead(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            Integer receivedStatusCode = NewLeadSamsClub.createNewLead(item.nome, item.sobrenome, item.email, item.telefone, item.cpf, item.dataNascimento);
            Output newOutput = new Output();
            newOutput.statusCode = receivedStatusCode;
            lstRetorno.add(newOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='nome' required=true)
        public String nome;
        @InvocableVariable(label='sobremone' required=true)
        public String sobrenome;
        @InvocableVariable(label='email' required=true)
        public String email;
        @InvocableVariable(label='telefone' required=true)
        public String telefone;
        @InvocableVariable(label='cpf' required=true)
        public String cpf;
        @InvocableVariable(label='dataNascimento' required=true)
        public Datetime dataNascimento;
    }

    public class Output {
        @InvocableVariable 
        public Integer statusCode;
    }
}