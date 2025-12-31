@IsTest
public class FlowDetalhesChamadosTest {
    @IsTest
    public static void testChamarDetalhesChamados() {
        // Cenário de teste
        String CPF = '35330227810';
        
        // Mock do callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Executa o método a ser testado
        FlowDetalhesChamados.Input input = new FlowDetalhesChamados.Input();
        input.CPF = CPF;
        input.email = 'teste';
        input.period = '-1';
        input.startPeriod = Date.today() - 60;
        input.endPeriod = Date.today();
        List<FlowDetalhesChamados.Input> entrada = new List<FlowDetalhesChamados.Input>();
        entrada.add(input);
        List<List<FlowResponseProtocolo>> outputListAdd = FlowDetalhesChamados.chamarDetalhesChamados(entrada);
        
        // Verificações (Assertions)
        System.assertEquals(1, outputListAdd.size());
        
        List<FlowResponseProtocolo> outputList = outputListAdd[0];
        System.assertEquals(1, outputList.size());
        
        FlowResponseProtocolo output = outputList[0];
        System.assertEquals('Completed', output.status);
        
        // Verifica se o campo "statusPrazo" está correto
        Integer limiteDias = 3; // Defina o limite de dias para teste
        Datetime dtComTime = DateTime.valueOf(output.date_Z);
        Date dt = dtComTime.date();
        
        // Calcula a data de vencimento considerando apenas dias úteis
        Date dataVencimento = dt;
        Integer diasUteis = 0;
        Integer diasContados = 0;

        while (diasUteis < limiteDias) {
            dataVencimento = dataVencimento.addDays(1);
            if (isBusinessDay(dataVencimento)) {
                diasUteis++;
            }
            diasContados++;

            // Limita o número de iterações para evitar loops infinitos
            if (diasContados > limiteDias * 2) {
                break;
            }
        }

        // Verifica se a data atual está antes da data de vencimento
        if (System.today() <= dataVencimento) {
            System.assertEquals('Dentro do prazo', output.statusPrazo);
        } else {
            System.assertEquals('Fora do prazo', output.statusPrazo);
        }
    }
    
    // Método para verificar se um determinado dia é dia útil
    private static Boolean isBusinessDay(Date datee) {
        // Implemente sua lógica para verificar se o dia é dia útil
        // Exemplo: verificar se o dia não é sábado nem domingo
        
        return true; // Retorne true se for dia útil, ou false caso contrário
    }
    
    // Classe de mock para simular o callout HTTP
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Verifique a URL, headers e parâmetros da requisição se necessário
            
            // Crie uma resposta de exemplo
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"data":[{"Protocolo":123,"Status":"Completed","CategoryID": 388024,"Date_Z":"2022-01-01 08:57:50","DateUpdate":"2022-01-02 ","Resolution":1,"ProtocoloResolutionDate":"2022-01-03","ExpertFullName":"John Doe","StatusPrazo":"Dentro do Prazo","WorkflowStatus":1}]}');
            response.setStatusCode(200);
            
            return response;
        }
    }
}