public class FlowInfoSocio {

    @InvocableMethod(label='Identificar Socio')
    public static List<Output> chamarIdentificarSocio(List<Input> lstEntrada) {
        String CPF = lstEntrada[0].CPF;
        System.debug('CPF: ' + CPF);

        List<Output> outputList = new List<Output>();

        if (CPF != null) {
            IdentificarSocioTO.ResponseWrapper result = IdentificarSocio.getInfoSocio(CPF);
            System.debug('Return flow' + result);

            Output output = new Output();
            output.uniqueid = result.uniqueid;
            output.firstname = result.firstname;
            output.cpf = result.cpf;
            output.lastname = result.lastname;
            output.renovationdate = result.renovationdate;
            output.favoritestore = result.favoritestore;
            output.store = result.store;
            output.status = result.status;
            output.aka = result.aka;
            output.fullnumber = result.fullnumber;
            output.photo = result.photo;
            output.birthdate = result.birthdate;
            output.email = result.email;
            output.phone = result.phone;
            output.cep = result.cep;
            output.streetname = result.streetname;
            output.number_Z = result.number_Z;
            output.complement = result.complement;
            output.neighbour = result.neighbour;
            output.city = result.city;
            output.state = result.state;
            output.autorenovation = result.autorenovation;
            output.trialpass = result.trialpass;
            output.memberiD = result.memberiD;
            output.plus = result.plus;

            outputList.add(output); // Adicionar objeto Output à lista de output
            System.debug('output: '+ output);
        }
        return outputList;
    }
    
    public class Input {
        @InvocableVariable(label='CPF'  required=true)
        public String CPF;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public Integer uniqueid;
        @AuraEnabled @InvocableVariable
		public String firstname;
        @AuraEnabled @InvocableVariable
		public String cpf;
        @AuraEnabled @InvocableVariable
		public String lastname;
        @AuraEnabled @InvocableVariable
		public String renovationdate;
        @AuraEnabled @InvocableVariable
		public Integer favoritestore;
        @AuraEnabled @InvocableVariable
		public String store;
        @AuraEnabled @InvocableVariable
		public String status;
        @AuraEnabled @InvocableVariable
		public String aka;
        @AuraEnabled @InvocableVariable
		public String fullnumber;
        @AuraEnabled @InvocableVariable
		public String photo;
        @AuraEnabled @InvocableVariable
		public String birthdate;
        @AuraEnabled @InvocableVariable
		public String email;
        @AuraEnabled @InvocableVariable
		public String phone;
        @AuraEnabled @InvocableVariable
		public String cep;
        @AuraEnabled @InvocableVariable
		public String streetname;
        @AuraEnabled @InvocableVariable
		public String number_Z; // in json: number
        @AuraEnabled @InvocableVariable
		public String complement;
        @AuraEnabled @InvocableVariable
		public String neighbour;
		@AuraEnabled @InvocableVariable
        public String city;
        @AuraEnabled @InvocableVariable
		public String state;
        @AuraEnabled @InvocableVariable
		public Boolean autorenovation;
        @AuraEnabled @InvocableVariable
		public Boolean trialpass;
        @AuraEnabled @InvocableVariable
		public Integer memberiD;
        @AuraEnabled @InvocableVariable
		public boolean plus;
    }
}