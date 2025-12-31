/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceBancosDebitoAutomatico                             100%           *
**************************************************************************/

@isTest
public class InterfaceBancosDebitoAutomaticoTest {

    @isTest
    public static void obterBancos() {
        InterfaceBancosDebitoAutomatico.RequestConsultarBancos request = new InterfaceBancosDebitoAutomatico.RequestConsultarBancos();      
        request.itemMenu1 = 'Nenhum dos anteriores';
        
        List<InterfaceBancosDebitoAutomatico.RequestConsultarBancos> requestList = new List<InterfaceBancosDebitoAutomatico.RequestConsultarBancos>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceBancosDebitoAutomatico.ResponseConsultarBancos> retorno = InterfaceBancosDebitoAutomatico.ObterBancosDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        List<String> bancos = retorno.get(0).bancos;
        System.AssertNotEquals(null, bancos.get(0));
    }
    
    @isTest
    public static void obterBancosNenhumaDasOpcoes() {
        InterfaceBancosDebitoAutomatico.RequestConsultarBancos request = new InterfaceBancosDebitoAutomatico.RequestConsultarBancos();      
        request.itemMenu1 = 'Quero sugerir outro banco';
        request.itemMenu2 = 'Voltar para o menu anterior';
        
        List<InterfaceBancosDebitoAutomatico.RequestConsultarBancos> requestList = new List<InterfaceBancosDebitoAutomatico.RequestConsultarBancos>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceBancosDebitoAutomatico.ResponseConsultarBancos> retorno = InterfaceBancosDebitoAutomatico.ObterBancosDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        List<String> bancos = retorno.get(0).bancos;
        System.AssertNotEquals(null, bancos.get(0));
    }  
}