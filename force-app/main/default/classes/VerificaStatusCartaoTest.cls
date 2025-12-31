/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - VerificaStatusCartao                             100%           *
**************************************************************************/

@isTest
public class VerificaStatusCartaoTest {

    @isTest
    public static void verificaStatusCancelado() {
    
        List<String> statusCancelados = new List<String>{'CLSD', 'CLSC', 'CLSB', 'PICK'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('CANCEL',retorno.get(0).statusCartao);
        }
    }  
    
    @isTest
    public static void verificaStatusBloqueado() {
    
        List<String> statusCancelados = new List<String>{'BLCK'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('BLOQ',retorno.get(0).statusCartao);
        }
    }  
    
    
    @isTest
    public static void verificaStatusBloqueadoDefinitivo() {
    
        List<String> statusCancelados = new List<String>{'DAMC','CNRV','DSTY','STLC','LOST','INSC','STLC','BLDC','INTC'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('BLOQ_DEFIN',retorno.get(0).statusCartao);
        }
    }  
    
    @isTest
    public static void verificaStatusFraude() {
    
        List<String> statusCancelados = new List<String>{'AFRD','REPL','RCHQ','ANUI','ERIN','IUPD','SAFE','ASNT','DOWN','UPGR','BAPP'};
       
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('FRAUDE',retorno.get(0).statusCartao);
        }
    }  
    
    @isTest
    public static void verificaStatusPlanoParcelamento() {
    
        List<String> statusCancelados = new List<String>{'NORP', 'NORC', 'NURP'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('PLANO_PARCELAMENTO',retorno.get(0).statusCartao);
        }
    }  
    
    @isTest
    public static void verificaStatusCobranca() {
    
        List<String> statusCancelados = new List<String>{'PWOF', 'DLNQ'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('COBR',retorno.get(0).statusCartao);
        }
    } 
    
    @isTest
    public static void verificaStatusNormal() {
    
        List<String> statusCancelados = new List<String>{'NORM'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('NORMAL',retorno.get(0).statusCartao);
        }
    } 
    
    @isTest
    public static void verificaStatusBloqueioParcelamento() {
    
        List<String> statusCancelados = new List<String>{'NRPP'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('BLOQ_PARC',retorno.get(0).statusCartao);
        }
    } 
    
    @isTest
    public static void verificaStatusDemaisStatus() {
    
        List<String> statusCancelados = new List<String>{'CPOC'};
        
        VerificaStatusCartao.RequestVerificaStatusCartao request;
        for(String codigoStatus : statusCancelados){
            request = new VerificaStatusCartao.RequestVerificaStatusCartao();
            request.codigoStatusCartao = codigoStatus;
            
            List<VerificaStatusCartao.RequestVerificaStatusCartao> requestList = new List<VerificaStatusCartao.RequestVerificaStatusCartao>();
            requestList.add(request);
            
            List<VerificaStatusCartao.ResponseVerificaStatusCartao> retorno = VerificaStatusCartao.VerificaStatusCartao(requestList);

            System.AssertEquals('OUTROS',retorno.get(0).statusCartao);
        }
    }  
   
}