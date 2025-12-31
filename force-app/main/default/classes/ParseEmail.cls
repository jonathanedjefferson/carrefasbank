public class ParseEmail {
    @invocableMethod(label='Get Email/Email Mascarado')
    public static List<Output> GetEmail(List<String> listJsonEmails){
        List<JsonToEmail> listEmails = new List<JsonToEmail>();
        List<Output> listRetorno = new List<Output>();

        for (String item: listJsonEmails) {
            listEmails = parse(item);
        }

        for (Emails item: listEmails[0].emails) {
            Output outp = new Output();
            outp.email = item.endereco;
            outp.emailMascarado = Util.mascararEmail(item.endereco);

            listRetorno.add(outp);
            break;
        }

        return listRetorno;
    }

    public class Output{
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String emailMascarado;
    }
    
    public class JsonToEmail {
        public List<Emails> emails;
        public List<Telefones> telefones;
        public String numeroConta;
    }

    public class Emails {
        public String endereco;
    }

    public class Telefones {
        public Boolean celularSeguro;
        public String numero;
        public String ddd;
    }
    public static List<JsonToEmail> parse(String json) {
        return (List<JsonToEmail>) System.JSON.deserialize(json, List<JsonToEmail>.class);
    }
}