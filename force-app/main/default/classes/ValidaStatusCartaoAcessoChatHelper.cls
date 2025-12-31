public class ValidaStatusCartaoAcessoChatHelper {
    @invocableMethod(label='Validar Status Cartão para acessar Chat')
    public static List<Output> ValidarStatus(List<Input> listInput){
        List<Output> listRetorno = new List<Output>();
        Output objRetorno = new Output();

        for (Input itemInput: listInput) {
            List<StatusCartaoPermitidoChat__mdt> listStatusMetadado = ValidaStatusCartaoAcessoChatDAO.getStatus(itemInput.LabelsMetadado.split(';'));
            
            for (StatusCartaoPermitidoChat__mdt itemStatus: listStatusMetadado) {
                if (itemStatus.ListaStatus__c != null) {
                    List<String> listStatus = itemStatus.ListaStatus__c.split(';');
                    
                    for (String item: listStatus) {
                        if (item == itemInput.StatusCartaoCliente) {
                            objRetorno.ComAcesso = itemStatus.ComAcesso__c;
                            objRetorno.SemAcessoAppChat = itemStatus.SemAcessoAppChat__c;
                            objRetorno.SemAcessoAppComAcessoChat = itemStatus.SemAcessoAppComAcessoChat__c;
                            break;
                        }
                    }
                }
            } 
            break;
        }

        listRetorno.add(objRetorno);
        return listRetorno;
    }

    public class Input{
        @InvocableVariable(required = true)
        public String StatusCartaoCliente;
        @InvocableVariable(required = true)
        public String LabelsMetadado;
    }

    public class Output{
        @InvocableVariable
        public Boolean ComAcesso;
        @InvocableVariable
        public Boolean SemAcessoAppChat;
        @InvocableVariable
        public Boolean SemAcessoAppComAcessoChat;
    }
}