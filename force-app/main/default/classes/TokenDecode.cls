public class TokenDecode {    
    @InvocableMethod(label='Descriptografar Token')
	public static List<Output> DecodeToken(List<Input> token){
		// TRANSFORMA TOKEN EM UMA LISTA DE STRING USANDO O ATRIBUTO '.' COMO PARAMETRO PARA DIVIDIR A STRING
		// A INFORMAÇÃO QUE QUEREMOS ESTÁ NA SEGUNDA POSIÇÃO DA LISTA, OU SEJA, listToken[1]
		List<String> listToken = token[0].Token.split('\\.');

		// CONVERTE O TOKEN PARA O FORMATO JSON
		String info = EncodingUtil.base64Decode(listToken[1]).toString();

		// CONVERTE A INFORMAÇÃO JSON EM UM OBJETO COM AS INFORMAÇÕES
		TokenDecode.Output infoJson = TokenDecode.Output.Json2Output(info);
		List<Output> listTokenDecoded = new List<Output>();
		listTokenDecoded.add(infoJson);
		
		return listTokenDecoded;
	}

	public static Output Json2Output(String json) {
		return (Output) System.JSON.deserialize(json, Output.class);
	}

	public class Input{
		@InvocableVariable(label='Token' required = true)
		public String Token;
	}

	public class Output{
		@InvocableVariable(label='jti' required = false)
		public String jti;
		@InvocableVariable(label='exp' required = false)
		public Integer exp;
		@InvocableVariable(label='nbf' required = false)
		public Integer nbf;
		@InvocableVariable(label='iat' required = false)
		public Integer iat;
		@InvocableVariable(label='iss' required = false)
		public String iss;
		@InvocableVariable(label='sub' required = false)
		public String sub;
		@InvocableVariable(label='typ' required = false)
		public String typ;
		@InvocableVariable(label='azp' required = false)
		public String azp;
		@InvocableVariable(label='auth_time' required = false)
		public Integer auth_time;
		@InvocableVariable(label='session_state' required = false)
		public String session_state;
		@InvocableVariable(label='acr' required = false)
		public String acr;
		@InvocableVariable(label='scope' required = false)
		public String scope;
		@InvocableVariable(label='email_verified' required = false)
		public Boolean email_verified;
		@InvocableVariable(label='account_name' required = false)
		public String account_name;
		@InvocableVariable(label='cpf' required = false)
		public String cpf;
		@InvocableVariable(label='tipo_cliente' required = false)
		public String tipo_cliente;
		@InvocableVariable(label='id_empresa' required = false)
		public String id_empresa;
		@InvocableVariable(label='preferred_username' required = false)
		public String preferred_username;
		@InvocableVariable(label='email' required = false)
		public String email;
	}
}