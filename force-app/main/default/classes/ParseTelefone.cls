public class ParseTelefone {
    @invocableMethod(label='Get Celular Seguro')
    public static List<Output> GetCelularSeguro(List<String> listJsonTelefones){
        List<JsonToTelefoneEmail> listTelefones = new List<JsonToTelefoneEmail>();
        List<Output> listRetorno = new List<Output>();

        for (String item: listJsonTelefones) {
            listTelefones = parse(item);
        }

        if (listTelefones.size() > 0) {
            for (Telefones item: listTelefones[0].telefones) {
                if (item.celularSeguro) {
                    Output outp = new Output();
                    outp.CelularSeguro = true;
                    outp.NumeroCelular = '(' + item.ddd + ')' + item.numero;
                    
                    listRetorno.add(outp);
                    break;
                }
            }
        }

        return listRetorno;
    }

    public class Output{
        @InvocableVariable
        public Boolean CelularSeguro;
        @InvocableVariable
        public String NumeroCelular;
    }
    
    public class JsonToTelefoneEmail {
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

    public static List<JsonToTelefoneEmail> parse(String json) {
        return (List<JsonToTelefoneEmail>) System.JSON.deserialize(json, List<JsonToTelefoneEmail>.class);
    }
}