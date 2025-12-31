/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BCSF_CLS_FlowIdentificaClienteAPI     95%                         *
*    - BCSF_CLS_IdentificaClienteAPI         100%                        *
*    - CarrefourAPICalloutDAO                100%                        *
*    - IdentificaClienteTO                   100%                        *
**************************************************************************/
@isTest
public class FlowIdentificaClienteAPITest {
    @isTest
    public static void identificaClienteTest() {
        List<BCSF_CLS_FlowIdentificaClienteAPI.Input> listInput = new List<BCSF_CLS_FlowIdentificaClienteAPI.Input>();
        Test.setMock(HttpCalloutMock.class, new FlowIdentificaClienteAPIHttpCalloutMock());
        HttpResponse response = Util.executarHttpRequest('String strEndPoint', 'POST', new Map<String, String>(), 'String strBody', 40000);
        
        BCSF_CLS_FlowIdentificaClienteAPI.Input input = new BCSF_CLS_FlowIdentificaClienteAPI.Input();
        input.chaveToken = 'TestToken';
        input.cpf = '12345678978';
        input.telefone = '11991055985';
        input.unidadeNegocio = 'CSF';
        listInput.add(input);

        Test.StartTest();
        List<BCSF_CLS_FlowIdentificaClienteAPI.Output> Output = BCSF_CLS_FlowIdentificaClienteAPI.identificaCliente(listInput);
        Test.StopTest();

        System.AssertEquals(1, Output.size());
    }

    @isTest
    public static void identificaCliente72Test() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"data": {"cliente": {"dadosSociais": [{"nomePrimeiro": "DANILO","nomeUltimo": "BRAZ","nomeSocial": "MR","dataDeNascimento": "1966-07-31T03:00:00Z","nomeCompleto": "DANILO BRAZ","numeroConta": "00033148004","tipoEnvioFatura": "2"},{"nomePrimeiro": "DANILO BRAZ","nomeMeio": "","nomeUltimo": "","nomeSocial": "","dataDeNascimento": "1966-07-31T00:00:00-03:00","nomeCompleto": "DANILO BRAZ","numeroConta": "10047481535","tipoEnvioFatura": ""}],"contaCartao": {"contratos": [{"diaVencimento": 0,"classificacaoStatusConta": 0,"valorLimiteTotal": 0,"valorLimiteDisponivel": 0,"numeroContaSerno": "1","cartoes": [],"numeroConta": "10047481535","unidadeNegocio": "ATC","codigoProdutoCurto": "","dataAberturaConta": "","statusConta": "72"}]},"contato": {"dadosContato": [{"numeroConta": "10047481535","telefones": [{"ddd": "01","numero": "14173226","celularSeguro": false}],"emails": [{"endereco": ""},{"endereco": "joao_victor_rocha_dos_santos_ext@carrefour.com"}]}]},"cpf": "05272472854"}}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/whatsapp' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BCSF_CLS_FlowIdentificaClienteAPI.Input> listInput = new List<BCSF_CLS_FlowIdentificaClienteAPI.Input>();
        BCSF_CLS_FlowIdentificaClienteAPI.Input input = new BCSF_CLS_FlowIdentificaClienteAPI.Input();
        input.chaveToken = 'TestToken';
        input.cpf = '04272472844';
        input.telefone = '1188887777';
        input.unidadeNegocio = 'ATC';
        listInput.add(input);
        
        Test.StartTest();
        List<BCSF_CLS_FlowIdentificaClienteAPI.Output> retornoList = BCSF_CLS_FlowIdentificaClienteAPI.identificaCliente(listInput);
        Test.StopTest();

