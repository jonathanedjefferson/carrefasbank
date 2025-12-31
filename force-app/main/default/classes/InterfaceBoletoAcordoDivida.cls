public class InterfaceBoletoAcordoDivida {
    
    @InvocableMethod(label='Obter Boleto Acordo')
    public static List<ResponseObterBoleto> ObterBoletoAcordo(List<RequestObterBoleto> parametersRequest){
    
        List<ResponseObterBoleto> toReturn = new List<ResponseObterBoleto>();
        ResponseObterBoleto responseObterBoleto = new ResponseObterBoleto();
        
        for(RequestObterBoleto request: parametersRequest){
        
            Boolean output = AcordoDivida.EnviarBoletoAcordo(request.identificadorAcordo, request.idEmpresa, request.cpf, request.canal);
                
            if(output){
                responseObterBoleto.statusChamada= 'OK';
            } else {
                responseObterBoleto.statusChamada= 'ERRO';
            }
            
            toReturn.add(responseObterBoleto);
        }
        
        return toReturn;
    }

    public class RequestObterBoleto {
        @InvocableVariable(label='Identificador Acordo' required=true)
        public String identificadorAcordo;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='CPF Cliente' required=true)
        public String cpf;
        @InvocableVariable(required=true)
        public String canal;
    }
    
    public class ResponseObterBoleto {
        @InvocableVariable(label='Status Chamada')
        public String statusChamada;
    }
}