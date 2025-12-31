public with sharing class CadastrarUsuarioHSMTO {
	public class resposneWrapper {
        public Data data;
        public Integer statusCode;
	}

	public class Data {
		public Integer id;
		public String name;
		public String phone;
		public String acronymLoja;
		public String createdAt;
		public String updatedAt;
		public Object deletedAt;
	}

    public String phone;
    public String name;
    public String acronymLoja;
}