public class GerarLinkDeCatalogoTO {
    public class ResponseWrapper {
            public Boolean success;
            public Payload payload;
            public Object error;
        }
    
        public class Payload {
            public String orderFormId;
            public String orderURL;
        }
   }