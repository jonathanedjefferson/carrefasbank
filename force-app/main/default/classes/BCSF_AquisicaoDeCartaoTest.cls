@IsTest
private class BCSF_AquisicaoDeCartaoTest {
    @isTest
    private static void iniciarChatTestOK() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockIniciarChat');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
        
        input.idEmpresa = 1;
        input.numeroTelefone = '11999999999';
        input.actionName = 'IniciarchatBuscaProposta';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(1, lLstOutput.size());
        Assert.areEqual(200, output.statusCode);
        Assert.areEqual('3fa85f64-5717-4562-b3fc-2c963f66afa6', output.idProposta);
        Assert.areEqual('AprovadoAnaliseInicial', output.etapa);
        Assert.areEqual(1000.50, output.limite);
        Assert.areEqual('', output.nome);
    }

    @isTest
    private static void iniciarChatTestNOK() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
        
        input.idEmpresa = 1;
        input.numeroTelefone = '11999999999';
        input.actionName = 'IniciarchatBuscaProposta';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(1, lLstOutput.size());
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao buscar dados', output.message);
    }

    @isTest
    private static void atualizarDadosContatoOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.optinWhatsapp = true;
        input.email = 'teste@gmail.com';
        input.actionName = 'AtualizarDadosDeContato';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Contato atualizado', output.message);
    }

    @isTest
    private static void atualizarDadosContatoNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.optinWhatsapp = true;
        input.email = 'teste@gmail.com';
        input.actionName = 'AtualizarDadosDeContato';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao atualizar dados de contato', output.message);
    }

    @isTest
    private static void atualizarDadosPessoaisOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.nome = 'Joao da Silva';
        input.genero = 'M';
        input.dataNascimento = '09/10/1980';
        input.nomeMae = 'Maria da Silva';
        input.pep = 'F';
        input.actionName = 'AtualizarDadosPessoais';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Dados pessoais atualizados', output.message);
    }

    @isTest
    private static void atualizarDadosPessoaisNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.nome = 'Joao da Silva';
        input.genero = 'M';
        input.dataNascimento = '09/10/1980';
        input.nomeMae = 'Maria da Silva';
        input.pep = 'F';
        input.actionName = 'AtualizarDadosPessoais';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao atualizar dados pessoais', output.message);
    }

    @isTest
    private static void buscarEmpresaOcupacaoOK(){
        createOcupations();
        DadosProfissionais.InputData input = new DadosProfissionais.InputData();
        input.actionName = 'BuscarEmpresaOcupacao';
        input.codOcupacao = 1;
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();

        DadosProfissionais.OutputData output = lLstOutput.get(0);

        Assert.areEqual(true, output.hasEmpresa);
    }

    @isTest
    private static void buscarModelosContratacaoOK(){
        createOcupations();
        DadosProfissionais.InputData input = new DadosProfissionais.InputData();
        input.actionName = 'BuscarModelosDeContratacao';
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();

        DadosProfissionais.OutputData output = lLstOutput.get(0);

        Assert.areEqual(false, output.listOptions.isEmpty());
    }

    @isTest
    private static void buscarDadosSelecionadosProfissao() {
        createOcupations();
        createCategories();
        createProfessions();

        DadosProfissionais.InputData input = new DadosProfissionais.InputData();
        input.labelProfissao = 'Profissao Teste 2';
        input.codOcupacao = 2;
        input.actionName = 'BuscarDadosSelecionados';
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();
        
        DadosProfissionais.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(12.0, output.codSelecionado);
    }

    @isTest
    private static void buscarDadosSelecionadosCategoria() {
        createOcupations();
        createCategories();
        createProfessions();

        DadosProfissionais.InputData input = new DadosProfissionais.InputData();
        input.labelCategoria = 'Categoria Teste 3';
        input.codOcupacao = 3;
        input.actionName = 'BuscarDadosSelecionados';
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();
        
        DadosProfissionais.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(8.0, output.codSelecionado);
    }

    @isTest
    private static void buscarDadosSelecionadosOcupacao() {
        createOcupations();
        createCategories();
        createProfessions();

        DadosProfissionais.InputData input = new DadosProfissionais.InputData();
        input.labelOcupacao = 'Ocupação Teste 4';
        input.actionName = 'BuscarDadosSelecionados';
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();
        
        DadosProfissionais.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(4.0, output.codSelecionado);
    }

    @isTest
    private static void buscarProfissoesPorCategoria() {
        createOcupations();
        createCategories();
        createProfessions();

        DadosProfissionais.InputData input = new DadosProfissionais.InputData();

        input.codOcupacao = 1.0;
        input.codCategoria = 6.0;
        input.pagina = 0;
        input.quantidade = 1;
        input.actionName = 'BuscarProfissaoCategoria';
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();
        
        DadosProfissionais.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.listOptions.isEmpty());
        Assert.areEqual(0, output.nextPageNumber);
    }

    @isTest
    private static void buscarProfissoesRanqueadas() {
        createOcupations();
        createCategories();
        createProfessions();

        DadosProfissionais.InputData input = new DadosProfissionais.InputData();

        input.codOcupacao = 1.0;
        input.actionName = 'BuscarProfissaoPrincipais';
        
        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();
        
        DadosProfissionais.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.listOptions.isEmpty());
    }
    
    @isTest
    private static void buscarCategoriasOK() { 
        createOcupations();
        createCategories();
        DadosProfissionais.InputData input = new DadosProfissionais.InputData();
        input.pagina = 0;
        input.quantidade = 1;
        input.codOcupacao = 1.0;
        input.actionName = 'BuscarCategorias';

        Test.startTest();
        List<DadosProfissionais.OutputData> lLstOutput = 
            DadosProfissionais.manageActions(new List<DadosProfissionais.InputData>{input});
        Test.stopTest();
        
        DadosProfissionais.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.listOptions.isEmpty());
        Assert.areEqual(0, output.nextPageNumber);
    }

    @isTest
    private static void atualizarDadosProfissionaisOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idProfissao = 1.0;
        input.idOcupacao = 1.0;
        input.cnpjEmpresa = '';
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'AtualizarDadosProfissionais';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Dados profissionais atualizados com sucesso', output.message);
    }

    @isTest
    private static void atualizarDadosProfissionaisNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idProfissao = 1.0;
        input.idOcupacao = 1.0;
        input.cnpjEmpresa = '';
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'AtualizarDadosProfissionais';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao atualizar dados profissionais', output.message);
    }

    @isTest
    private static void buscarEnderecoPorCepOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockBuscarEnderecoPorCEP');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        BCSF_AquisicaoDeCartaoConsulta.InputData input = new BCSF_AquisicaoDeCartaoConsulta.InputData();
        
        input.cep = '01234567';
        input.idEmpresa = 1;
        input.actionName = 'BuscarEnderecoPorCEP';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoConsulta.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoConsulta.manageActions(new List<BCSF_AquisicaoDeCartaoConsulta.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoConsulta.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(200, output.statusCode);
        Assert.areEqual('Busca realizada com sucesso', output.message);
        Assert.areEqual('01234567', output.cep);
        Assert.areEqual('Rua X', output.logradouro);
        Assert.areEqual('Centro', output.bairro);
        Assert.areEqual('Sao Paulo', output.cidade);
        Assert.areEqual('SP', output.estado);
    }

    @isTest
    private static void buscarEnderecoPorCepNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoConsulta.InputData input = new BCSF_AquisicaoDeCartaoConsulta.InputData();
        
        input.cep = '01234567';
        input.idEmpresa = 1;
        input.actionName = 'BuscarEnderecoPorCEP';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoConsulta.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoConsulta.manageActions(new List<BCSF_AquisicaoDeCartaoConsulta.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoConsulta.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao buscar cep', output.message);
    }

    @isTest
    private static void atualizarDadosDeEnderecoOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idEmpresa = 1;
        input.cep = '01234567';
        input.logradouro = 'Rua X';
        input.bairro = 'Centro';
        input.cidade = 'Sao Paulo';
        input.estado = 'SP';
        input.numero = '100';
        input.complemento = 'Casa 1';
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.actionName = 'AtualizarDadosDeEndereco';
        input.cpf = '34612356527';
        
       Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Endereço atualizado', output.message);  
    }

    @isTest
    private static void atualizarDadosDeEnderecoNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.idEmpresa = 1;
        input.cep = '01234567';
        input.logradouro = 'Rua X';
        input.bairro = 'Centro';
        input.cidade = 'Sao Paulo';
        input.estado = 'SP';
        input.numero = '100';
        input.complemento = 'Casa 1';
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.actionName = 'AtualizarDadosDeEndereco';
        input.cpf = '34612356527';
        
       Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao atualizar dados de endereço', output.message);
    }

    @isTest
    private static void iniciarAutenticacaoPorBiometriaOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockIniciarAutenticacaoPorBiometria');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
  
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'IniciarAutenticacaoPorBiometria';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(1, lLstOutput.size());
        Assert.areEqual(200, output.statusCode);
        Assert.areEqual('https://aquisicao.carrefoursolucoes.com.br/whatsaspp/1fa22264-5717-4562-b3fc-2c963f66af34', output.urlAutenticacao);
    }

    @isTest
    private static void iniciarAutenticacaoPorBiometriaOK2(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
  
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'IniciarAutenticacaoPorBiometria';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);        
    }

    @isTest
    private static void iniciarAutenticacaoPorBiometriaNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
  
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'IniciarAutenticacaoPorBiometria';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha na biometria', output.message);
    }

    @isTest
    private static void validarAutenticacaoPorBiometriaOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockValidarAutenticacaoPorBiometria');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'ValidarAutenticacaoPorBiometria';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);

        Assert.areEqual(200, output.statusCode);
        Assert.areEqual('Oferta', output.etapa);    
    }

    @isTest
    private static void validarAutenticacaoPorBiometriaOK2(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'ValidarAutenticacaoPorBiometria';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
    }

    @isTest
    private static void validarAutenticacaoPorBiometriaNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.idEmpresa = 1;
        input.actionName = 'ValidarAutenticacaoPorBiometria';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();

        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha na validação da biometria', output.message);
    }

    @isTest
    private static void buscarDiasDeVencimentoOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockBuscarDiasDeVencimento');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        BCSF_AquisicaoDeCartaoConsulta.InputData input = new BCSF_AquisicaoDeCartaoConsulta.InputData();
        
        input.idEmpresa = 1;
        input.actionName = 'BuscarDiasDeVencimento';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoConsulta.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoConsulta.manageActions(new List<BCSF_AquisicaoDeCartaoConsulta.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoConsulta.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(200, output.statusCode);
        Assert.areEqual('Busca realizada com sucesso', output.message);
        // Assert.areEqual('Todo dia 1', body[0].descricao);
        // Assert.areEqual(1, body[0].valor);
    }

    @isTest
    private static void buscarDiasDeVencimentoNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoConsulta.InputData input = new BCSF_AquisicaoDeCartaoConsulta.InputData();
        
        input.idEmpresa = 1;
        input.actionName = 'BuscarDiasDeVencimento';
        input.cpf = '34612356527';
        
        Test.startTest();
        List<BCSF_AquisicaoDeCartaoConsulta.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoConsulta.manageActions(new List<BCSF_AquisicaoDeCartaoConsulta.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoConsulta.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha ao buscar modelos de contratação', output.message);
    }

    @isTest
    private static void efetuarConfiguracaoDoCartaoOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200,'MockEfetuarConfiguracaoDoCartao');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idEmpresa = 1;
        input.idProposta ='3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.optinAumentoLimite = true;
        input.optinOverlimit = true;
        input.diaVencimento = '2';
        input.actionName = 'EfetuarConfiguracaoDoCartao';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(200, output.statusCode);
        Assert.areEqual('Configuração realizada com sucesso', output.message);
        Assert.isNotNull(output.cep);
        Assert.isNotNull(output.logradouro);
        Assert.isNotNull(output.bairro);
        Assert.isNotNull(output.cidade);
        Assert.isNotNull(output.estado);
        Assert.isNotNull(output.numero);
        Assert.isNotNull(output.complemento);
        Assert.isNotNull(output.diaVencimento);
        Assert.isNotNull(output.limite);
        Assert.isNotNull(output.limiteFormatado);
        Assert.isNotNull(output.nome);
        Assert.isNotNull(output.diasEntrega);
        Assert.isNotNull(output.anuidade);
        Assert.isNotNull(output.termoId);
    }

    @isTest
    private static void efetuarConfiguracaoDoCartaoNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idEmpresa = 1;
        input.idProposta ='3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.optinAumentoLimite = true;
        input.optinOverlimit = true;
        input.diaVencimento = '2';
        input.actionName = 'EfetuarConfiguracaoDoCartao';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Falha na configuração', output.message);
    }

    @isTest
    private static void aceiteDaOfertaOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
        
        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.aceita = true;
        input.actionName = 'AceiteDaOferta';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
      
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Operação realizada com sucesso', output.message);        
    }

    @isTest
    private static void aceiteDaOfertaNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();
        
        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.aceita = true;
        input.actionName = 'AceiteDaOferta';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
      
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Problema ao realizar operação', output.message);
    }

    @isTest
    private static void abandonoDePropostaOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idEmpresa = 1 ;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.motivo = 'Motivo escolhido ou preenchido manualmente';
        input.actionName = 'AbandonoDeProposta';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
      
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Operação realizada com sucesso', output.message);
    }

    @isTest
    private static void abandonoDePropostaNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idEmpresa = 1 ;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.motivo = 'Motivo escolhido ou preenchido manualmente';
        input.actionName = 'AbandonoDeProposta';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
      
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Problema ao realizar operação', output.message);
    }

    @isTest
    private static void desistenciaDeCadastroDePropostaOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(204);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.motivo = 'Motivo escolhido ou preenchido manualmente';
        input.actionName = 'DesistenciaDeCadastroDeProposta';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);

        Assert.areEqual(204, output.statusCode);
        Assert.areEqual('Operação realizada com sucesso', output.message);
    }

    @isTest
    private static void desistenciaDeCadastroDePropostaNOK(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);
        
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.idEmpresa = 1;
        input.idProposta = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
        input.motivo = 'Motivo escolhido ou preenchido manualmente';
        input.actionName = 'DesistenciaDeCadastroDeProposta';
        input.cpf = '34612356527';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(400, output.statusCode);
        Assert.areEqual('Problema ao realizar operação', output.message);
    }

    @isTest
    private static void invalidActionOperacao(){
        BCSF_AquisicaoDeCartaoOperacao.InputData input = new BCSF_AquisicaoDeCartaoOperacao.InputData();

        input.actionName = 'InvalidAction';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoOperacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoOperacao.manageActions(new List<BCSF_AquisicaoDeCartaoOperacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoOperacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(500, output.statusCode);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void invalidActionAtualizacao(){
        BCSF_AquisicaoDeCartaoAtualizacao.InputData input = new BCSF_AquisicaoDeCartaoAtualizacao.InputData();

        input.actionName = 'InvalidAction';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoAtualizacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoAtualizacao.manageActions(new List<BCSF_AquisicaoDeCartaoAtualizacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoAtualizacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(500, output.statusCode);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void invalidActionConsulta(){
        BCSF_AquisicaoDeCartaoConsulta.InputData input = new BCSF_AquisicaoDeCartaoConsulta.InputData();

        input.actionName = 'InvalidAction';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoConsulta.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoConsulta.manageActions(new List<BCSF_AquisicaoDeCartaoConsulta.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoConsulta.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(500, output.statusCode);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoEmailOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.email = 'teste@teste.com';
        input.actionName = 'ValidarEmail';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoEmailNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.email = '';
        input.actionName = 'ValidarEmail';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoNomeOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.nome = 'Teste Testador';
        input.actionName = 'ValidarNome';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoNomeNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.nome = '';
        input.actionName = 'ValidarNome';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoNomeMaeOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.nomeMae = 'Teste Testador';
        input.actionName = 'ValidarNomeMae';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoNomeMaeNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.nome = '';
        input.nomeMae = 'ValidarNomeMae';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoNumeroOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.numeroEndereco = '600';
        input.actionName = 'ValidarNumero';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoNumeroNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.numeroEndereco = 'Numero 500';
        input.nomeMae = 'ValidarNumero';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }
    

    @isTest
    private static void validacaoDataOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.data = '10/11/2025';
        input.actionName = 'ValidarData';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoDataNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.data = '';
        input.actionName = 'ValidarData';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoCEPOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.CEP = '13508-970';
        input.actionName = 'ValidarCEP';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoCEPNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.CEP = '';
        input.actionName = 'ValidarCEP';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoCEPInvalid(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.CEP = '12345-678910';
        input.actionName = 'ValidarCEP';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoEnderecoOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.endereco = 'Avenida das Flores, 123';
        input.actionName = 'ValidarEndereco';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoEnderecoNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.endereco = '';
        input.actionName = 'ValidarEndereco';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoComplementoOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.complemento = 'Apto 902';
        input.actionName = 'ValidarComplemento';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoComplementoNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.complemento = '';
        input.actionName = 'ValidarComplemento';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoCidadeOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.cidade = 'Uberlândia';
        input.actionName = 'ValidarCidade';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoCidadeNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.cidade = '    ';
        input.actionName = 'ValidarCidade';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoBairroOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.bairro = 'Centro';
        input.actionName = 'ValidarBairro';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoBairroNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.bairro = '';
        input.actionName = 'ValidarBairro';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoCNPJOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.cnpjEmpresa = '38452000174';
        input.actionName = 'ValidarCNPJ';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(true, output.valido);
        Assert.isNull(output.message);
    }

    @isTest
    private static void validacaoCNPJNOK(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.cnpjEmpresa = '';
        input.actionName = 'ValidarCNPJ';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    @isTest
    private static void validacaoInvalidAction(){
        BCSF_AquisicaoDeCartaoValidacao.InputData input = new BCSF_AquisicaoDeCartaoValidacao.InputData();

        input.actionName = 'InvalidAction';

        Test.startTest();
        List<BCSF_AquisicaoDeCartaoValidacao.OutputData> lLstOutput = 
            BCSF_AquisicaoDeCartaoValidacao.manageActions(new List<BCSF_AquisicaoDeCartaoValidacao.InputData>{input});
        Test.stopTest();
        
        BCSF_AquisicaoDeCartaoValidacao.OutputData output = lLstOutput.get(0);
        
        Assert.areEqual(false, output.valido);
        Assert.isNotNull(output.message);
    }

    private static void createOcupations() {
        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();
        String ocupacaoRecordTypeId = 
            Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Ocupacao').getRecordTypeId();

        for (Integer i = 0; i < 5 ; i ++) {
            lLstParams.add(new ParametroConsultaProfissao__c (
                Name = 'Ocupação Teste ' + i,
                Codigo__c = i,
                PossuiEmpresa__c = true,
                RecordTypeId = ocupacaoRecordTypeId
            ));
        }

        If (!lLstParams.isEmpty()) {
            insert lLstParams;
        }
    }

    private static void createCategories() {
        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();
        String categoriaRecordTypeId = 
            Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Categoria').getRecordTypeId();

        for (Integer i = 0; i < 5 ; i ++) {
            lLstParams.add(new ParametroConsultaProfissao__c (
                Name = 'Categoria Teste ' + i,
                Codigo__c = i + 5,
                Ocupacao__c = i,
                RecordTypeId = categoriaRecordTypeId
            ));
        }

        If (!lLstParams.isEmpty()) {
            insert lLstParams;
        }
    }

    private static void createProfessions() {
        List<ParametroConsultaProfissao__c> lLstParams = new List<ParametroConsultaProfissao__c>();
        String categoriaRecordTypeId = 
            Schema.SObjectType.ParametroConsultaProfissao__c.getRecordTypeInfosByDeveloperName().get('Profissao').getRecordTypeId();

        for (Integer i = 0; i < 5 ; i ++) {
            lLstParams.add(new ParametroConsultaProfissao__c (
                Name = 'Profissao Teste ' + i,
                Codigo__c = i + 10,
                Categoria__c = i + 5,
                Ocupacao__c = i,
                Rank__c = i,
                RecordTypeId = categoriaRecordTypeId
            ));
        }

        If (!lLstParams.isEmpty()) {
            insert lLstParams;
        }
    }
}