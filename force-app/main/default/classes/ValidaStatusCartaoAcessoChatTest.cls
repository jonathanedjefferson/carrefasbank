/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - ValidaStatusCartaoAcessoChatDAO                 100%              *
*    - ValidaStatusCartaoAcessoChatHelper              100%              *
**************************************************************************/
@isTest
public class ValidaStatusCartaoAcessoChatTest {
    @isTest
    public static void ValidarStatusTest() {
        List<ValidaStatusCartaoAcessoChatHelper.Input> listInput = new List<ValidaStatusCartaoAcessoChatHelper.Input>();
        ValidaStatusCartaoAcessoChatHelper.Input input = new ValidaStatusCartaoAcessoChatHelper.Input();
        input.StatusCartaoCliente = 'NORM';
        input.LabelsMetadado = 'ComAcessoATC;SemAcessoAppChatATC;SemAcessoAppComAcessoChatATC';
        listInput.add(input);

        Test.StartTest();
        List<ValidaStatusCartaoAcessoChatHelper.Output> retorno = ValidaStatusCartaoAcessoChatHelper.ValidarStatus(listInput);
        Test.StopTest();

        System.AssertEquals(retorno[0].ComAcesso, true);
        System.AssertEquals(retorno[0].SemAcessoAppChat, false);
        System.AssertEquals(retorno[0].SemAcessoAppComAcessoChat, false);
    }
}