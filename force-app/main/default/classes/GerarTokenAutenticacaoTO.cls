public with sharing class GerarTokenAutenticacaoTO {
	public class resposneWrapper {
        public String token;
        public Integer statusCode;
        public String message;
	}

    public String clientId;
    public String clientSecret;
    public String grantType;
}