public with sharing class FlowNewMembership {
    @invocableMethod(label='New membership')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> lstRetorno = new List<Output>();

        for(Input item: lstEntrada) {
            System.debug(item);
            NewMembershipTO.Additional aditional;
            if (item.additional != null) {
                aditional= new NewMembershipTO.Additional(
                                                    item.additional.aka,
                                                    item.additional.firstname,
                                                    item.additional.lastname,
                                                    item.additional.birthdate, 
                                                    item.additional.phone,
                                                    item.additional.email,
                                                    item.additional.cpf.replace('-', '').replace('.', ''),
                                                    item.additional.optin,
                                                    item.additional.zipcode.replace('-',''),
                                                    item.additional.number_z,
                                                    item.additional.complement
                                                   );

                aditional.cpf = String.isNotBlank(item.additional.cpf) ? item.additional.cpf.replace('-', '').replace('.', '') : '';
                aditional.zipcode = String.isNotBlank(item.additional.zipcode) ? item.additional.zipcode.replace('-', '') : '';
            }
            
                                                  
            NewMembershipTO.ResponseWrapper resultado = NewMembershipCallout.makeAPIRequest(item.store, item.aka, item.firstName, item.lastName, item.birthDate, item.zipcode, item.number_z, item.complement, item.phone, item.email, item.cpf, item.promoter, item.partner, item.cupom, item.optin, item.salesChannel, item.midiaChannel, item.promoName,aditional);
            Output newOutput = new Output();
            
            if(resultado != null) {
                newOutput.status = resultado.status;
                newOutput.statusmsg = resultado.statusmsg;
                newOutput.msnbr1 = resultado.msnbr1;
            }
            lstRetorno.add(newOutput);

        }
        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='store' required=true)
        public String store;
        @InvocableVariable(label='aka' required=true)
        public String aka;
        @InvocableVariable(label='firstName' required=true)
        public String firstName;
        @InvocableVariable(label='lastName' required=true)
        public String lastName;
        @InvocableVariable(label='birthDate' required=true)
        public Date birthDate;
        @InvocableVariable(label='zipcode' required=true)
        public String zipcode;
        @InvocableVariable(label='number' required=true)
        public String number_z;
        @InvocableVariable(label='complement')
        public String complement;
        @InvocableVariable(label='phone' required=true)
        public String phone;
        @InvocableVariable(label='email' required=true )
        public String email;
        @InvocableVariable(label='cpf' required=true )
        public String cpf;
        @InvocableVariable(label='promoter')
        public Integer promoter;
        @InvocableVariable(label='partner')
        public String partner;
        @InvocableVariable(label='cupom')
        public String cupom;
        @InvocableVariable(label='optin' required=true)
        public Boolean optin;
        @InvocableVariable(label='salesChannel' required=true)
        public String salesChannel;
        @InvocableVariable(label='midiaChannel')
        public String midiaChannel;
        @InvocableVariable(label='promoName')
        public String promoName;
        @InvocableVariable(label='additional')
        public AditionalInput additional;

    }


    public class Output{
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String statusmsg;
        @InvocableVariable
        public String msnbr1;
    }


}