        BCSF_CLS_FlowIdentificaClienteAPI.Output retorno = retornoList[0];
        System.AssertEquals('10047481535', retorno.NumeroConta);
        System.assertEquals('72', retorno.StatusConta);
        System.assertEquals('(••) ••••-7777', retorno.TelefoneMascarado);
    }

    @isTest
    public static void identificaClienteDuasContasMesmaBUTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"data": {"cliente": {"dadosSociais": [{"nomePrimeiro": "DANILO","nomeUltimo": "BRAZ","nomeSocial": "MR","dataDeNascimento": "1966-07-31T03:00:00Z","nomeCompleto": "DANILO BRAZ","numeroConta": "00033148004","tipoEnvioFatura": "2"},{"nomePrimeiro": "DANILO BRAZ","nomeMeio": "","nomeUltimo": "","nomeSocial": "","dataDeNascimento": "1966-07-31T00:00:00-03:00","nomeCompleto": "DANILO BRAZ","numeroConta": "00033148006","tipoEnvioFatura": ""}],"contaCartao": {"contratos": [{"diaVencimento": 10,"classificacaoStatusConta": 0,"valorLimiteTotal": 40000,"valorLimiteDisponivel": 25713.47,"numeroContaSerno": "2057517","cartoes": [{"vencimentoCartao": "2028-12-31T00:00:00.000-03:00","id": "18350776","numeroCartao": "5300.XXXX.XXXX.6940","statusCartao": "CLSC","tipoTitularidade": "TITULAR","nomePortador": "DANILO BRAZ","ehPrimario": true,"ehAtivo": false,"ehVirtual": false}],"numeroConta": "00033148006","unidadeNegocio": "CSF","codigoProdutoCurto": "AMFIN","dataAberturaConta": "2004-12-18","statusConta": "CLSC"},{"diaVencimento": 8,"classificacaoStatusConta": 0,"valorLimiteTotal": 22910,"valorLimiteDisponivel": 14713.47,"numeroContaSerno": "2057516","cartoes": [{"vencimentoCartao": "2024-04-30T00:00:00.000-03:00","id": "27698503","numeroCartao": "5300.XXXX.XXXX.5360","statusCartao": "NORM","tipoTitularidade": "DEPENDENTE","nomePortador": "SIRLENE DA SILVA","ehPrimario": false,"ehAtivo": true,"ehVirtual": false},{"vencimentoCartao": "2028-12-31T00:00:00.000-03:00","id": "18350775","numeroCartao": "5300.XXXX.XXXX.6940","statusCartao": "NORM","tipoTitularidade": "TITULAR","nomePortador": "DANILO BRAZ","ehPrimario": true,"ehAtivo": true,"ehVirtual": false}],"numeroConta": "00033148004","unidadeNegocio": "CSF","codigoProdutoCurto": "AMFIN","dataAberturaConta": "2008-12-18","statusConta": "NORM"}]},"contato": {"dadosContato": [{"numeroConta": "00033148004","telefones": [{"ddd": "11","numero": "37796000","celularSeguro": false},{"ddd": "11","numero": "973382297","celularSeguro": true},{"ddd": "11","numero": "41732260","celularSeguro": false}],"emails": [{"endereco": "danilo_sbr@yahoo.com.br"}]},{"numeroConta": "00033148006","telefones": [{"ddd": "01","numero": "19733822","celularSeguro": false}],"emails": [{"endereco": "boleto.acordes@gmail.com"}]}]},"cpf": "04272472844"}}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/whatsapp' => response 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<BCSF_CLS_FlowIdentificaClienteAPI.Input> listInput = new List<BCSF_CLS_FlowIdentificaClienteAPI.Input>();
        BCSF_CLS_FlowIdentificaClienteAPI.Input input = new BCSF_CLS_FlowIdentificaClienteAPI.Input();
        input.chaveToken = 'TestToken';
        input.cpf = '04272472844';
        input.telefone = '11991055986';
        input.unidadeNegocio = 'CSF';
        listInput.add(input);
        
        Test.StartTest();
        List<BCSF_CLS_FlowIdentificaClienteAPI.Output> retornoList = BCSF_CLS_FlowIdentificaClienteAPI.identificaCliente(listInput);
        Test.StopTest();

        BCSF_CLS_FlowIdentificaClienteAPI.Output retorno = retornoList[0];
        System.AssertEquals('00033148004', retorno.NumeroConta);
        System.assertEquals('NORM', retorno.StatusConta);
        System.assertEquals('(••) •••••-5986', retorno.TelefoneMascarado);
    }   

    @isTest
    public static void IdentificaClienteTOTest(){
        IdentificaClienteTO.DadosTO dadosTo =  new IdentificaClienteTO.DadosTO();
        IdentificaClienteTO.DadosGeraisTO DadosGeraisTO =  new IdentificaClienteTO.DadosGeraisTO();
        IdentificaClienteTO.ClienteTO ClienteTO =  new IdentificaClienteTO.ClienteTO();
        IdentificaClienteTO.DadosSociaisTO DadosSociaisTO =  new IdentificaClienteTO.DadosSociaisTO();
        IdentificaClienteTO.ContaCartaoTO ContaCartaoTO =  new IdentificaClienteTO.ContaCartaoTO();
        IdentificaClienteTO.ContratoTO ContratoTO =  new IdentificaClienteTO.ContratoTO();
        IdentificaClienteTO.ContatoTO ContatoTO =  new IdentificaClienteTO.ContatoTO();
        IdentificaClienteTO.DadosContatoTO DadosContatoTO =  new IdentificaClienteTO.DadosContatoTO();
        IdentificaClienteTO.EmailTO EmailTO =  new IdentificaClienteTO.EmailTO();
        IdentificaClienteTO.TelefoneTO TelefoneTO =  new IdentificaClienteTO.TelefoneTO();
    }
}