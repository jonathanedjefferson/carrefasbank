/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR A CLASSE ABAIXO:               *
*    - disabeCustomerInactiveButtonController                 100%       *
**************************************************************************/

@isTest
public with sharing class disabeCustomerInactiveButtonTest {
    @isTest
    public static void getStaticRessourceTest() {
        Test.startTest();
        String retorno = disabeCustomerInactiveButtonController.getStaticRessource();
        retornoTestTO retornoObj = (retornoTestTO) System.JSON.deserialize(retorno, retornoTestTO.class);
        Test.stopTest();

        System.assertEquals(retornoObj.xpath[0], '//span[text()=\'Customer Inactive\']');
        System.assertEquals(retornoObj.xpath[1], '//span[text()=\'Cliente inativo\']');
        System.assertEquals(retornoObj.xpath[2], '//input[@value=\'inactivate\']');
    }


    public class retornoTestTO{
        List<String> xpath {get;set;}
    }
}