public with sharing class BCSF_ArrayParser {
    public class Request {
        @InvocableVariable(label='JSON para converter 01')
        public String jsonStringToConvert;
        @InvocableVariable(label='JSON para converter 02')
        public String jsonStringToConvert02;
        @InvocableVariable(label='JSON para converter 03')
        public String jsonStringToConvert03;
        @InvocableVariable(label='JSON para converter 04')
        public String jsonStringToConvert04;
        @InvocableVariable(label='JSON para converter 05')
        public String jsonStringToConvert05;
    }

    public class Response {
        @InvocableVariable(label='Coleção 01') public List<String> JSONCollection01 = new List<String>();
        @InvocableVariable(label='Coleção 02') public List<String> JSONCollection02 = new List<String>();
        @InvocableVariable(label='Coleção 03') public List<String> JSONCollection03 = new List<String>();
        @InvocableVariable(label='Coleção 04') public List<String> JSONCollection04 = new List<String>();
        @InvocableVariable(label='Coleção 05') public List<String> JSONCollection05 = new List<String>();

        public void setCollection(String collectionJson, List<String> referenceToOneOfMyLists){
            if(collectionJson != null) referenceToOneOfMyLists.addAll(JSONConvertCollection(collectionJson));
        }
    }

    @InvocableMethod(label='Converte array em JSONs')
    public static List<Response> execute(List<Request> requests) {
        Request curRequest = requests[0];
        Response response = new Response();

        response.setCollection(curRequest.jsonStringToConvert, response.JSONCollection01);
        response.setCollection(curRequest.jsonStringToConvert02, response.JSONCollection02);
        response.setCollection(curRequest.jsonStringToConvert03, response.JSONCollection03);
        response.setCollection(curRequest.jsonStringToConvert04, response.JSONCollection04);
        response.setCollection(curRequest.jsonStringToConvert05, response.JSONCollection05);
        
        return new List<Response>{response};
    }

    private static List<String> JSONConvertCollection(String jsonString) {
        List<Object> theList = (List<Object>) System.JSON.deserializeUntyped(jsonString);
        List<String> CollectionResult = new List<String>();

        for(Object obj: theList){
            CollectionResult.add(System.JSON.serialize(obj));
        }

        return CollectionResult;
    }
}