@isTest
public class IdentificaCockpitControllerTest {
    
    /**
     * Atualiza Dados Sociais e Conta Financeira.
     */
    @isTest
    public static void atualizaContaPorCPF() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'NomeDesatualizado';
        acc.LastName = 'SobrenomeDesatualizado';
        acc.CPF__c = '48283917200';
        acc.NomeMae__c = 'NomeMaeDesatualizado';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '10000081470';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = '72';
        insert cf;

        Test.StartTest();
        Account contaAtualizada = IdentificaCockpitController.atualizaContaPorCPF(acc.Id, 'cockpit');
        Test.StopTest();

        List<ContaFinanceira__c> resultsContaFinanceiras = [SELECT NumeroConta__c, UnidadeNegocio__c, StatusConta__c FROM ContaFinanceira__c WHERE NomeCliente__c = :contaAtualizada.Id];
        ContaFinanceira__c contaFinanceiraAtualizada = resultsContaFinanceiras[0];

        System.assertEquals(1, resultsContaFinanceiras.size());
        System.assertEquals('M', contaAtualizada.Sexo__c);
        System.assertEquals('HELEN NASCIMENTO NUNES', contaAtualizada.NomeMae__c);
        System.assertEquals('GUSTAVO', contaAtualizada.FirstName);
        System.assertEquals('NASCIMENTO NUNES', contaAtualizada.LastName);
        System.assertEquals('10000081470', contaFinanceiraAtualizada.NumeroConta__c);
        System.assertEquals('2', contaFinanceiraAtualizada.UnidadeNegocio__c);
        System.assertEquals('NORM', contaFinanceiraAtualizada.StatusConta__c);
    }

    /**
     * Atualiza Dados Sociais e Conta Financeira, cenário sem o nome do meio e último nome.
     */
    @isTest
    public static void atualizaContaPorCPFSemNome() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF3');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'NomeDesatualizado';
        acc.LastName = 'SobrenomeDesatualizado';
        acc.CPF__c = '48283917200';
        acc.NomeMae__c = 'NomeMaeDesatualizado';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '10000081470';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = '72';
        insert cf;

        Test.StartTest();
        Account contaAtualizada = IdentificaCockpitController.atualizaContaPorCPF(acc.Id, 'cockpit');
        Test.StopTest();

        List<ContaFinanceira__c> resultsContaFinanceiras = [SELECT NumeroConta__c, UnidadeNegocio__c, StatusConta__c FROM ContaFinanceira__c WHERE NomeCliente__c = :contaAtualizada.Id];
        ContaFinanceira__c contaFinanceiraAtualizada = resultsContaFinanceiras[0];

        System.assertEquals(1, resultsContaFinanceiras.size());
        System.assertEquals('M', contaAtualizada.Sexo__c);
        System.assertEquals('HELEN NASCIMENTO NUNES', contaAtualizada.NomeMae__c);
        System.assertEquals('GUSTAVO', contaAtualizada.FirstName);
        System.assertEquals('GUSTAVO', contaAtualizada.LastName);
        System.assertEquals('10000081470', contaFinanceiraAtualizada.NumeroConta__c);
        System.assertEquals('2', contaFinanceiraAtualizada.UnidadeNegocio__c);
        System.assertEquals('NORM', contaFinanceiraAtualizada.StatusConta__c);
    }

    /**
     * Atualiza Conta Financeira existente e cria uma nova Conta Financeira Cashback.
     */
    @isTest
    public static void insereContaFinanceiraTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF2');
        // Mock com conta financeira e conta cashback.

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'NomeDesatualizado';
        acc.LastName = 'SobrenomeDesatualizado';
        acc.CPF__c = '32967501263';
        acc.NomeMae__c = 'NomeMaeDesatualizado';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '37000116170';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = '72';
        insert cf;

        Test.StartTest();
        Account contaAtualizada = IdentificaCockpitController.atualizaContaPorCPF(acc.Id, 'cockpit');
        Test.StopTest();

        ContaFinanceira__c contaCartao = [SELECT NumeroConta__c, UnidadeNegocio__c, StatusConta__c FROM ContaFinanceira__c WHERE NomeCliente__c = :contaAtualizada.Id AND NumeroConta__c != NULL LIMIT 1];
        ContaFinanceira__c contaCashback = [SELECT NumeroContrato__c, StatusContrato__c FROM ContaFinanceira__c WHERE NomeCliente__c = :contaAtualizada.Id AND NumeroContrato__c != NULL LIMIT 1];

        System.assertEquals('M', contaAtualizada.Sexo__c);
        System.assertEquals('ILDA SANTOS SILVA', contaAtualizada.NomeMae__c);
        System.assertEquals('JONAS', contaAtualizada.FirstName);
        System.assertEquals('SANTOS SILVA', contaAtualizada.LastName);
        System.assertEquals('37000116170', contaCartao.NumeroConta__c);
        System.assertEquals('1', contaCartao.UnidadeNegocio__c);
        System.assertEquals('NORM', contaCartao.StatusConta__c);
        System.assertEquals('cc01ce58-b784-4ad9-a068-59a30c84d158', contaCashback.NumeroContrato__c);
        System.assertEquals('Ativo', contaCashback.StatusContrato__c);
    }

    /**
     * Inseri 3 contas finaceiras Cartão.
     */
    @isTest
    public static void insereContasFinanceiraTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF4');
        // Mock com conta financeira e conta cashback.

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'NomeDesatualizado';
        acc.LastName = 'SobrenomeDesatualizado';
        acc.CPF__c = '00455134065';
        acc.NomeMae__c = 'NomeMaeDesatualizado';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        Test.StartTest();
        Account contaAtualizada = IdentificaCockpitController.atualizaContaPorCPF(acc.Id, 'cockpit');
        Test.StopTest();

        List<ContaFinanceira__c> listaContas = [SELECT NumeroConta__c, UnidadeNegocio__c, StatusConta__c FROM ContaFinanceira__c WHERE NomeCliente__c = :contaAtualizada.Id ORDER BY NumeroConta__c DESC];
        ContaFinanceira__c contaCartao = listaContas[0];

        System.assertEquals(3, listaContas.size());
        System.assertEquals('M', contaAtualizada.Sexo__c);
        System.assertEquals('ALICE BORGES CAMPOS', contaAtualizada.NomeMae__c);
        System.assertEquals('GABRIEL', contaAtualizada.FirstName);
        System.assertEquals('SANTOS', contaAtualizada.LastName);


        System.assertEquals('70000006604', contaCartao.NumeroConta__c);
        System.assertEquals('6', contaCartao.UnidadeNegocio__c);
        System.assertEquals('NORM', contaCartao.StatusConta__c);
    }

    /**
     * Conta não existente.
     */
    @isTest
    public static void contaNaoExistente() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        Account contaAtualizada = IdentificaCockpitController.atualizaContaPorCPF('9xDf9423trga', 'cockpit');
        Test.StopTest();

        System.assertEquals(null, contaAtualizada);
    }

    @isTest
    public static void atualizaContaSemSobrenome() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPFEmptyLastName');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('BCSF Cliente Pessoal Carrefour').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'NomeDesatualizado';
        acc.LastName = 'SobrenomeDesatualizado';
        acc.CPF__c = '02091277754';
        acc.NomeMae__c = 'NomeMaeDesatualizado';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        Test.StartTest();
        Account contaAtualizada = IdentificaCockpitController.atualizaContaPorCPF(acc.Id, 'cockpit');
        Test.StopTest();

        System.assertEquals('F', contaAtualizada.Sexo__c);
        System.assertEquals('BENEDITA LINDOSO FONSECA', contaAtualizada.NomeMae__c);
        System.assertEquals('DALETE', contaAtualizada.FirstName);
        System.assertEquals('GARCIA', contaAtualizada.LastName);
    }

}