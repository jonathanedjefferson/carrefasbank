@isTest
public with sharing class BCSF_CLS_FlowGetPhoneNumberTest {
    
    @isTest
    static void shouldGetFormatedNumber(){
        List<String> result = BCSF_CLS_FlowGetPhoneNumber.getFormatedNumber(new List<String>{'WhatsApp:+5511970705570'});
        String expected = '11970705570';

        System.assertEquals(result[0], expected, 'O metodo que deveria remover o texto "WhatsApp:+55" nao funcionou corretamente');
    }

    @isTest
    static void GetFormatedNumberNo55(){
        List<String> result = BCSF_CLS_FlowGetPhoneNumber.getFormatedNumber(new List<String>{'5511970705570'});
        System.assertEquals('11970705570', result[0]);
    }
}