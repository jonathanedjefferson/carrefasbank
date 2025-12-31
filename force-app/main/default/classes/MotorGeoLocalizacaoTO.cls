public with sharing class MotorGeoLocalizacaoTO {
	public class resposneWrapper {
		public String category;
		public String type;
		public Address address;
		public Integer statusCode;
        public Integer quantidadeLojas;
	}

	public class Address {
		public String whatsappText;
	}

	public class returnItem {
        public Integer statusCode;
        public String whatsappText;
    }
}