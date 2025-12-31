/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ParseTelefone                              100%                   *
*    - ParseEmail                                 100%                   *
**************************************************************************/

@isTest
public class ParseTelefoneEmailTest {
    @isTest
    public static void getTelefoneTest() {
        List<String> listInput = new List<String>();
        String input = '[{"emails":[{"endereco":"teste@gmail.com"}],"telefones":[{"celularSeguro":false,"numero":"994268795","ddd":"19"},{"celularSeguro":false,"numero":"33334444","ddd":"11"},{"celularSeguro":false,"numero":"44443333","ddd":"11"},{"celularSeguro":true,"numero":"932761946","ddd":"11"}],"numeroConta":"37000001646"}]';
        listInput.add(input);

        Test.StartTest();
        List<ParseTelefone.Output> retorno = ParseTelefone.GetCelularSeguro(listInput);
        Test.StopTest();

        System.AssertEquals(retorno[0].CelularSeguro, true);
        System.AssertEquals(retorno[0].NumeroCelular, '(11)932761946');
    }

    @isTest
    public static void getEmailTest() {
        List<String> listInput = new List<String>();
        String input = '[{"emails":[{"endereco":"teste@gmail.com"}],"telefones":[{"celularSeguro":false,"numero":"994268795","ddd":"19"},{"celularSeguro":false,"numero":"33334444","ddd":"11"},{"celularSeguro":false,"numero":"44443333","ddd":"11"},{"celularSeguro":true,"numero":"932761946","ddd":"11"}],"numeroConta":"37000001646"}]';
        listInput.add(input);

        Test.StartTest();
        List<ParseEmail.Output> retorno = ParseEmail.GetEmail(listInput);
        Test.StopTest();

        System.AssertEquals(retorno[0].email, 'teste@gmail.com');
        System.AssertEquals(retorno[0].emailMascarado, 'tes**@gmail.com');
    }
}