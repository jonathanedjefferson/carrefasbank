public class AvaliacaoAlteracaoCadastralDAO {
    public static AvaliacaoAlteracaoCadastral__c GetAlteracaoCadastralByCase(String caseId) {
        List<AvaliacaoAlteracaoCadastral__c> lt = [
            SELECT
                Id,
                TelefoneContato__c,
                SolicitacaoCartao__c,
                MudouCPF__c,
                CPF__c,
                CPFOrigin__c,
                Complemento__c,
                ComplementoOrigin__c,
                Cidade__c,
                CidadeOrigin__c,
                Email__c,
                EmailOrigin__c,
                CEP__c,
                CEPOrigin__c,
                NumeroCasa__c,
                NumeroCasaOrigin__c,
                Bairro__c,
                BairroOrigin__c,
                UF__c,
                UFOrigin__c,
                Account__c,
                ContaFinanceira__c,
                Case__c,
                Rua__c,
                RuaOrigin__c,
                TelefoneResidencial__c,
                TelefoneResidencialOrigin__c,
                TelefoneCelular__c,
                TelefoneCelularOrign__c,
                ContaFinanceira__r.NumeroConta__c,
                ContaFinanceira__r.UnidadeNegocio__c,
                Account__r.CPF__c
            FROM 
                AvaliacaoAlteracaoCadastral__c
            WHERE
                Case__c = :caseId 
        ];

        return lt.size() == 0 ? null : lt[0];
    }
}