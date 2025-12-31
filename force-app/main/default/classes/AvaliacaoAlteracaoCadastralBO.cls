public class AvaliacaoAlteracaoCadastralBO {
    public static AvaliacaoAlteracaoCadastralTO ObterDadosAlteracaoCadastral(String caseId) {
        AvaliacaoAlteracaoCadastralTO retorno = new AvaliacaoAlteracaoCadastralTO();
        AvaliacaoAlteracaoCadastral__c altCadastral = AvaliacaoAlteracaoCadastralDAO.GetAlteracaoCadastralByCase(caseId);
        
        if(altCadastral != null){
            retorno.MudouCPF                    = altCadastral.MudouCPF__c;
            retorno.CPFCliente                  = altCadastral.Account__r.CPF__c                    == null ? '--' : Util.formatarCPF(altCadastral.Account__r.CPF__c);
            retorno.IdAvaliacao                 = altCadastral.Id                                   == null ? '--' : altCadastral.Id;
            retorno.TelefoneContato             = altCadastral.TelefoneContato__c                   == null ? '--' : altCadastral.TelefoneContato__c;
            retorno.SolicitacaoCartao           = altCadastral.SolicitacaoCartao__c                 == null ? '--' : altCadastral.SolicitacaoCartao__c;
            retorno.CPF                         = altCadastral.CPF__c                               == null ? '--' : altCadastral.CPF__c;
            retorno.CPFOrigin                   = altCadastral.CPFOrigin__c                         == null ? '--' : altCadastral.CPFOrigin__c;
            retorno.Complemento                 = altCadastral.Complemento__c                       == null ? '--' : altCadastral.Complemento__c;
            retorno.ComplementoOrigin           = altCadastral.ComplementoOrigin__c                 == null ? '--' : altCadastral.ComplementoOrigin__c;
            retorno.Cidade                      = altCadastral.Cidade__c                            == null ? '--' : altCadastral.Cidade__c;
            retorno.CidadeOrigin                = altCadastral.CidadeOrigin__c                      == null ? '--' : altCadastral.CidadeOrigin__c;
            retorno.Email                       = altCadastral.Email__c                             == null ? '--' : altCadastral.Email__c;
            retorno.EmailOrigin                 = altCadastral.EmailOrigin__c                       == null ? '--' : altCadastral.EmailOrigin__c;
            retorno.CEP                         = altCadastral.CEP__c                               == null ? '--' : altCadastral.CEP__c;
            retorno.CEPOrigin                   = altCadastral.CEPOrigin__c                         == null ? '--' : altCadastral.CEPOrigin__c;
            retorno.NumeroCasa                  = altCadastral.NumeroCasa__c                        == null ? '--' : altCadastral.NumeroCasa__c;
            retorno.NumeroCasaOrigin            = altCadastral.NumeroCasaOrigin__c                  == null ? '--' : altCadastral.NumeroCasaOrigin__c;
            retorno.Bairro                      = altCadastral.Bairro__c                            == null ? '--' : altCadastral.Bairro__c;
            retorno.BairroOrigin                = altCadastral.BairroOrigin__c                      == null ? '--' : altCadastral.BairroOrigin__c;
            retorno.UF                          = altCadastral.UF__c                                == null ? '--' : altCadastral.UF__c;
            retorno.UFOrigin                    = altCadastral.UFOrigin__c                          == null ? '--' : altCadastral.UFOrigin__c;
            retorno.Rua                         = altCadastral.Rua__c                               == null ? '--' : altCadastral.Rua__c;
            retorno.RuaOrigin                   = altCadastral.RuaOrigin__c                         == null ? '--' : altCadastral.RuaOrigin__c;
            retorno.TelefoneResidencial         = altCadastral.TelefoneResidencial__c               == null ? '--' : altCadastral.TelefoneResidencial__c;
            retorno.TelefoneResidencialOrigin   = altCadastral.TelefoneResidencialOrigin__c         == null ? '--' : altCadastral.TelefoneResidencialOrigin__c;
            retorno.TelefoneCelular             = altCadastral.TelefoneCelular__c                   == null ? '--' : altCadastral.TelefoneCelular__c;
            retorno.TelefoneCelularOrign        = altCadastral.TelefoneCelularOrign__c              == null ? '--' : altCadastral.TelefoneCelularOrign__c;
            retorno.IdConta                     = altCadastral.Account__c                           == null ? '--' : altCadastral.Account__c;
            retorno.IdContaFinanceira           = altCadastral.ContaFinanceira__c                   == null ? '--' : altCadastral.ContaFinanceira__c;
            retorno.IdCaso                      = altCadastral.Case__c                              == null ? '--' : altCadastral.Case__c;
            retorno.NumeroConta                 = altCadastral.ContaFinanceira__r.NumeroConta__c    == null ? '--' : altCadastral.ContaFinanceira__r.NumeroConta__c;
            retorno.UnidadeNegocio              = altCadastral.ContaFinanceira__r.UnidadeNegocio__c == null ? '--' : altCadastral.ContaFinanceira__r.UnidadeNegocio__c;       
        }else{
            return null;
        }

        return retorno;
    }

    public static void CriarAvaliacaoAlteracao(AvaliacaoAlteracaoCadastralTO avaliacao){
        if(avaliacao != null){
            AvaliacaoAlteracaoCadastral__c avaliacaoInsert = new AvaliacaoAlteracaoCadastral__c();

            avaliacaoInsert.MudouCPF__c                     = avaliacao.MudouCPF;
            avaliacaoInsert.TelefoneContato__c              = (avaliacao.TelefoneContato            == null || avaliacao.TelefoneContato            == '--') ? null : avaliacao.TelefoneContato;
            avaliacaoInsert.SolicitacaoCartao__c            = (avaliacao.SolicitacaoCartao          == null || avaliacao.SolicitacaoCartao          == '--') ? null : avaliacao.SolicitacaoCartao;
            avaliacaoInsert.CPF__c                          = (avaliacao.CPF                        == null || avaliacao.CPF                        == '--') ? null : avaliacao.CPF;
            avaliacaoInsert.CPFOrigin__c                    = (avaliacao.CPFOrigin                  == null || avaliacao.CPFOrigin                  == '--') ? null : avaliacao.CPFOrigin;
            avaliacaoInsert.Complemento__c                  = (avaliacao.Complemento                == null || avaliacao.Complemento                == '--') ? null : avaliacao.Complemento;
            avaliacaoInsert.ComplementoOrigin__c            = (avaliacao.ComplementoOrigin          == null || avaliacao.ComplementoOrigin          == '--') ? null : avaliacao.ComplementoOrigin;
            avaliacaoInsert.Cidade__c                       = (avaliacao.Cidade                     == null || avaliacao.Cidade                     == '--') ? null : avaliacao.Cidade;
            avaliacaoInsert.CidadeOrigin__c                 = (avaliacao.CidadeOrigin               == null || avaliacao.CidadeOrigin               == '--') ? null : avaliacao.CidadeOrigin;
            avaliacaoInsert.Email__c                        = (avaliacao.Email                      == null || avaliacao.Email                      == '--') ? null : avaliacao.Email;
            avaliacaoInsert.EmailOrigin__c                  = (avaliacao.EmailOrigin                == null || avaliacao.EmailOrigin                == '--') ? null : avaliacao.EmailOrigin;
            avaliacaoInsert.CEP__c                          = (avaliacao.CEP                        == null || avaliacao.CEP                        == '--') ? null : avaliacao.CEP;
            avaliacaoInsert.CEPOrigin__c                    = (avaliacao.CEPOrigin                  == null || avaliacao.CEPOrigin                  == '--') ? null : avaliacao.CEPOrigin;
            avaliacaoInsert.NumeroCasa__c                   = (avaliacao.NumeroCasa                 == null || avaliacao.NumeroCasa                 == '--') ? null : avaliacao.NumeroCasa;
            avaliacaoInsert.NumeroCasaOrigin__c             = (avaliacao.NumeroCasaOrigin           == null || avaliacao.NumeroCasaOrigin           == '--') ? null : avaliacao.NumeroCasaOrigin;
            avaliacaoInsert.Bairro__c                       = (avaliacao.Bairro                     == null || avaliacao.Bairro                     == '--') ? null : avaliacao.Bairro;
            avaliacaoInsert.BairroOrigin__c                 = (avaliacao.BairroOrigin               == null || avaliacao.BairroOrigin               == '--') ? null : avaliacao.BairroOrigin;
            avaliacaoInsert.UF__c                           = (avaliacao.UF                         == null || avaliacao.UF                         == '--') ? null : avaliacao.UF;
            avaliacaoInsert.UFOrigin__c                     = (avaliacao.UFOrigin                   == null || avaliacao.UFOrigin                   == '--') ? null : avaliacao.UFOrigin;
            avaliacaoInsert.Account__c                      = (avaliacao.IdConta                    == null || avaliacao.IdConta                    == '--') ? null : avaliacao.IdConta;
            avaliacaoInsert.ContaFinanceira__c              = (avaliacao.IdContaFinanceira          == null || avaliacao.IdContaFinanceira          == '--') ? null : avaliacao.IdContaFinanceira;
            avaliacaoInsert.Case__c                         = (avaliacao.IdCaso                     == null || avaliacao.IdCaso                     == '--') ? null : avaliacao.IdCaso;
            avaliacaoInsert.Rua__c                          = (avaliacao.Rua                        == null || avaliacao.Rua                        == '--') ? null : avaliacao.Rua;
            avaliacaoInsert.RuaOrigin__c                    = (avaliacao.RuaOrigin                  == null || avaliacao.RuaOrigin                  == '--') ? null : avaliacao.RuaOrigin;
            avaliacaoInsert.TelefoneResidencial__c          = (avaliacao.TelefoneResidencial        == null || avaliacao.TelefoneResidencial        == '--') ? null : avaliacao.TelefoneResidencial;
            avaliacaoInsert.TelefoneResidencialOrigin__c    = (avaliacao.TelefoneResidencialOrigin  == null || avaliacao.TelefoneResidencialOrigin  == '--') ? null : avaliacao.TelefoneResidencialOrigin;
            avaliacaoInsert.TelefoneCelular__c              = (avaliacao.TelefoneCelular            == null || avaliacao.TelefoneCelular            == '--') ? null : avaliacao.TelefoneCelular;
            avaliacaoInsert.TelefoneCelularOrign__c         = (avaliacao.TelefoneCelularOrign       == null || avaliacao.TelefoneCelularOrign       == '--') ? null : avaliacao.TelefoneCelularOrign;        
            
            insert avaliacaoInsert;
        }
    }

    public class AvaliacaoAlteracaoCadastralTO{
        @AuraEnabled
        public Boolean MudouCPF {get;set;}
        @AuraEnabled
        public String IdAvaliacao {get;set;}
        @AuraEnabled
        public String TelefoneContato {get;set;}
        @AuraEnabled
        public String SolicitacaoCartao {get;set;}
        @AuraEnabled
        public String CPFCliente {get;set;}
        @AuraEnabled
        public String CPF {get;set;}
        @AuraEnabled
        public String CPFOrigin {get;set;}
        @AuraEnabled
        public String Complemento {get;set;}
        @AuraEnabled
        public String ComplementoOrigin {get;set;}
        @AuraEnabled
        public String Cidade {get;set;}
        @AuraEnabled
        public String CidadeOrigin {get;set;}
        @AuraEnabled
        public String Email {get;set;}
        @AuraEnabled
        public String EmailOrigin {get;set;}
        @AuraEnabled
        public String CEP {get;set;}
        @AuraEnabled
        public String CEPOrigin {get;set;}
        @AuraEnabled
        public String NumeroCasa {get;set;}
        @AuraEnabled
        public String NumeroCasaOrigin {get;set;}
        @AuraEnabled
        public String Bairro {get;set;}
        @AuraEnabled
        public String BairroOrigin {get;set;}
        @AuraEnabled
        public String UF {get;set;}
        @AuraEnabled
        public String UFOrigin {get;set;}
        @AuraEnabled
        public String IdConta {get;set;}
        @AuraEnabled
        public String IdContaFinanceira {get;set;}
        @AuraEnabled
        public String IdCaso {get;set;}
        @AuraEnabled
        public String NumeroConta {get;set;}
        @AuraEnabled
        public String UnidadeNegocio {get;set;}
        @AuraEnabled
        public String Rua {get;set;}
        @AuraEnabled
        public String RuaOrigin {get;set;}
        @AuraEnabled
        public String TelefoneResidencial {get;set;}
        @AuraEnabled
        public String TelefoneResidencialOrigin {get;set;}
        @AuraEnabled
        public String TelefoneCelular {get;set;}
        @AuraEnabled
        public String TelefoneCelularOrign {get;set;}
    }
}