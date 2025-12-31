public class IdentificaCockpitController {
    @AuraEnabled
    public static string identificaConta(String accountId, String canal){
        return IdentificaCockpitBO.IdentificaConta(accountId, canal);
    }
    @AuraEnabled
    public static string identificaNumeroConta(String contaId, String canal){
        return IdentificaCockpitBO.IdentificaNumeroConta(contaId, canal);
    }
    @AuraEnabled
    public static Account atualizaContaPorCPF(String accountId, String  canal){
        
        Account acc = IdentificaCockpitDAO.getInstance().getAccoutById(accountId);
        // Caso conta não encontrada ou CPF vazio.
        if(acc == null || acc.CPF__c == null){
            return null;
        }
        
        return inserirAtualizarConta(acc, canal);
    }
    
    public static ContaFinanceira__c identificaContaFinanceira(String accountId, String contaValidada){
        
        List<ContaFinanceira__c> listCF = IdentificaCockpitDAO.getInstance().getContaByCliente(accountId);
        System.debug('IdentificaCockpitController identificaContaFinanceira'+ listCF);
        if(listCF[0] != null){
            ContaFinanceira__c cf = listCF[0];
            if(contaValidada == 'SIM'){
                Id userId = UserInfo.getUserId();
                cf.DataLimiteDesbloqueio__c = System.now();
                cf.UltimoOperador__c = userId;
                System.debug('cf => '+ cf);
                update cf;
            }
            return cf;
        }
        // else {
        //    Account ac =  ConsultaCPFNoIDCBO.createAccount(cpf, 'Ouvidoria');
        // }
        return null;
        
    }
    public static ContaFinanceira__c identificaContaFinanceira(String accountId,String numeroConta, String contaValidada){
        
        ContaFinanceira__c cf = IdentificaCockpitDAO.getInstance().getContaByCliente(accountId, numeroConta);
        if(cf != null){
            if(contaValidada == 'SIM'){
                Id userId = UserInfo.getUserId();
                cf.DataLimiteDesbloqueio__c = System.now();
                cf.UltimoOperador__c = userId;
                System.debug('cf => '+ cf);
                update cf;
            }
            return cf;
        }
        return null;
    }
    
    @AuraEnabled
    public static Account consultaContaPorCPF(String cpf, String  canal){
        
        RecordType rt = ConsultaCPFNoIDDAO.getRecordType('BCSF Cliente Pessoal Carrefour');
        if(String.isBlank(cpf) || rt == null){
            return null;
        }
        
        Account acc = new Account();
        acc.CPF__c = cpf;
        acc.RecordTypeId = rt.Id;
        System.debug('IdentificaCockpitController consultaContaPorCPF'+ acc);
        return inserirAtualizarConta(acc, canal);
    }
    private static Account inserirAtualizarConta(Account account, String canal){
        
        IdentificaCockpitV2.ResponseAPI clienteAtualizado = IdentificaCockpitV2.identificaCockpitByCPF(account.CPF__c, canal);
        // API sem retorno ou lista de contratações vazia.
        if (clienteAtualizado == null || clienteAtualizado.data?.clientePorCpfETipoProduto?.contratacoes?.size() == 0) {
            return null;
        }
        
        IdentificaCockpitV2.DadosSociais dadosSociais = clienteAtualizado.data.clientePorCpfETipoProduto.contratacoes[0].dadosSociais;
        account.NomeMae__c = dadosSociais.nomeMae;
        account.DataNascimento__c = dadosSociais.dataNascimento?.date();
        if(String.isNotBlank(dadosSociais.genero)){
            account.Sexo__c = dadosSociais.genero.substring(0, 1);
        }
        
        account.EhBlindado__c = clienteAtualizado.data.clientePorCpfETipoProduto.ehBlindado;
        account.EhBlindadoFull__c = clienteAtualizado.data.clientePorCpfETipoProduto.ehBlindadoFull;
        
        account.FirstName = dadosSociais.nomePrimeiro?.split(' ')[0];
        String lastName = String.isBlank(dadosSociais.nomeMeio) ? '' : dadosSociais.nomeMeio.trim() + ' ';
        lastName += String.isBlank(dadosSociais.nomeUltimo) ? '' : dadosSociais.nomeUltimo.trim();
        account.LastName = lastName.trim();
        
        if(String.isBlank(account.LastName)){
            String lastNameObtained = Util.obterSobrenome(dadosSociais.nomePrimeiro);
            account.LastName = String.isBlank(lastNameObtained) ? account.FirstName : lastNameObtained;
        }
        upsert account CPF__c;
        
        List<ContaFinanceira__c> listaContasFinanceirasCartao = new List<ContaFinanceira__c>();
        List<ContaFinanceira__c> listaContasFinanceirasContratadas = new List<ContaFinanceira__c>();
        List<ContaFinanceira__c> listaContasConsignadoContratadas = new List<ContaFinanceira__c>();
        Map<String, RecordType> rts = ConsultaCPFNoIDDAO.getRecordTypeBySobjectType('ContaFinanceira__c');
        for (IdentificaCockpitV2.Contratacao contratacao: clienteAtualizado.data.clientePorCpfETipoProduto.contratacoes) {
            
            String nomeProduto = contratacao.produto?.nomeProduto;
            ContaFinanceira__c cf = new ContaFinanceira__c();
            cf.NomeCliente__c = account.Id;
            
            String unidadeNegocio = contratacao.unidadeNegocio?.trim();
            if ('CSF'.equalsIgnoreCase(unidadeNegocio) || 'CRF'.equalsIgnoreCase(unidadeNegocio)) {
                cf.UnidadeNegocio__c = '1';
            } else if('ATC'.equalsIgnoreCase(unidadeNegocio)) {
                cf.UnidadeNegocio__c = '2';
            } else if('SAMS'.equalsIgnoreCase(unidadeNegocio)) {
                cf.UnidadeNegocio__c = '6';
            } else {
                cf.UnidadeNegocio__c = null;
            }
            
            RecordType rt = null;
            if('Cartao'.equalsIgnoreCase(nomeProduto)){
                cf.NumeroConta__c = contratacao.chaveContratacao?.trim();
                cf.StatusConta__c = contratacao.statusContratacao?.trim();
                rt = rts.get('BCSF_RT_CFI_ContaFinanceira');
                cf.RecordTypeId = rt?.Id;
                cf.IdConta__c = contratacao.numeroContaSerno;
                listaContasFinanceirasCartao.add(cf);
            } else if('Consignado'.equalsIgnoreCase(nomeProduto)){
                cf.StatusConsignado__c = contratacao.statusContratacao?.trim();
                cf.PropostaId__c = contratacao.chaveContratacao?.trim();
                rt = rts.get('BCSFConsignado');
                cf.RecordTypeId = rt?.Id;
                listaContasConsignadoContratadas.add(cf);
                continue;
            } else if('Cashback'.equalsIgnoreCase(nomeProduto)){
                cf.StatusContrato__c = contratacao.statusContratacao?.trim();
                cf.NumeroContrato__c = contratacao.chaveContratacao?.trim();
                rt = rts.get('Comprou_Voltou');
                cf.RecordTypeId = rt?.Id;
                cf.Produto__c = 'Comprou Voltou';
                listaContasFinanceirasContratadas.add(cf);
            } else {
                continue;
            }
        }
        
        upsert listaContasFinanceirasCartao NumeroConta__c;
        upsert listaContasFinanceirasContratadas NumeroContrato__c;
        upsert listaContasConsignadoContratadas PropostaId__c;
        return account;
    }
}