/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - CpfValidation                              98%                    *
**************************************************************************/
@isTest
public class CpfValidationTest {
    @isTest
    public static void ValidarCpfTest(){
        List<String> listCpf = new List<String>();
        listCpf.add('861.371.650-43');
        listCpf.add('52902243006');     
        listCpf.add('512 772 810 92');     
        listCpf.add('11111111111');
        listCpf.add('Testando123');
        listCpf.add('123456');

        Test.StartTest();
        List<CpfValidation.OutputValidacao> retorno = CpfValidation.BotValidaCpf(listCpf);
        Test.StopTest();

        System.AssertEquals(true, retorno[0].cpfValido);
        System.AssertEquals('86137165043', retorno[0].cpfFormatado);

        System.AssertEquals(true, retorno[1].cpfValido);
        System.AssertEquals('52902243006', retorno[1].cpfFormatado);

        System.AssertEquals(true, retorno[2].cpfValido);
        System.AssertEquals('51277281092', retorno[2].cpfFormatado);

        System.AssertEquals(false, retorno[3].cpfValido);
        System.AssertEquals(null, retorno[3].cpfFormatado);

        System.AssertEquals(false, retorno[4].cpfValido);
        System.AssertEquals(null, retorno[4].cpfFormatado);
        
        System.AssertEquals(false, retorno[5].cpfValido);
        System.AssertEquals(null, retorno[5].cpfFormatado);
    }
}