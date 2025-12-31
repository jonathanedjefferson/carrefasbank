public class InterfaceConfirmarAcordoDivida {
    @InvocableMethod(label='Confirmar Acordo Divida')
    public static List<ResponseConfirmarAcordo> ConfirmarAcordo(List<RequestConfirmarAcordo> parametersRequest){
    
        List<ResponseConfirmarAcordo> toReturn = new List<ResponseConfirmarAcordo>();
        ResponseConfirmarAcordo responseConfirmarAcordo = new ResponseConfirmarAcordo();
        
        for(RequestConfirmarAcordo request: parametersRequest){
            // Pix - 1
            // Boleto - 0
            String formaPagamento = request.formaPagamento;
            if(formaPagamento.contains('Boleto')){ 
                formaPagamento = '0';
            } else {
                formaPagamento = '1';
            }
            
            AcordoDivida.OutputConfirmarAcordo confirmarAcordo = AcordoDivida.ConfirmarAcordo(request.identificadorPlano, request.canalAcordo, formaPagamento, request.idEmpresa, request.cpf, request.canal);
                
            if(confirmarAcordo == null){
                responseConfirmarAcordo.statusRetorno = 'ERRO';
            } else {
                responseConfirmarAcordo.statusRetorno = 'OK';
                responseConfirmarAcordo.pix = confirmarAcordo.copiaCola;
                responseConfirmarAcordo.linhaDigitavel = confirmarAcordo.linhaDigitavel;      
                responseConfirmarAcordo.identificadorAcordo = confirmarAcordo.identificador;                
            }
            
            toReturn.add(responseConfirmarAcordo);
        }
        
        return toReturn;
    }
        
    public class RequestConfirmarAcordo {
        @InvocableVariable(label='Identificador do Plano' required=true)
        public String identificadorPlano;
        @InvocableVariable(label='Canal Acordo' required=true)
        public String canalAcordo;
        @InvocableVariable(label='Forma Pagamento' required=true)
        public String formaPagamento;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(required=true)
        public String canal;

    }
    
    public class ResponseConfirmarAcordo {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Pix')
        public String pix;
        @InvocableVariable(label='Linha Digitável')
        public String linhaDigitavel;
        @InvocableVariable(label='Identificador Acordo')
        public String identificadorAcordo;
    }
}