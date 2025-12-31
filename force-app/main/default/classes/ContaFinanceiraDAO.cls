public without sharing class ContaFinanceiraDAO {
    
    private static final ContaFinanceiraDAO instance = new ContaFinanceiraDAO();

    public static ContaFinanceiraDAO getInstance() {
      return instance;
    }

    public ContaFinanceira__c getDadosContaFinanceira(String idContaFinanceira) {
        List<ContaFinanceira__c> lst = [
            SELECT 
                Id,
                Name,
                NomeCliente__c,
                NomeCliente__r.Name,
                NomeCliente__r.FirstName,
                NomeCliente__r.LastName,
                NomeCliente__r.CPF__c,
                NomeCliente__r.DataNascimento__c,
                NomeCliente__r.Sexo__c,
                NomeCliente__r.NomeMae__c,
                RG__c,
                NumeroConta__c, 
                TipoConta__c, 
                UnidadeNegocio__c, 
                StatusConta__c,
                CelularSeguro__c,
                CEP__c,
                Rua__c,
                Numero__c,
                Complemento__c,
                Bairro__c,
                Cidade__c,
                Estado__c,
                Telefone__c,
                Email__c,
                CartaoTransversal__c, 
                ModoRecebimentoFatura__c,
                EstadoCivil__c,
                TelefoneResidencial__c,
                EhBlindado__c,
                EhBlindadoFull__c,
                AceitaRecebimentoEmail__c,
                AumentoAltomaticoLimite__c,
                Genero__c,
                DataInicioConta__c
            FROM 
                ContaFinanceira__c WHERE id =: idContaFinanceira];
        return lst.isEmpty() ? null : lst[0];
    }
    
    public ContaFinanceira__c getDadosEndereco(String numeroContaFinanceira) {
        List<ContaFinanceira__c> listaContas =  [
            SELECT 
                CEP__c,
                Rua__c,
                Cidade__c, 
                Bairro__c, 
                Estado__c, 
                Numero__c, 
                Complemento__c
            FROM 
                ContaFinanceira__c
            WHERE
                NumeroConta__c =: numeroContaFinanceira
        ];
        
        return listaContas .isEmpty() ? null : listaContas [0];
    }

    public static ContaFinanceira__c getDadosContaFinanceiraNumero(String numeroContaFinanceira){
        List<ContaFinanceira__c> listaContas =  [
            SELECT 
            Id,
            NomeCliente__c,
            NomeCliente__r.Name,
            NomeCliente__r.FirstName,
            NomeCliente__r.LastName,
            NomeCliente__r.CPF__c,
            NomeCliente__r.DataNascimento__c,
            NomeCliente__r.Sexo__c,
            NomeCliente__r.NomeMae__c,
            UnidadeNegocio__c,
            RG__c,
            NumeroConta__c, 
            CEP__c,
            Rua__c,
            Numero__c,
            Complemento__c,
            Bairro__c,
            Cidade__c,
            Estado__c,
            Telefone__c,
            Email__c
            FROM 
                ContaFinanceira__c
            WHERE
                NumeroConta__c =: numeroContaFinanceira
        ];

        return listaContas .isEmpty() ? null : listaContas [0];
    }


    public static ContaFinanceira__c getContaFinanceiraByCpf(String cpf) {
        if (String.isBlank(cpf)) return null;
        String cleanCpf = cpf.replaceAll('[^0-9]', '');
        List<ContaFinanceira__c> contas = [
            SELECT Id, NumeroConta__c, NomeCliente__r.CPF__c
            FROM ContaFinanceira__c
            WHERE NomeCliente__r.CPF__c = :cleanCpf
            LIMIT 1
        ];
        return contas.isEmpty() ? null : contas[0];
    }

    public static List<ContaFinanceira__c> getContaFinanceiraByNumberList(List<String> lNumAccount){
        return [
            SELECT 
                Id,
                NumeroConta__c,
                NomeCliente__r.CPF__c
            FROM 
                ContaFinanceira__c WHERE NumeroConta__c IN :lNumAccount
        ];      
    }

    public ContaFinanceira__c getContaFinanceiraByNumeroConta(String numeroConta) {
        return [
            SELECT 
                Id,
                NomeCliente__r.Id
            FROM 
                ContaFinanceira__c
            WHERE
                NumeroConta__c = :numeroConta
            LIMIT 1
        ];
    }

}