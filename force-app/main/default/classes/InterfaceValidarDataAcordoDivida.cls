public class InterfaceValidarDataAcordoDivida {

    static final Integer MIN_DAY_ACORDO = 1;
    static final Integer MAX_DAY_ACORDO = 29;
    
    @InvocableMethod(label='Validar Data Acordo Dívida')
    public static List<ResponseDatasIntervaloAcordo> ValidarDataAcordoDivida(List<RequestDatasIntervaloAcordo> parametersRequest){
    
        List<ResponseDatasIntervaloAcordo> toReturn = new List<ResponseDatasIntervaloAcordo>();
        ResponseDatasIntervaloAcordo responseDatasIntervaloAcordo = new ResponseDatasIntervaloAcordo();
        
        for(RequestDatasIntervaloAcordo request: parametersRequest){
        
            if('VALIDAR_DATA'.equals(request.action)){
                boolean isDataValida = Util.isValidDateAcordo(MIN_DAY_ACORDO, MAX_DAY_ACORDO, request.dataAcordo);
                if(isDataValida){
                    Date dataAcordo = Util.stringToDate(request.dataAcordo, '/');
                    String dayAcordo = '' + dataAcordo.day();
                    responseDatasIntervaloAcordo.diaVencimentoAcordo =  dayAcordo.leftPad(2, '0');
                    responseDatasIntervaloAcordo.dataValida = 'S';
                } else {
                    responseDatasIntervaloAcordo.dataValida = 'N';
                }               
            } else {
                responseDatasIntervaloAcordo.dataMinina =  Util.getDateAcordo(MIN_DAY_ACORDO);    
                responseDatasIntervaloAcordo.dataMaxima = Util.getDateAcordo(MAX_DAY_ACORDO);
            }
            
            toReturn.add(responseDatasIntervaloAcordo);
        }
        
        return toReturn;
    }
        
    public class RequestDatasIntervaloAcordo {
        @InvocableVariable(label='Ação' required=true)
        public String action;
        @InvocableVariable(label='Data acordo' required=false)
        public String dataAcordo;
    }
    
    public class ResponseDatasIntervaloAcordo {
        @InvocableVariable(label='Data Mínima')
        public String dataMinina;
        @InvocableVariable(label='Data Máxima')
        public String dataMaxima;
        @InvocableVariable(label='Data está valida')
        public String dataValida;
        @InvocableVariable(label='Dia Vencimento Acordo')
        public String diaVencimentoAcordo;
    }
}