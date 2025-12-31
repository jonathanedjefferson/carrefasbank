public class InterfaceBancosDebitoAutomatico {
    
    @InvocableMethod(label='Obter Bancos Débito Automático')
    public static List<ResponseConsultarBancos> ObterBancosDebitoAutomatico(List<RequestConsultarBancos> requests){

        List<Banco__mdt> output = BancoDAO.getInstance().getAllDebitoAutomatico();
        
        String itemMenu1, itemMenu2;
        for(RequestConsultarBancos request : requests){
            itemMenu1 = request.itemMenu1;
            itemMenu2 = request.itemMenu2;
        }
        
        List<String> bancos = new List<String>();
        String descricaoBanco;
        for(Banco__mdt banco : output){
            descricaoBanco = banco.label + ' ' + banco.Codigo_Banco__c;
            bancos.add(descricaoBanco);
        }
        
        if(!String.isBlank(itemMenu1)){
            bancos.add(itemMenu1);
        }
        
        if(!String.isBlank(itemMenu2)){
            bancos.add(itemMenu2);
        }
        
        ResponseConsultarBancos responseConsultarBancos = new ResponseConsultarBancos();
        responseConsultarBancos.bancos = bancos;
        
        List<ResponseConsultarBancos> toReturn = new List<ResponseConsultarBancos>();
        toReturn.add(responseConsultarBancos);
        return toReturn;
    }

    public class RequestConsultarBancos {
        @InvocableVariable(label='Item menu 1')
        public String itemMenu1;
        @InvocableVariable(label='Item menu 2')
        public String itemMenu2;
    }
    
    public class ResponseConsultarBancos {
        @InvocableVariable(label='Lista de bancos')
        public List<String> bancos;
    }
}