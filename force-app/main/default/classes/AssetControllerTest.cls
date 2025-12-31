@isTest
public class AssetControllerTest {
    
    @isTest
    public static void getCartaoContactlessEnabled(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

        Asset ass1 = new Asset();
        ass1.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass1.NumeroCartao__c = '5438821131329799'; 
        ass1.CPF__c = '12345678912'; 
        ass1.ContaFinanceira__c = cf.Id;
        ass1.Name = 'Cartão'; 
        ass1.CartaoPrimario__c = true;
        ass1.Product2Id = produto.Id;
        ass1.Contactless__c = true;
        ass1.Status = 'NORM';
        ass1.CartaoSernoId__c = '956199';
        insert ass1;

        Asset ass2 = new Asset();
        ass2.NomeReduzido__c = 'FELICIA B ANDRADE'; 
        ass2.NumeroCartao__c = '5438821131329788'; 
        ass2.CPF__c = '12345678924'; 
        ass2.ContaFinanceira__c = cf.Id;
        ass2.Name = 'Cartão'; 
        ass2.CartaoPrimario__c = false;
        ass2.Product2Id = produto.Id;
        ass2.Contactless__c = true;
        ass2.Status = 'LOST';
        ass2.CartaoSernoId__c = '956197';
        insert ass2;

        Test.startTest();
        List<AssetBO.AssetTO> result = AssetController.getAllAtivos(cf.Id);
        Test.stopTest();

        System.AssertEquals(2, result.size());
    }

    @isTest
    public static void CreateCaseTest(){

        Test.StartTest();
        List<ChaveLigaDesligaBO.ChaveTO> chaves = AssetController.getAllButtonsAssets();
        Test.StopTest();

        System.assertNotEquals(null, chaves);
    }
}