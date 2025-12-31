public class FlowAtualizarNovosUsuarios {
    
    @InvocableMethod(label='API para  atualização de usuários ')
    public static List<Output> callAPI(List<Input> lstInputs) {
        List<Output> outp = new List<Output>();
        for (Input inLst: lstInputs){
            AtualizarNovosUsuarios.Response response =  AtualizarNovosUsuarios.atualizarUsuario(inLst.fullnumber, inLst.midiachannel, inLst.partner);
            
            If(response != null){
            Output outpt = new Output();
            outpt.status = response.status;
            outpt.statusmsg =  response.statusmsg;
            outpt.msnbr1 = response.msnbr1;
                
            outp.add(outpt);        
            } else {
                Output outNull = new Output();
                outNull.status = 'erro';
                outp.add(outNull);
            }
        }
        System.debug('output: ' + outp);
        return outp;
    }
    public class Input {
        @InvocableVariable
        public String fullNumber;
        
        @InvocableVariable
        public String midiachannel;
        
        @InvocableVariable
        public String partner;

    }
    
    public class Output {
        @AuraEnabled @InvocableVariable
        public String status;
        
        @AuraEnabled @InvocableVariable
        public String statusmsg;
        
        @AuraEnabled @InvocableVariable
        public String msnbr1;
        
    }

}