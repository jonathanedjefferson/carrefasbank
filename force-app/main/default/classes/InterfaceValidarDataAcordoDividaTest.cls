/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceValidarDataAcordoDivida                            100%  *
**************************************************************************/

@isTest
public class InterfaceValidarDataAcordoDividaTest {

    @isTest
    public static void ObterDataAcordoTest() {
        
        InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo requestDatas = new InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo();   
        requestDatas.action = 'OBTER_DATA';
        
        List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo> requestDatasList = new List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo>();
        requestDatasList.add(requestDatas);
        
        Test.StartTest();
        List<InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo> retornoDatas = InterfaceValidarDataAcordoDivida.ValidarDataAcordoDivida(requestDatasList);
        Test.StopTest();
        
        String dataMinina =  Util.getDateAcordo(1);    
        String dataMaxima = Util.getDateAcordo(29);
                
        InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo retorno = retornoDatas[0];
        System.AssertEquals(dataMinina, retorno.dataMinina);
        System.AssertEquals(dataMaxima, retorno.dataMaxima);
    }
    
    @isTest
    public static void DataAcordoValidaTest() {
        
        String dataAcordo = Util.getDateAcordo(5);
        String diaAcordo = dataAcordo.split('/')[0];
        
        InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo requestDatas = new InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo();   
        requestDatas.action = 'VALIDAR_DATA';
        requestDatas.dataAcordo =  dataAcordo; // dentro do período
        
        
        List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo> requestDatasList = new List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo>();
        requestDatasList.add(requestDatas);
        
        Test.StartTest();
        List<InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo> retornoDatas = InterfaceValidarDataAcordoDivida.ValidarDataAcordoDivida(requestDatasList);
        Test.StopTest();
                    
        InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo retorno = retornoDatas[0];
        System.AssertEquals('S', retorno.dataValida);
        System.AssertEquals(diaAcordo, retorno.diaVencimentoAcordo);
    }
    
    @isTest
    public static void DataAcordoInvalidaTest() {
        
        InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo requestDatas = new InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo();   
        requestDatas.action = 'VALIDAR_DATA';
        requestDatas.dataAcordo =  Util.getDateAcordo(30); // fora do período
        
        List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo> requestDatasList = new List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo>();
        requestDatasList.add(requestDatas);
        
        Test.StartTest();
        List<InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo> retornoDatas = InterfaceValidarDataAcordoDivida.ValidarDataAcordoDivida(requestDatasList);
        Test.StopTest();
        
        InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo retorno = retornoDatas[0];
        System.AssertEquals('N', retorno.dataValida);
    }
    
    @isTest
    public static void DataAcordoNulaTest() {
        
        InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo requestDatas = new InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo();   
        requestDatas.action = 'VALIDAR_DATA';
        requestDatas.dataAcordo =  null; // data inválida
        
        List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo> requestDatasList = new List<InterfaceValidarDataAcordoDivida.RequestDatasIntervaloAcordo>();
        requestDatasList.add(requestDatas);
        
        Test.StartTest();
        List<InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo> retornoDatas = InterfaceValidarDataAcordoDivida.ValidarDataAcordoDivida(requestDatasList);
        Test.StopTest();
        
        InterfaceValidarDataAcordoDivida.ResponseDatasIntervaloAcordo retorno = retornoDatas[0];
        System.AssertEquals('N', retorno.dataValida);
    }
    
}