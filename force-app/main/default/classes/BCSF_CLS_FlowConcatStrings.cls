global with sharing class BCSF_CLS_FlowConcatStrings {
    @InvocableMethod
    global static List<String> concatStringList(List<List<String>> stringListList){
        String result = '';
        List<String> stringList = stringListList[0];
        
        for(String value : stringList){
            if(result == ''){
                result = value;
            } else{
                result += ';' + value;
            }
        }

        return new List<String>{result};
    }
}