@isTest
public class ConsultaProtocolosTest {
    
    @isTest
    public static void ClienteComProtocolosTest() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'BCSF SAC' LIMIT 1];
        Date today = Date.today();
        Date yesterday = Date.today().addDays(-1);
        
        Account acc = new Account();
        acc.Name = 'FABIANO SOUZA';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '37000137895';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;
        
        Case caso1 = new Case();
        caso1.RecordTypeId = rt.Id;
        caso1.Origin = 'SAC';
        caso1.Type = 'Solicitação';
        caso1.Status = 'New';
        caso1.ContaFinanceira__c = cf.Id;
        caso1.Assunto__c = 'Cobrança';
        caso1.Evento__c = 'Dúvidas sobre Negativação';
        caso1.CreatedDate = yesterday;
        insert caso1;
        Case caso2 = new Case();
        caso2.RecordTypeId = rt.Id;
        caso2.Origin = 'SAC';
        caso2.Type = 'Execução';
        caso2.Status = 'New';
        caso2.ContaFinanceira__c = cf.Id;
        caso2.Assunto__c = 'Cobrança';
        caso2.Evento__c = 'Dúvidas sobre Negativação';
        caso2.CreatedDate = today;
        insert caso2;
        
        Case caso3 = new Case();
        caso3.RecordTypeId = rt.Id;
        caso3.Origin = 'SAC';
        caso3.Type = 'Reclamação';
        caso3.Status = 'New';
        caso3.ContaFinanceira__c = cf.Id;
        caso3.Assunto__c = 'Cobrança';
        caso3.Evento__c = 'Dúvidas sobre Negativação';
        caso3.CreatedDate = today;
        insert caso3;
        
        System.System.debug(caso1);
        System.System.debug(caso2);
        System.System.debug(caso3);
        InterfaceConsultaProtocolos.RequestConsultaProtocolos request = new InterfaceConsultaProtocolos.RequestConsultaProtocolos();
        request.numeroConta = '37000137895';
        request.origens = 'SAC,Pós Vendas,Chatbot,Intercâmbio,Cobrança';
        request.status = 'New,Em tratativa,Closed';
        request.tipos = 'Solicitação,Reclamação';
        request.quantidade = '6';
        request.offset = '0';
        
        List<InterfaceConsultaProtocolos.RequestConsultaProtocolos> parametersRequest = new List<InterfaceConsultaProtocolos.RequestConsultaProtocolos>();
        parametersRequest.add(request);
        
        Test.startTest();
        List<InterfaceConsultaProtocolos.ResponseConsultaProtocolos> response = InterfaceConsultaProtocolos.InterfaceConsultaProtocolos(parametersRequest);
        Test.stopTest();
        
        List<Case> cases = [SELECT CaseNumber FROM Case WHERE Id IN (:caso1.Id, :caso3.Id) ORDER BY CaseNumber LIMIT 2];
        
        String protocoloOntem = cases.get(0).CaseNumber + ' - ' + caso1.CreatedDate.format('dd/MM');
        String protocoloHoje = cases.get(1).CaseNumber + ' - ' + caso3.CreatedDate.format('dd/MM');
        InterfaceConsultaProtocolos.ResponseConsultaProtocolos protocolosResponse = response.get(0);
        System.assertEquals(0, protocolosResponse.numeroProcotolos);
    }
    
    @isTest
    public static void ConsultaDadosProtocoloTest() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'BCSF SAC' LIMIT 1];
        Date today = Date.today();
        
        Account acc = new Account();
        acc.Name = 'FABIANO SOUZA';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '37000137895';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;
        
        Case caso1 = new Case();
        caso1.RecordTypeId = rt.Id;
        caso1.Origin = 'SAC';
        caso1.Type = 'Solicitação';
        caso1.Status = 'Closed';
        caso1.ContaFinanceira__c = cf.Id;
        caso1.Assunto__c = 'Cobrança';
        caso1.Evento__c = 'Dúvidas sobre Negativação';
        caso1.CreatedDate = today;
        insert caso1;
        
        List<Case> cases = [SELECT CaseNumber FROM Case WHERE Id IN (:caso1.Id) ORDER BY CaseNumber];
        
        String prot = cases.get(0).CaseNumber + ' - ' + caso1.CreatedDate.format('dd/MM');
        List<String> listProt = new List<String>();
        listProt.add(prot);
        
        InterfaceConsultaDadosProtocolo.RequestConsultaDadosProtocolo requestConsulta = new InterfaceConsultaDadosProtocolo.RequestConsultaDadosProtocolo();
        requestConsulta.listaProtocolos = listProt;
        requestConsulta.idsProtocolos = '' + cases.get(0).Id;
        requestConsulta.protocolo = prot;
        
        List<InterfaceConsultaDadosProtocolo.RequestConsultaDadosProtocolo> parametersRequestConsulta = new List<InterfaceConsultaDadosProtocolo.RequestConsultaDadosProtocolo>();
        parametersRequestConsulta.add(requestConsulta);
        
        
        Test.startTest();
        List<InterfaceConsultaDadosProtocolo.ResponseConsultaDadosProtocolo> responseConsulta = InterfaceConsultaDadosProtocolo.consultaDadosProtocolo(parametersRequestConsulta);
        InterfaceConsultaDadosProtocolo.ResponseConsultaDadosProtocolo dadosProtocolo = responseConsulta.get(0);
        Test.stopTest();
        
        System.assertEquals('Dúvidas sobre Negativação', dadosProtocolo.evento);
        System.assertEquals('Cobrança', dadosProtocolo.assunto);
        System.assertEquals('Concluído', dadosProtocolo.status);
        System.assertEquals(caso1.CreatedDate.format('dd/MM/yyyy'), dadosProtocolo.dataCriacao);
    }
    
}