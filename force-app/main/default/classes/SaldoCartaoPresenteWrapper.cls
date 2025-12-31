public class SaldoCartaoPresenteWrapper {
    public void SaldoCartaoPresenteWrapper(){
        this.success = new ReturnSuccess();
        this.error = new ReturnError();
    }

    public ReturnSuccess success;	
    public ReturnError error;	
    
    public class ReturnSuccess{
        public String id;	
        public Double balance;	
        public String emissionDate;
        public String expiringDate;
    }

    public class ReturnError{
        public String timestamp;	
    	public Integer status;	
    	public String error;	
    	public String message;
    	public String path;
    }
}