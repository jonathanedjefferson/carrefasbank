public class IdentificaClienteChatHelper {
    @invocableMethod(label='Identifica Cliente - Chat')
    public static List<Output> IdentificarCliente(List<Input> listInput){
        List<Output> listRetorno = new List<Output>();
        Output objRetorno = new Output();
        String unidadeNegocioEntrada, idCartaoPrimario, statusCartaoPrimario, finalNumeroCartao, numeroCartaoPrimario = '';
        Boolean ehAtivoCartaoPrimario = false;
        List<String> cartoesBloqueadoIdLst = new List<String>();

        // CHAMADA DA API
        IdentificaClienteChat.OutputIdentifica retornoAPI = new IdentificaClienteChat.OutputIdentifica();
        LiveChatTranscript transcript =  IdentificaClienteChatDAO.getTranscriptById(listInput[0].RoutableId);
        String tokenLogado = transcript.Token__c;
        for (Input item: listInput) {
            retornoAPI = IdentificaClienteChat.IdentificarCliente(tokenLogado, item.IdEmpresa);
            
            objRetorno.StatusCodeApi = Integer.valueOf(retornoAPI.statusCode);
            if (retornoAPI.statusCode != '200' && retornoAPI.statusCode != '204') {
                listRetorno.add(objRetorno);
                return listRetorno;
            }
            
            unidadeNegocioEntrada = item.UnidadeNegocio;
            objRetorno.ClienteIdentificado = retornoAPI.statusCode == '200'? true : false;
            objRetorno.CpfCliente = retornoAPI.data.cliente.cpf;
            break;
        }

        // TRATATIVA DOS DADOS QUE RETORNAM PARA O BOT
        for (IdentificaClienteChat.contratos itemContrato: retornoAPI.data.cliente.contaCartao.contratos) {
            if (itemContrato.unidadeNegocio == unidadeNegocioEntrada && itemContrato.numeroConta == transcript.ChaveContaFinanceira__c) {
                for(IdentificaClienteChat.Cartoes objCartao : itemContrato.cartoes){
                    if(objCartao.ehPrimario){
                        idCartaoPrimario = objCartao.id;
                        numeroCartaoPrimario = objCartao.numeroCartao;
                        if(String.isNotBlank(numeroCartaoPrimario)){
                            List<String> opcaoCartao = numeroCartaoPrimario.split('\\.');
                            finalNumeroCartao = opcaoCartao[opcaoCartao.size() - 1];
                        }
                        statusCartaoPrimario = objCartao.statusCartao;
                        ehAtivoCartaoPrimario = objCartao.ehAtivo;
                        break;
                    }
                }

                for(IdentificaClienteChat.Cartoes objCartao : itemContrato.cartoes){
                    if(objCartao.statusCartao == 'WCNP'){
                        cartoesBloqueadoIdLst.add(objCartao.id);
                    }
                }
                
                objRetorno.NumeroContaSerno = itemContrato.numeroContaSerno;
                objRetorno.LimiteTotal = '';
                objRetorno.LimiteDisponivel = '';
                if(itemContrato.valorLimiteTotal != null){
                    objRetorno.LimiteTotal = 'R$ ' + StringUtils.getCurrencyFormat(itemContrato.valorLimiteTotal);
                }
                if(itemContrato.valorLimiteDisponivel != null){
                    objRetorno.LimiteDisponivel = 'R$ ' + StringUtils.getCurrencyFormat(itemContrato.valorLimiteDisponivel);
                }
                objRetorno.NumeroConta = itemContrato.numeroConta;
                objRetorno.StatusConta = itemContrato.statusConta;
                objRetorno.PerfilAnuidade = itemContrato.perfilAnuidade;
                if (String.isNotBlank(objRetorno.PerfilAnuidade)) {
                    objRetorno.PerfilAnuidade = objRetorno.PerfilAnuidade.replaceAll('\\s+$', '');
                }
                objRetorno.idCartaoPrimario = idCartaoPrimario;
                objRetorno.StatusCartao = statusCartaoPrimario;
                objRetorno.NumeroCartao = numeroCartaoPrimario;
                objRetorno.FinalNumeroCartao = finalNumeroCartao;
                objRetorno.tipoCartaoTransversal = String.valueOf(itemContrato.tipoCartaoTransversal);
                objRetorno.CartaoEstaCancelado = VerificaStatusCancelado(statusCartaoPrimario);
                objRetorno.ehAtivoCartaoPrimario = ehAtivoCartaoPrimario;

                if(!cartoesBloqueadoIdLst.isEmpty()){
                    objRetorno.idCartoesBloqueadosLst = String.join(cartoesBloqueadoIdLst, ',');
                }
               
                break;
            }
        }

        for (IdentificaClienteChat.DadosSociais dadosSociais: retornoAPI.data.cliente.dadosSociais) {
            if (dadosSociais.numeroConta == transcript.ChaveContaFinanceira__c) {
                objRetorno.PrimeiroNome = dadosSociais.nomePrimeiro;
                objRetorno.SobrenomeCliente = dadosSociais.nomeMeio;
                objRetorno.UltimoNome = dadosSociais.nomeUltimo;
                objRetorno.NomeCompleto = dadosSociais.nomeCompleto;
                objRetorno.dataDeNascimento = dadosSociais.dataDeNascimento;
                objRetorno.nomeMae = dadosSociais.nomeMae;
                objRetorno.genero = dadosSociais.genero;
            }
        }

        for(IdentificaClienteChat.DadosContato itemData : retornoAPI.data.cliente.contato.dadosContato){
            if(objRetorno.NumeroConta == itemData.numeroConta){
                if(itemData.emails.size() > 0){
                    String email = itemData.emails.get(0).endereco;
                    objRetorno.email = email;
                    objRetorno.emailMascarado = Util.mascararEmail(email);
                }
                
                if(itemData.telefones.size() > 0){
                    for(IdentificaClienteChat.Telefones objTelefone : itemData.telefones){
                        if(objTelefone.celularSeguro) {
                            objRetorno.TemCelularSeguro = true;
                            objRetorno.NumeroCelularSeguro = Util.mascararTelefone(objTelefone.numero);
                            objRetorno.ddd = objTelefone.ddd;
                            objRetorno.telefone = objTelefone.numero;
                            break;
                        }
                    }
                }
                break;
            }
        }
        
        if (objRetorno.PrimeiroNome != null) {
            AtualizaChatTranscript(transcript.Id, listInput[0].UnidadeNegocio, listInput[0].IdEmpresa, objRetorno);
        }
        
        listRetorno.add(objRetorno);
        return listRetorno;
    }

    private static void AtualizaChatTranscript(String IdTranscript, String unidadeNegocio, String IdEmpresa, Output InfoCliente){
        LiveChatTranscript liveChat = new LiveChatTranscript();
        liveChat.Id = IdTranscript;
        liveChat.CPF__c = InfoCliente.CpfCliente;
        liveChat.PrimeiroNome__c = InfoCliente.PrimeiroNome;
        liveChat.Sobrenome__c = InfoCliente.SobrenomeCliente != null? InfoCliente.SobrenomeCliente : InfoCliente.UltimoNome;
        liveChat.StatusCartao__c = InfoCliente.StatusCartao;
        liveChat.StatusConta__c = InfoCliente.StatusConta;
        liveChat.UnidadeNegocio__c = unidadeNegocio;
        liveChat.LimiteDisponivel__c = InfoCliente.LimiteDisponivel;
        liveChat.Limite__c = InfoCliente.LimiteTotal;

        liveChat.SernoContaFinanceira__c = InfoCliente.NumeroContaSerno;

        Account clientAccount = new Account();
        clientAccount.CPF__c = InfoCliente.CpfCliente;
        if((String.isBlank(InfoCliente.SobrenomeCliente) || String.isBlank(InfoCliente.UltimoNome) && !String.isBlank(InfoCliente.NomeCompleto))){
            clientAccount.FirstName = !String.isBlank(InfoCliente.PrimeiroNome) ? InfoCliente.PrimeiroNome.split(' ')[0] : InfoCliente.NomeCompleto.split(' ')[0];
            clientAccount.LastName = Util.obterSobrenome(InfoCliente.NomeCompleto);
        }else{
            clientAccount.FirstName = InfoCliente.PrimeiroNome;
            clientAccount.LastName = InfoCliente.SobrenomeCliente != null? InfoCliente.SobrenomeCliente : InfoCliente.UltimoNome;
        }
        clientAccount.RecordTypeId = IdentificaClienteChatDAO.getPersonRecordType().Id;
        clientAccount.DataNascimento__c = InfoCliente.dataDeNascimento.Date();
        clientAccount.NomeMae__c = InfoCliente.nomeMae;
        clientAccount.Sexo__c = InfoCliente.genero;
        upsert clientAccount CPF__c;

        liveChat.Cliente__c = clientAccount.Id;

        List<ContaFinanceira__c> CF = IdentificaClienteChatDAO.getContaFinanceira(IdEmpresa, InfoCliente.NumeroConta);

        if(CF.size() > 0){
            liveChat.ContaFinanceira__c = CF[0].Id;

            List<Asset> listCartao = IdentificaClienteChatDAO.getCartao(CF[0].NomeCliente__r.Id, CF[0].Id);
            for (Asset item: listCartao) {
                if (InfoCliente.NumeroCartao != null && item.NumeroCartao__c != null) {
                    if (item.NumeroCartao__c.contains(InfoCliente.NumeroCartao.substring(InfoCliente.NumeroCartao.length() - 4))) {
                        liveChat.Cartao__c = item.Id;
                        break;
                    }
                }
            }
        } 
        
        ContaFinanceira__c contaFinanceira = CF.size() > 0 ? CF[0] : new ContaFinanceira__c();
        contaFinanceira.IdConta__c = InfoCliente.NumeroContaSerno;
        contaFinanceira.NomeCliente__c = clientAccount.Id;
        contaFinanceira.NumeroConta__c = InfoCliente.NumeroConta;
        contaFinanceira.StatusConta__c = InfoCliente.StatusConta;
        contaFinanceira.UnidadeNegocio__c = IdEmpresa;
        if(contaFinanceira.Telefone__c == null && (InfoCliente.telefone != null && InfoCliente.ddd != null)) contaFinanceira.Telefone__c = '55' + InfoCliente.ddd + InfoCliente.telefone;
        if(contaFinanceira.Email__c == null && InfoCliente.Email != null){
            String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
            contaFinanceira.Email__c = Pattern.matches(emailRegex, InfoCliente.Email) ? InfoCliente.Email : null;
        }
        
        if(contaFinanceira.Id != null){
            update contaFinanceira;
        }else{
            insert contaFinanceira;
        }
        
        liveChat.ContaFinanceira__c = contaFinanceira.Id;
        update liveChat;
    }

    public static Boolean VerificaStatusCancelado(String status){
        List<StatusContaCancelada__mdt> listaStatus = IdentificaClienteChatDAO.getStatusContaCanceladoByStatus(status);
        if (listaStatus.size() > 0) {
            return true;
        }

        return false;
    }

    public class Input{
        @InvocableVariable(required = true)
        public String RoutableId;
        @InvocableVariable(required = true description = 'Carrefour = "1".\nAtacadão = "2".\nSams = "6".')
        public String IdEmpresa;
        @InvocableVariable(required = true description = 'Carrefour = "CSF".\nAtacadão = "ATC".\nSams = "SAMS".')
        public String UnidadeNegocio;
    }

    public class Output{
        @InvocableVariable
        public Boolean ClienteIdentificado;
        @InvocableVariable
        public Integer StatusCodeApi;
        @InvocableVariable
        public String PrimeiroNome;
        @InvocableVariable
        public String SobrenomeCliente;
        @InvocableVariable
        public String UltimoNome;
        @InvocableVariable
        public String NomeCompleto;
        @InvocableVariable
        public String CpfCliente;
        @InvocableVariable
        public Boolean TemCelularSeguro;
        @InvocableVariable
        public String NumeroCelularSeguro;
        @InvocableVariable
        public String Email;
        @InvocableVariable
        public String EmailMascarado;
        @InvocableVariable
        public String IdCartaoPrimario;
        @InvocableVariable
        public String StatusCartao;
        @InvocableVariable
        public Boolean ehAtivoCartaoPrimario;
        @InvocableVariable
        public Boolean CartaoEstaCancelado;
        @InvocableVariable
        public String NumeroConta;
        @InvocableVariable
        public String StatusConta;
        @InvocableVariable
        public String PerfilAnuidade;

        public String NumeroContaSerno;
        public String NumeroCartao;
        @InvocableVariable
        public String FinalNumeroCartao;
        @InvocableVariable
        public String LimiteTotal;
        @InvocableVariable
        public String LimiteDisponivel;

        @InvocableVariable
        public Datetime dataDeNascimento;
        @InvocableVariable
        public String nomeMae;
        @InvocableVariable
        public String genero;
        @InvocableVariable
        public String ddd;
        @InvocableVariable
        public String telefone;
        @InvocableVariable
        public string idCartoesBloqueadosLst;

        @InvocableVariable
        public String tipoCartaoTransversal;
    }
}