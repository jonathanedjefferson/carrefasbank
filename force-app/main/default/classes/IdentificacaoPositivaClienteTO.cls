public with sharing class IdentificacaoPositivaClienteTO {
    public class ResponseWrapper {
        public String email;
        public String firstName;
        public String lastName;
        public String document;
        public String homePhone;
        public String birthDate;
        public String updatedIn;
    }

    public class Retorno {
        public String email;
        public String firstName;
        public String lastName;
        public String homePhone;
        public String birthDate;
    }
}