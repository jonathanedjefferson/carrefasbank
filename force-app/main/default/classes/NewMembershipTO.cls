public with sharing class NewMembershipTO {
    public class RequestWrapper {
        public String store {get;set;} 
        public String aka {get;set;} 
        public String firstname {get;set;} 
        public String lastname {get;set;} 
        public Date birthdate {get;set;} 
        public String zipcode {get;set;} 
        public String number_Z {get;set;} 
        public String complement {get;set;} 
        public String phone {get;set;} 
        public String email {get;set;} 
        public String cpf {get;set;} 
        public Integer promoter {get;set;} 
        public String partner {get;set;} 
        public String cupom {get;set;} 
        public Boolean optin {get;set;} 
        public String saleschannel {get;set;} 
        public String midiachannel {get;set;} 
        public String promoname {get;set;} 
        public Additional additional {get;set;} 
        
	}

	public class Additional {
		public String aka {get;set;} 
		public String firstname {get;set;} 
		public String lastname {get;set;} 
		public Date birthdate {get;set;} 
		public String phone {get;set;} 
		public String email {get;set;} 
		public String cpf {get;set;} 
		public Boolean optin {get;set;} 
		public String zipcode {get;set;} 
		public String number_Z {get;set;} 
		public String complement {get;set;} 
        public Additional(){}
        public Additional(String aka, String firstname, String lastname, Date birthdate, 
                      String phone, String email, String cpf, Boolean optin, 
                      String zipcode, String number_Z, String complement) {
        this.aka = aka;
        this.firstname = firstname;
        this.lastname = lastname;
        this.birthdate = birthdate;
        this.phone = phone;
        this.email = email;
        this.cpf = cpf;
        this.optin = optin;
        this.zipcode = zipcode;
        this.number_Z = number_Z;
        this.complement = complement;
    }
	}

    public class ResponseWrapper {
        public String status {get;set;} 
        public String statusmsg {get;set;} 
        public String msnbr1 {get;set;} 
    }
}