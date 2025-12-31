@isTest
public class HomeMultiProdutoTest {
    @isTest
    public static void getContasFinanceirasTest() {
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        cf.UnidadeNegocio__c = '2';
        insert cf;

        Test.startTest();
        List<ContaFinanceira__c> listCf = HomeMultiProdutoController.getContasFinanceiras(acc.Id);
        Test.stopTest();

        System.assertEquals(1, listCf.size());
        System.assertEquals(listCf[0].NumeroConta__c, '11111111111');
        System.assertEquals(listCf[0].StatusConta__c, 'NORM');
        System.assertEquals(listCf[0].UnidadeNegocio__c, '2');
    }
}