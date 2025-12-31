@isTest
public with sharing class NewLeadSamsClubTest {
    public class NewLeadSamsClubMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(201);
            return response;
        }
    }

    @isTest
    public static void testChamarFlowNewLead() {
        FlowNewLeadSamsClub.Input input = new FlowNewLeadSamsClub.Input();
        input.nome = 'John';
        input.sobrenome = 'Doe';
        input.email = 'testemail@email.com';
        input.telefone = '21232';
        input.cpf = '22134343';
        input.dataNascimento = Datetime.now();

        List<FlowNewLeadSamsClub.Input> lstEntrada = new List<FlowNewLeadSamsClub.Input>();
        lstEntrada.add(input);


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NewLeadSamsClubTest.NewLeadSamsClubMock());

        List<FlowNewLeadSamsClub.Output> outputList = FlowNewLeadSamsClub.cadastrarNovoLead(lstEntrada);
        Test.stopTest();

        System.assertEquals(1, outputList.size());
        FlowNewLeadSamsClub.Output output = outputList[0];
        System.assertEquals(output.statusCode, 201);
    }
}