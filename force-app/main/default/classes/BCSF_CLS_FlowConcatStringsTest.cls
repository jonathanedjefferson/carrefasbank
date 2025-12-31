@isTest
public with sharing class BCSF_CLS_FlowConcatStringsTest {
    @isTest
    static void shouldConcatStringList(){
        List<String> stringList = new List<String>{'value1','value2','value3'};

        List<String> result = BCSF_CLS_FlowConcatStrings.concatStringList(new List<List<String>>{stringList});

        String expected = 'value1;value2;value3';

        System.assertEquals(expected, result[0], 'O metodo de concatenacao de strings nao funcionou como deveria.');
    }
}