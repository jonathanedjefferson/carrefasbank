/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - RetornaValoresPlanoAcordoDividas                            100%  *
**************************************************************************/

@isTest
public class RetornaValoresPlanoAcordoDividasTest {

    @isTest
    public static void retornaValoresParcelaPrimeiraOpcaoTest() {
        
        RetornaValoresPlanoAcordoDividas.InputValores requestPlanoselecionado = new RetornaValoresPlanoAcordoDividas.InputValores();   
        requestPlanoselecionado.acordoOpcaoSelecionada = '1 parcela de R$36,63';
        requestPlanoselecionado.idsPlanosAcordo = '1;9;10;11;12;13;';
        requestPlanoselecionado.valoresPlanosAcordo = '36,63;6,09;5,49;5,01;4,6;5,12;';
        requestPlanoselecionado.identificadoresPlanosAcordo = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwbYQqmQ7za+P0BplEVl3U8=;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRx/JoeFDTpRUZUtYUXaElMdE36OGzz7wnw3ws2gVS1K3;';
        requestPlanoselecionado.identificadoresPlanosAcordo2 = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRw/UkwYv/dxvKhQCgJ8p94QcVFcYTcNjpiErvTbsk2q5;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3;';
       requestPlanoselecionado.descontosPlanosAcordo = 'R$33,8(88%);R$50,71(82%);R$50,71(82%);R$50,71(82%);R$50,71(82%);R$61,97(78%);';
            
        
        List<RetornaValoresPlanoAcordoDividas.InputValores> requestPlanoList = new List<RetornaValoresPlanoAcordoDividas.InputValores>();
        requestPlanoList.add(requestPlanoselecionado);
        
        Test.StartTest();
        List<RetornaValoresPlanoAcordoDividas.OutputValores> retornoDatas = RetornaValoresPlanoAcordoDividas.RetornaValoresPlanoAcordo(requestPlanoList);
        Test.StopTest();
        
                
        RetornaValoresPlanoAcordoDividas.OutputValores retorno = retornoDatas[0];
        System.AssertEquals('1', retorno.numeroParcelaPlanoAcordo);
        System.AssertEquals('R$36,63', retorno.valorPlanoAcordo);
        System.AssertEquals('R$33,8(88%)', retorno.descontoPlanoAcordo);
        System.AssertEquals('QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=', retorno.identificadorPlanoAcordo);
        System.AssertEquals('R$36,63', retorno.valorFinalPlanoAcordo);
    }
    
    @isTest
    public static void retornaValoresParcelaUltimaOpcaoTest() {
        
        RetornaValoresPlanoAcordoDividas.InputValores requestPlanoselecionado = new RetornaValoresPlanoAcordoDividas.InputValores();   
        requestPlanoselecionado.acordoOpcaoSelecionada = '13 parcelas de R$5,12';
        requestPlanoselecionado.idsPlanosAcordo = '1;9;10;11;12;13;';
        requestPlanoselecionado.valoresPlanosAcordo = '36,63;6,09;5,49;5,01;4,6;5,12;';
        requestPlanoselecionado.identificadoresPlanosAcordo = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwbYQqmQ7za+P0BplEVl3U8=;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRx/JoeFDTpRUZUtYUXaElMdE36OGzz7wnw3ws2gVS1K3;';
        requestPlanoselecionado.identificadoresPlanosAcordo2 = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRw/UkwYv/dxvKhQCgJ8p94QcVFcYTcNjpiErvTbsk2q5;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3;';
       requestPlanoselecionado.descontosPlanosAcordo = 'R$33,8(88%);R$50,71(82%);R$50,71(82%);R$50,71(82%);R$50,71(82%);R$61,97(78%);';
            
        
        List<RetornaValoresPlanoAcordoDividas.InputValores> requestPlanoList = new List<RetornaValoresPlanoAcordoDividas.InputValores>();
        requestPlanoList.add(requestPlanoselecionado);
        
        Test.StartTest();
        List<RetornaValoresPlanoAcordoDividas.OutputValores> retornoDatas = RetornaValoresPlanoAcordoDividas.RetornaValoresPlanoAcordo(requestPlanoList);
        Test.StopTest();
        
                
        RetornaValoresPlanoAcordoDividas.OutputValores retorno = retornoDatas[0];
        System.AssertEquals('13', retorno.numeroParcelaPlanoAcordo);
        System.AssertEquals('R$5,12', retorno.valorPlanoAcordo);
        System.AssertEquals('R$61,97(78%)', retorno.descontoPlanoAcordo);
        System.AssertEquals('QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3', retorno.identificadorPlanoAcordo);
        System.AssertEquals('R$66,56', retorno.valorFinalPlanoAcordo);
    }
    
    @isTest
    public static void retornaValoresParcelaInexistenteTest() {
        
        RetornaValoresPlanoAcordoDividas.InputValores requestPlanoselecionado = new RetornaValoresPlanoAcordoDividas.InputValores();   
        requestPlanoselecionado.acordoOpcaoSelecionada = '40 parcelas de R$500,12'; // parcela inexistente
        requestPlanoselecionado.idsPlanosAcordo = '1;9;10;11;12;13;';
        requestPlanoselecionado.valoresPlanosAcordo = '36,63;6,09;5,49;5,01;4,6;5,12;';
        requestPlanoselecionado.identificadoresPlanosAcordo = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwbYQqmQ7za+P0BplEVl3U8=;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRx/JoeFDTpRUZUtYUXaElMdE36OGzz7wnw3ws2gVS1K3;';
        requestPlanoselecionado.identificadoresPlanosAcordo2 = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRw/UkwYv/dxvKhQCgJ8p94QcVFcYTcNjpiErvTbsk2q5;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid;QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3;';
       requestPlanoselecionado.descontosPlanosAcordo = 'R$33,8(88%);R$50,71(82%);R$50,71(82%);R$50,71(82%);R$50,71(82%);R$61,97(78%);';
            
        List<RetornaValoresPlanoAcordoDividas.InputValores> requestPlanoList = new List<RetornaValoresPlanoAcordoDividas.InputValores>();
        requestPlanoList.add(requestPlanoselecionado);
        
        Test.StartTest();
        List<RetornaValoresPlanoAcordoDividas.OutputValores> retornoDatas = RetornaValoresPlanoAcordoDividas.RetornaValoresPlanoAcordo(requestPlanoList);
        Test.StopTest();
        
                
        RetornaValoresPlanoAcordoDividas.OutputValores retorno = retornoDatas[0];
        System.AssertEquals(null, retorno.numeroParcelaPlanoAcordo);
        System.AssertEquals(null, retorno.valorPlanoAcordo);
        System.AssertEquals(null, retorno.descontoPlanoAcordo);
        System.AssertEquals(null, retorno.identificadorPlanoAcordo);
        System.AssertEquals(null, retorno.valorFinalPlanoAcordo);
        
    }
    
    
}