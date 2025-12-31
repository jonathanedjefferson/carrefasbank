@isTest
public class VerificaStatusTest {
	
    @isTest
    public static void verificaStatusContaNormCartaoCancelado() {
    
        List<String> statusCancelados = new List<String>{'CLSD', 'CLSC', 'CLSB', 'PICK'};
        
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('CANCEL',retorno.get(0).status);
        }
    }  
    
    @isTest
    public static void verificaStatusContaNormCartaoBloqueado() {
    
        List<String> statusCancelados = new List<String>{'BLCK'};
                
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('BLOQ',retorno.get(0).status);
        }
    }  
    
    
    @isTest
    public static void verificaStatusContaNormCartaoBloqueadoDefinitivo() {
    
        List<String> statusCancelados = new List<String>{'DAMC','CNRV','DSTY','STLC','LOST','INSC','STLC','BLDC','INTC'};
		
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('BLOQ_DEFIN',retorno.get(0).status);
        }
    }  
    
    @isTest
    public static void verificaStatusContaNormCartaoFraude() {
    
        List<String> statusCancelados = new List<String>{'AFRD','REPL','RCHQ','ANUI','ERIN','IUPD','SAFE','ASNT','DOWN','UPGR','BAPP'};
      		
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('FRAUDE',retorno.get(0).status);
        }
    }  
    
    @isTest
    public static void verificaStatusContaNormCartaoPlanoParcelamento() {
    
        List<String> statusCancelados = new List<String>{'NORP', 'NORC', 'NURP'};
        
    	VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('PLANO_PARCELAMENTO',retorno.get(0).status);
        }
    }  
    
    @isTest
    public static void verificaStatusContaNormCartaoCobranca() {
    
        List<String> statusCancelados = new List<String>{'PWOF', 'DLNQ'};
        
		VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('COBR',retorno.get(0).status);
        }
    } 
    
    @isTest
    public static void verificaStatusContaNormCartaoNormal() {
    
        List<String> statusCancelados = new List<String>{'NORM'};

        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('NORMAL',retorno.get(0).status);
        }
    } 
    
    @isTest
    public static void verificaStatusContaNormCartaoBloqueioParcelamento() {
    
        List<String> statusCancelados = new List<String>{'NRPP'};
	
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('BLOQ_PARC',retorno.get(0).status);
        }
    } 
    
    @isTest
    public static void verificaStatusContaNormCartaoDemaisStatus() {
    
        List<String> statusCancelados = new List<String>{'CPOC'};
		
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'NORM';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('OUTROS',retorno.get(0).status);
        }
    }
    
    @isTest
    public static void verificaStatusContaDiferenteNormCartaoCancelado() {
    
        List<String> statusCancelados = new List<String>{'CLSD', 'CLSC', 'CLSB', 'PICK'};
        
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = 'CLSD';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('CANCEL',retorno.get(0).status);
        }
    }
    
    @isTest
    public static void verificaStatusContaVazioCartaoCancelado() {
    
        List<String> statusCancelados = new List<String>{'CLSD', 'CLSC', 'CLSB', 'PICK'};
        
        VerificaStatus.RequestVerificaStatus request = new VerificaStatus.RequestVerificaStatus();    
        request.codigoStatusConta = '';
        
        for(String codigoStatus : statusCancelados){
            request.codigoStatusCartao = codigoStatus;
            
            
            List<VerificaStatus.RequestVerificaStatus> requestList = new List<VerificaStatus.RequestVerificaStatus>();
            requestList.add(request);
            
            List<VerificaStatus.ResponseVerificaStatus> retorno = VerificaStatus.VerificaStatus(requestList);

            System.AssertEquals('CANCEL',retorno.get(0).status);
        }
    }
}