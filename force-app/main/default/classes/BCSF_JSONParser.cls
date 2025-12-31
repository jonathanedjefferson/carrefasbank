public with sharing class BCSF_JSONParser {

    @InvocableMethod(label='Parser de JSONs')
    public static List<ResultValue> MultipleJSONParser(List<Request> jsonObjects) {
        List<ResultValue> results = new List<ResultValue>();
        ResultValue result = new ResultValue();
        for (Request jsonObject: jsonObjects) {
            Object jsonToParse = JSON.deserializeUntyped(jsonObject.jsonStringToParse);
            result.Value01 = JSONParser(jsonObject.fieldName1, jsonToParse, jsonObject.ignore_error);
            result.Value02 = JSONParser(jsonObject.fieldName2, jsonToParse, jsonObject.ignore_error);
            result.Value03 = JSONParser(jsonObject.fieldName3, jsonToParse, jsonObject.ignore_error);
            result.Value04 = JSONParser(jsonObject.fieldName4, jsonToParse, jsonObject.ignore_error);
            result.Value05 = JSONParser(jsonObject.fieldName5, jsonToParse, jsonObject.ignore_error);
            result.Value06 = JSONParser(jsonObject.fieldName6, jsonToParse, jsonObject.ignore_error);
            result.Value07 = JSONParser(jsonObject.fieldName7, jsonToParse, jsonObject.ignore_error);
            result.Value08 = JSONParser(jsonObject.fieldName8, jsonToParse, jsonObject.ignore_error);
            result.Value09 = JSONParser(jsonObject.fieldName9, jsonToParse, jsonObject.ignore_error);
            result.Value10 = JSONParser(jsonObject.fieldName10, jsonToParse, jsonObject.ignore_error);
            result.Value11 = JSONParser(jsonObject.fieldName11, jsonToParse, jsonObject.ignore_error);
            result.Value12 = JSONParser(jsonObject.fieldName12, jsonToParse, jsonObject.ignore_error);
            result.Value13 = JSONParser(jsonObject.fieldName13, jsonToParse, jsonObject.ignore_error);
            result.Value14 = JSONParser(jsonObject.fieldName14, jsonToParse, jsonObject.ignore_error);
            result.Value15 = JSONParser(jsonObject.fieldName15, jsonToParse, jsonObject.ignore_error);
            result.Value16 = JSONParser(jsonObject.fieldName16, jsonToParse, jsonObject.ignore_error);
            result.Value17 = JSONParser(jsonObject.fieldName17, jsonToParse, jsonObject.ignore_error);
            result.Value18 = JSONParser(jsonObject.fieldName18, jsonToParse, jsonObject.ignore_error);
            result.Value19 = JSONParser(jsonObject.fieldName19, jsonToParse, jsonObject.ignore_error);
            result.Value20 = JSONParser(jsonObject.fieldName20, jsonToParse, jsonObject.ignore_error);
            results.add(result);
        }

        return results;
    }
    
	private static String JSONParser(String fieldName, Object jsonToParse, Boolean ignore_error) {
        String result;
        if(fieldName != null && ignore_error == True){
            try{
                result = mapParser(fieldName, jsonToParse);
            }
            catch(exception e){
                result = '[Error] : '+ e.getMessage();}
        }
        else if (fieldName != null && ignore_error == False){
            result = mapParser(fieldName, jsonToParse);
        }
        else{
            System.debug('No need to parse');
        }

     return result;   
    }
    
    private static String mapParser(String fieldName, Object jsonObject) {
       Object paramObject = null;
       Object JSONString = JSON.serialize(jsonObject);
       System.debug('Parsing: '+ JSONString);
       if (jsonObject instanceof List<Object> && fieldName != '') {
           System.debug('Detected as List');
           List<Object> theList = (List<Object>)jsonObject;
           Integer enclosureIndex = fieldName.indexOf(']');
           Integer listIndex = Integer.valueOf(fieldName.substring(1,enclosureIndex));
           paramObject = theList.get(listIndex);
           fieldName = fieldName.substring(enclosureIndex+1);
           return mapParser(fieldName, paramObject);           
       }
       if (jsonObject instanceof Map<String, Object> && fieldName != '') {
           System.debug('Detected as Map');
           Map<String, Object> theMap = (Map<String, Object>)jsonObject;
           Integer dotIndex=fieldName.indexOf('.');
           if (dotIndex<0) { dotIndex = fieldName.length(); }
           Integer listIndex=fieldName.indexOf('[');
           if (listIndex<0) { listIndex = fieldName.length(); }
           Integer earliestIndex = math.min(dotIndex, listIndex);
           String traversedFieldName = fieldName.substring(0,earliestIndex);    
           paramObject = theMap.get(traversedFieldName);
           if (earliestIndex+1>fieldName.length()) {
               fieldName ='';
           } else {
               fieldName = fieldName.substring(earliestIndex+1);
           }
           return mapParser(fieldName, paramObject);
       } else {
           if (jsonObject instanceof Map<String, Object> || jsonObject instanceof List<Object>) {
               return getStringValue(JSONString);}
           else{
               return getStringValue(jsonObject);
           }
       } 
    }

    private static String getStringValue(Object paramObject) {
        String result = null;
        if (paramObject instanceof String) { result = (String)paramObject;}
        else if (paramObject instanceof Integer) { result = String.valueOf((Integer)paramObject); }
        else if (paramObject instanceof Boolean) { result = String.valueOf((Boolean)paramObject); }
        else if (paramObject instanceof Decimal) { result = String.valueOf((Decimal)paramObject); }
        else if (paramObject instanceof Double) { result = String.valueOf((Double)paramObject); }
        else {
        System.debug('Unrecognized JSON object? Not string nor integer nor boolean?');
        return result;}
        System.debug('Base token: '+result);
        return result;
    }

    public class Request {
        @InvocableVariable(label='JSON para parsear' required=true)
        public String jsonStringToParse;
        @InvocableVariable(label='Ignorar erros?' required=true)
        public Boolean ignore_error;
        @InvocableVariable(label='Campo 01')
        public String fieldName1;
        @InvocableVariable(label='Campo 02')
        public String fieldName2;
        @InvocableVariable(label='Campo 03')
        public String fieldName3;
        @InvocableVariable(label='Campo 04')
        public String fieldName4;
        @InvocableVariable(label='Campo 05')
        public String fieldName5;
        @InvocableVariable(label='Campo 06')
        public String fieldName6;
        @InvocableVariable(label='Campo 07')
        public String fieldName7;
        @InvocableVariable(label='Campo 08')
        public String fieldName8;
        @InvocableVariable(label='Campo 09')
        public String fieldName9;
        @InvocableVariable(label='Campo 10')
        public String fieldName10;
        @InvocableVariable(label='Campo 11')
        public String fieldName11;
        @InvocableVariable(label='Campo 12')
        public String fieldName12;
        @InvocableVariable(label='Campo 13')
        public String fieldName13;
        @InvocableVariable(label='Campo 14')
        public String fieldName14;
        @InvocableVariable(label='Campo 15')
        public String fieldName15;
        @InvocableVariable(label='Campo 16')
        public String fieldName16;
        @InvocableVariable(label='Campo 17')
        public String fieldName17;
        @InvocableVariable(label='Campo 18')
        public String fieldName18;
        @InvocableVariable(label='Campo 19')
        public String fieldName19;
        @InvocableVariable(label='Campo 20')
        public String fieldName20;
    }

    public class ResultValue {
        @InvocableVariable(label='Valor 01')
        public String Value01;
        @InvocableVariable(label='Valor 02')
        public String Value02;
        @InvocableVariable(label='Valor 03')
        public String Value03;
        @InvocableVariable(label='Valor 04')
        public String Value04;
        @InvocableVariable(label='Valor 05')
        public String Value05;
        @InvocableVariable(label='Valor 06')
        public String Value06;
        @InvocableVariable(label='Valor 07')
        public String Value07;
        @InvocableVariable(label='Valor 08')
        public String Value08;
        @InvocableVariable(label='Valor 09')
        public String Value09;
        @InvocableVariable(label='Valor 10')
        public String Value10;
        @InvocableVariable(label='Valor 11')
        public String Value11;
        @InvocableVariable(label='Valor 12')
        public String Value12;
        @InvocableVariable(label='Valor 13')
        public String Value13;
        @InvocableVariable(label='Valor 14')
        public String Value14;
        @InvocableVariable(label='Valor 15')
        public String Value15;
        @InvocableVariable(label='Valor 16')
        public String Value16;
        @InvocableVariable(label='Valor 17')
        public String Value17;
        @InvocableVariable(label='Valor 18')
        public String Value18;
        @InvocableVariable(label='Valor 19')
        public String Value19;
        @InvocableVariable(label='Valor 20')
        public String Value20;
    }
}