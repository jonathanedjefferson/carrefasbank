public without sharing class IdentificaCockpitBO {
    public static String identificaConta(String accountId, String canal){
        string retorno = 'erro';
        Account acc = IdentificaCockpitDAO.getInstance().getAccoutById(accountId);
        IdentificaCockpit.ResponseAPIConta clienteAtualizado = IdentificaCockpit.identificaConta(acc.CPF__c, accountId, canal);
        
        if (clienteAtualizado == null) {
            return retorno;
        }
        
        List<IdentificaCockpit.ContaResponse> listContratos = clienteAtualizado.data.cliente.contaCartao.contratos;
        
        acc.EhBlindado__c = clienteAtualizado.ehBlindado;
        acc.EhBlindadoFull__c = clienteAtualizado.ehBlindadoFull;
        acc.Sexo__c = clienteAtualizado.data.cliente.dadosSociais[0].genero;
        acc.NomeMae__c = clienteAtualizado.data.cliente.dadosSociais[0].nomeMae;
        acc.DataNascimento__c = clienteAtualizado.data.cliente.dadosSociais[0].dataDeNascimento.date();
        if((String.isBlank(clienteAtualizado.data.cliente.dadosSociais[0].nomeMeio) && String.isBlank(clienteAtualizado.data.cliente.dadosSociais[0].nomeUltimo))){
            String lastNameObtained = Util.obterSobrenome(clienteAtualizado.data.cliente.dadosSociais[0].nomePrimeiro);
            acc.FirstName = clienteAtualizado.data.cliente.dadosSociais[0].nomePrimeiro.split(' ')[0];
            acc.LastName = String.isBlank(lastNameObtained) ? acc.FirstName : lastNameObtained;
        }else{
            String lastName = String.isBlank(clienteAtualizado.data.cliente.dadosSociais[0].nomeMeio) ? '' :  clienteAtualizado.data.cliente.dadosSociais[0].nomeMeio;
            lastName += String.isBlank(clienteAtualizado.data.cliente.dadosSociais[0].nomeUltimo) ? '' : ' ' + clienteAtualizado.data.cliente.dadosSociais[0].nomeUltimo;
            acc.FirstName = clienteAtualizado.data.cliente.dadosSociais[0].nomePrimeiro;
            acc.LastName = lastName;
        }
        update acc;
        
        List<ContaFinanceira__c> listConta = IdentificaCockpitDAO.getInstance().getContaByCliente(accountId);
        Map<String, ContaFinanceira__c> mapContas = new Map<String, ContaFinanceira__c>();

        if(!listConta.isEmpty()){
            for(ContaFinanceira__c cf : listConta){
                mapContas.put(cf.NumeroConta__c, cf);
            }
        }

        if(clienteAtualizado != null){

            List<ContaFinanceira__c> listContaFinanceiraInsert = new List<ContaFinanceira__c>();
            List<ContaFinanceira__c> listContaFinanceiraUpdate = new List<ContaFinanceira__c>();

            for (IdentificaCockpit.ContaResponse item: clienteAtualizado.data.cliente.contaCartao.contratos) {
                String unidadeNegocio = '';
                if (item.unidadeNegocio == 'CSF' || item.unidadeNegocio == 'CRF' || item.unidadeNegocio == '1') {
                    unidadeNegocio = '1';
                }else if(item.unidadeNegocio == 'ATC' || item.unidadeNegocio == '2') {
                    unidadeNegocio = '2';
                }else if(item.unidadeNegocio == 'SAMS' || item.unidadeNegocio == '6'){
                    unidadeNegocio = '6';
                }else{
                    unidadeNegocio = null;
                }
        
                ContaFinanceira__c cf = mapContas.containsKey(item.numeroConta) ? mapContas.get(item.numeroConta) : new ContaFinanceira__c();
                cf.NomeCliente__c = acc.Id;
                cf.NumeroConta__c = item.numeroConta;
                cf.StatusConta__c = item.statusConta;
                cf.IdConta__c = item.numeroContaSerno;
                cf.UnidadeNegocio__c = unidadeNegocio;
                cf.CartaoTransversal__c = (item.tipoCartaoTransversal == 1);
                
                if(cf.Id != null && mapContas.containsKey(item.numeroConta)){
                    listContaFinanceiraUpdate.add(cf);
                } else{
                    listContaFinanceiraInsert.add(cf);
                }
            }

            if(!listContaFinanceiraUpdate.isEmpty()){
                update listContaFinanceiraUpdate;
            }

            if(!listContaFinanceiraInsert.isEmpty()){
                insert listContaFinanceiraInsert;
            }

            retorno = 'ok';
        }
        
        return retorno;
    }

    public static String identificaNumeroConta(String contaId, String canal) {
        ContaFinanceira__c conta2 = IdentificaCockpitDAO.getInstance().getContaById(contaId);
        Map<String, Product2>  produtosMap = IdentificaCockpitDAO.getInstance().getMapProduct();
		IdentificaCockpit.ResponseAPIContaFinanceira conta = IdentificaCockpit.identificaNumeroConta(conta2.NumeroConta__c, conta2.UnidadeNegocio__c, conta2.NomeCliente__r.CPF__c, canal);
        
        Account contaAtualizada = new Account();
        contaAtualizada.id = conta2.NomeCliente__c;

        if (conta == null) {
            return '';
        }

        conta2.EhBlindado__c = conta.ehBlindado;
        conta2.EhBlindadoFull__c = conta.ehBlindadoFull;
        
        List<IdentificaCockpit.endereco> listEnderecos = conta.data.clientePorConta.contato.dadosContato.size() != 0 ? conta.data.clientePorConta.contato.dadosContato[0].enderecos : new List<IdentificaCockpit.endereco>(); 
        List<IdentificaCockpit.telefone> listCelularSeguro = conta.data.clientePorConta.contato.dadosContato.size() != 0 ? conta.data.clientePorConta.contato.dadosContato[0].telefones : new List<IdentificaCockpit.telefone> (); 
        List<IdentificaCockpit.Email> listEmail = conta.data.clientePorConta.contato.dadosContato.size() != 0 ? conta.data.clientePorConta.contato.dadosContato[0].emails : new List<IdentificaCockpit.Email>();
        List<IdentificaCockpit.cartao> listAtivos = conta.data.clientePorConta.contaCartao.contratos.size() != 0 ? conta.data.clientePorConta.contaCartao.contratos[0].cartoes : new List<IdentificaCockpit.cartao>();
        List<IdentificaCockpit.Identidades> listDocumentos = conta.data.clientePorConta.identidades;
        IdentificaCockpit.DadosSociais dadosSociais = conta.data.clientePorConta.dadosSociais.size() != 0 ? conta.data.clientePorConta.dadosSociais[0] : new IdentificaCockpit.DadosSociais();
        IdentificaCockpit.Contrato contratoAPI = conta.data.clientePorConta.contaCartao.contratos.size() != 0 ? conta.data.clientePorConta.contaCartao.contratos[0] : new IdentificaCockpit.Contrato();
        
        List<ContatoAtendimento__c> listContatoAtualizar = new List<ContatoAtendimento__c>();
        List<Asset> listAtivosAtualizar = new List<Asset>();
        List<Asset> listAtivosCriar = new List<Asset>();

        conta2.EstadoCivil__c = String.valueOf(dadosSociais.estadoCivil);
        conta2.Genero__c = dadosSociais.genero;

        if(!listEnderecos.isEmpty()){
            for(IdentificaCockpit.endereco dadosEndereco : listEnderecos){
                if (dadosEndereco.tipoEndereco[0] == 'RESIDENCIAL') {
                    conta2.Bairro__c = dadosEndereco.Bairro;
                    conta2.Cep__c = dadosEndereco.cep;
                    conta2.Cidade__c = dadosEndereco.Cidade;
                    conta2.Complemento__c = dadosEndereco.complemento;
                    conta2.Rua__c = dadosEndereco.logradouro;
                    conta2.Estado__c = dadosEndereco.uf;
                    conta2.TipoEndereco__c = 'RESIDENCIAL';
                    conta2.Numero__c = (dadosEndereco.numero == '' || dadosEndereco.numero == null) ? null : String.valueOf(dadosEndereco.numero);
                }
                
                for (ContatoAtendimento__c listContatoAtendimento : conta2.ContatosAtendimentos__r) {
                    if(!listContatoAtualizar.contains(listContatoAtendimento)){
                        listContatoAtendimento.Cep__c = dadosEndereco.cep;
                        listContatoAtendimento.Endereco__c = dadosEndereco.logradouro;
                        listContatoAtendimento.Numero__c = dadosEndereco.numero;
                        listContatoAtendimento.Bairro__c = dadosEndereco.Bairro;
                        listContatoAtendimento.Cidade__c = dadosEndereco.Cidade;
                        listContatoAtendimento.Estado__c = dadosEndereco.uf;
                    
                        listContatoAtualizar.add(listContatoAtendimento);
                    }
                }
            } 
        }

        if (!listDocumentos.isEmpty()) {
            for (IdentificaCockpit.Identidades item: listDocumentos) {
                if (item.tipo.equalsIgnoreCase('RG')) {
                    conta2.RG__c = item.valor;
                    break;
                }
            }
        }
        
        Boolean celularAtualizado = false;
        Boolean residencialAtualizado = false;
        if (!listCelularSeguro.isEmpty()){
            for(IdentificaCockpit.telefone item : listCelularSeguro ){
                String telefoneRegexCom55 = '([5]{2})([0-9]{2})([9]{1})([0-9]{8})';
                String telefoneRegexSem55 = '([0-9]{2})([9]{1})([0-9]{8})';
                Boolean resultCom55 = false;
                Boolean resultSem55 = false;
                if(item.celularSeguro){
                    if (item.numero != null) {
                        // VALIDAÇÃO COM 55 
                        Pattern telefonePatternCom55 = Pattern.compile(telefoneRegexCom55);
                        Matcher telefoneMatcherCom55 = telefonePatternCom55.matcher(item.ddd + item.numero);
                        resultCom55 = telefoneMatcherCom55.matches();
                        
                        // VALIDAÇÃO SEM 55 
                        Pattern telefonePatternSem55 = Pattern.compile(telefoneRegexSem55);
                        Matcher telefoneMatcherSem55 = telefonePatternSem55.matcher(item.ddd + item.numero);
                        resultSem55 = telefoneMatcherSem55.matches();
                    }
                
                    if (resultCom55) {
                        conta2.Telefone__c = item.ddd + item.numero;
                    } else if (resultSem55) {
                        conta2.Telefone__c = '55' + item.ddd + item.numero;
                    }
                
                    if (conta2.NomeCliente__r.RecordType.IsPersonType) {
                        contaAtualizada.CelularSeguro__pc = true;
                    }
                    celularAtualizado = true;
                    conta2.CelularSeguro__c = true;
                    continue;
                }else if (!celularAtualizado) {
                    if (conta2.NomeCliente__r.RecordType.IsPersonType) {
                        contaAtualizada.CelularSeguro__pc = false;
                    }
                    conta2.CelularSeguro__c = false;
                }

                if (item.tipo.equalsIgnoreCase('PRINCIPAL') && item.tipoContato[0].equalsIgnoreCase('RESIDENCIAL')) {
                    resultCom55 = false;
                    resultSem55 = false;
                    if (item.numero != null) {
                        telefoneRegexCom55 = '([5]{2})([0-9]{2})([0-9]{8})';
                        telefoneRegexSem55 = '([0-9]{2})([0-9]{8})';
                        // VALIDAÇÃO COM 55 
                        Pattern telefonePatternCom55 = Pattern.compile(telefoneRegexCom55);
                        Matcher telefoneMatcherCom55 = telefonePatternCom55.matcher(item.ddd + item.numero);
                        resultCom55 = telefoneMatcherCom55.matches();
                        
                        // VALIDAÇÃO SEM 55 
                        Pattern telefonePatternSem55 = Pattern.compile(telefoneRegexSem55);
                        Matcher telefoneMatcherSem55 = telefonePatternSem55.matcher(item.ddd + item.numero);
                        resultSem55 = telefoneMatcherSem55.matches();
                        
                        if (resultCom55) {
                            conta2.TelefoneResidencial__c = item.ddd + item.numero;
                        } else if (resultSem55) {
                            conta2.TelefoneResidencial__c = '55' + item.ddd + item.numero;
                        }
                        residencialAtualizado = true;
                    }
                    continue;
                }else if (!residencialAtualizado) {
                    conta2.TelefoneResidencial__c = null;
                }
            }
        }
        
        if (!listEmail.isEmpty()) {
            String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
            
            for (IdentificaCockpit.Email dadosEmail : listEmail) {
                if (Pattern.matches(emailRegex, dadosEmail.endereco)) {
                    conta2.Email__c = dadosEmail.endereco;
                }
            }
        }

        if(!listAtivos.isEmpty()){
            for(IdentificaCockpit.cartao dadosAtivos : listAtivos){
                String cartaoApi = null;
                Date dataAtivacao = dadosAtivos.dataAtivacao.year() == 1? null : dadosAtivos.dataAtivacao.date();
                Date vencimentoCartao = dadosAtivos.vencimentoCartao.year() == 1? null : dadosAtivos.vencimentoCartao.date();
                Product2 produto = produtosMap.get(dadosAtivos.idProduto);
                
                if(!String.isEmpty(dadosAtivos.numeroCartao)){
                    cartaoApi = dadosAtivos.numeroCartao.substring(dadosAtivos.numeroCartao.length() - 4);
                }
                Boolean cartaoExiste = false;
                String nomeCartao;
                if(dadosAtivos.bandeira == 'MASTERCARD'){
                    nomeCartao = 'CARMC'+cartaoApi;
                }else if(dadosAtivos.bandeira == 'VISA'){
                    nomeCartao = 'CARVS'+cartaoApi;
                }else{
                    nomeCartao = 'CARPL'+cartaoApi;
                }

                for (Asset ativosAtualizados : conta2.Ativos__r) {
                    String cartaoSalesforce = ativosAtualizados.NumeroCartao__c.substring(ativosAtualizados.NumeroCartao__c.length() - 4);
                    if (cartaoSalesforce == cartaoApi){
                        cartaoExiste =  true;
                        ativosAtualizados.name = nomeCartao;
                        ativosAtualizados.Situacao__c = dadosAtivos.ehAtivo? 'A' : 'I';
                        ativosAtualizados.CartaoPrimario__c = dadosAtivos.ehPrimario;
                        ativosAtualizados.NomeReduzido__c = dadosAtivos.nomeCartao;
                        ativosAtualizados.tipoTitularidade__c = dadosAtivos.tipoTitularidade;
                        ativosAtualizados.DataAtivacaoCartao__c = dataAtivacao;
                        ativosAtualizados.DataValidadeCartao__c = vencimentoCartao;
                        ativosAtualizados.TipoCartao__c = dadosAtivos.tipoCartao;
                        ativosAtualizados.Status = dadosAtivos.statusCartao;
                        ativosAtualizados.Product2Id = produto != null ? produto.id : null;
                        ativosAtualizados.UnidadeNegocio__c = conta2.UnidadeNegocio__c;
                        ativosAtualizados.Contactless__c = dadosAtivos.ehContactless;
                        ativosAtualizados.CartaoSernoId__c = dadosAtivos.id;
                        ativosAtualizados.NumeroCartao__c = dadosAtivos.numeroCartao;


                        listAtivosAtualizar.add(ativosAtualizados);
                    }
                }

                if(!cartaoExiste){
                    Asset novoCartao = new Asset(
                        Name = nomeCartao,
                        NomeReduzido__c = dadosAtivos.nomeCartao,
                        NumeroCartao__c = dadosAtivos.numeroCartao,
                        Situacao__c = dadosAtivos.ehAtivo? 'A' : 'I',
                        CartaoPrimario__c = dadosAtivos.ehPrimario,
                        CPF__c = dadosAtivos.cpfPortador,
                        tipoTitularidade__c = dadosAtivos.tipoTitularidade,
                        TipoCartao__c = dadosAtivos.tipoCartao,
                        Status = dadosAtivos.statusCartao,
                        ContaFinanceira__c = contaId,
                        AccountId = conta2.NomeCliente__c,
                        Product2Id = produto != null ? produto.id : null,
                        DataAtivacaoCartao__c = dataAtivacao,
                        DataValidadeCartao__c = vencimentoCartao,
                        UnidadeNegocio__c = conta2.UnidadeNegocio__c,
                        Contactless__c = dadosAtivos.ehContactless,
                        CartaoSernoId__c = dadosAtivos.id
                    );

                    listAtivosAtualizar.add(novoCartao);
                }
            }   
        }

        if (contratoAPI != null) {
             switch on contratoAPI.tipoEnvioFatura {
                when '1' {
                    conta2.ModoRecebimentoFatura__c = 'CORREIO';
                }
                when '2' {
                    conta2.ModoRecebimentoFatura__c = 'EMAIL';
                }
                when '4' {
                    conta2.ModoRecebimentoFatura__c = 'APP/PORTAL';
                }
                when '8' {
                    conta2.ModoRecebimentoFatura__c = 'WHATSAPP';
                }
                when '16' {
                    conta2.ModoRecebimentoFatura__c = 'SMS';
                }
            }

            conta2.AceitaRecebimentoEmail__c = contratoAPI.aceiteRecebimentoDeEmail;
            conta2.AumentoAltomaticoLimite__c = contratoAPI.aumentoAutomaticoDeLimite;
            conta2.CartaoTransversal__c = (contratoAPI.tipoCartaoTransversal == 1);
            conta2.StatusConta__c = contratoAPI.statusConta;
        }

        update contaAtualizada;    
            
        if(!listContatoAtualizar.isEmpty()){
            update listContatoAtualizar;
        }               

        if(!listAtivosAtualizar.isEmpty()){
            upsert listAtivosAtualizar;
        }

        update conta2;

        return 'ok';
    }
}