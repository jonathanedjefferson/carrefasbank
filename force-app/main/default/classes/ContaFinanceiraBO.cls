public without sharing class ContaFinanceiraBO {
    public static ContaFinanceira getContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = ContaFinanceiraDAO.getInstance().getDadosContaFinanceira(recordId);
        
        ContaFinanceira toReturn = new ContaFinanceira();
        toReturn.AccountId                  = contaFinanceira.NomeCliente__c                    == null ? '--' : contaFinanceira.NomeCliente__c;
        toReturn.Nome                       = contaFinanceira.NomeCliente__r.Name               == null ? '--' : contaFinanceira.NomeCliente__r.Name;
        toReturn.PrimeiroNome               = contaFinanceira.NomeCliente__r.FirstName          == null ? '--' : contaFinanceira.NomeCliente__r.FirstName;
        toReturn.UltimoNome                 = contaFinanceira.NomeCliente__r.LastName           == null ? '--' : contaFinanceira.NomeCliente__r.LastName;
        toReturn.RG                         = contaFinanceira.RG__c                             == null ? '--' : Util.formatRG(contaFinanceira.RG__c);
        toReturn.CPF                        = contaFinanceira.NomeCliente__r.CPF__c             == null ? '--' : Util.formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        toReturn.DataNascimento             = contaFinanceira.NomeCliente__r.DataNascimento__c  == null ? '--' : Util.formatarData(contaFinanceira.NomeCliente__r.DataNascimento__c); 
        toReturn.NomeMae                    = contaFinanceira.NomeCliente__r.NomeMae__c         == null ? '--' : contaFinanceira.NomeCliente__r.NomeMae__c; 
        toReturn.Genero                     = contaFinanceira.Genero__c                         == null ? '--' : contaFinanceira.Genero__c; 
        toReturn.NumeroConta                = contaFinanceira.NumeroConta__c                    == null ? '--' : contaFinanceira.NumeroConta__c;
        toReturn.StatusConta                = contaFinanceira.StatusConta__c                    == null ? '--' : contaFinanceira.StatusConta__c;
        toReturn.TipoConta                  = contaFinanceira.TipoConta__c                      == null ? '--' : contaFinanceira.TipoConta__c;
        toReturn.UnidadeNegocio             = contaFinanceira.UnidadeNegocio__c                 == null ? '--' : contaFinanceira.UnidadeNegocio__c;
        toReturn.CelularSeguro              = contaFinanceira.celularSeguro__c                          ? 'Possui Celular Seguro': 'Não possui Celular Seguro';
        toReturn.CEP                        = contaFinanceira.CEP__c                            == null ? '--' : contaFinanceira.CEP__c;
        toReturn.Rua                        = contaFinanceira.Rua__c                            == null ? '--' : contaFinanceira.Rua__c;
        toReturn.NumeroCasa                 = contaFinanceira.Numero__c                         == null ? '--' : String.valueOf(contaFinanceira.Numero__c);
        toReturn.Complemento                = contaFinanceira.Complemento__c                    == null ? '--' : contaFinanceira.Complemento__c;
        toReturn.Bairro                     = contaFinanceira.Bairro__c                         == null ? '--' : contaFinanceira.Bairro__c;
        toReturn.Cidade                     = contaFinanceira.Cidade__c                         == null ? '--' : contaFinanceira.Cidade__c;
        toReturn.Estado                     = contaFinanceira.Estado__c                         == null ? '--' : contaFinanceira.Estado__c;
        toReturn.Telefone                   = contaFinanceira.Telefone__c                       == null ? '--' : contaFinanceira.Telefone__c;
        toReturn.Email                      = contaFinanceira.Email__c                          == null ? '--' : contaFinanceira.Email__c;
        toReturn.EstadoCivil                = contaFinanceira.EstadoCivil__c                    == null ? '--' : contaFinanceira.EstadoCivil__c;
        toReturn.ModoRecebimentoFatura      = contaFinanceira.ModoRecebimentoFatura__c          == null ? '--' : contaFinanceira.ModoRecebimentoFatura__c;
        toReturn.TelefoneResidencial        = contaFinanceira.TelefoneResidencial__c            == null ? '--' : contaFinanceira.TelefoneResidencial__c;
        toReturn.NomeConta                  = contaFinanceira.Name                              == null ? '--' : contaFinanceira.Name;
        toReturn.DataInicioConta            = contaFinanceira.DataInicioConta__c                == null ? '--' : Util.formatarData(contaFinanceira.DataInicioConta__c);
        toReturn.ClienteBlindado            = contaFinanceira.EhBlindado__c;
        toReturn.ClienteBlindadoFull        = contaFinanceira.EhBlindadoFull__c;
        toReturn.AceitaRecebimentoEmail     = contaFinanceira.AceitaRecebimentoEmail__c;
        toReturn.AumentoAltomaticoLimite    = contaFinanceira.AumentoAltomaticoLimite__c;
        toReturn.CartaoTransversal          = contaFinanceira.CartaoTransversal__c;
        // OBTENDO OS VALORES DA PICKLIST ContaFinanceira__c.EstadoCivil__c
        Schema.DescribeFieldResult fieldDescription = ContaFinanceira__c.EstadoCivil__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();
        PickListValues plv = new PickListValues();
        plv.Campo = 'EstadoCivil__c';
        for (Schema.PicklistEntry item : entries) {
            if (item.isActive()) {
                Values vl = new Values();        
                vl.ApiName = item.getValue();
                vl.Label = item.getLabel();
                plv.Valores.add(vl);
            }
        }
        toReturn.PickListValues.add(plv);

        return toReturn;
    }

    public class ContaFinanceira {
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String NomeConta{get; set;}
        @AuraEnabled
        public String Nome{get; set;}
        @AuraEnabled
        public String PrimeiroNome{get; set;}
        @AuraEnabled
        public String UltimoNome{get; set;}
        @AuraEnabled
        public String RG{get; set;}
        @AuraEnabled
        public String CPF {get; set;}
        @AuraEnabled
        public String DataNascimento {get; set;}
        @AuraEnabled
        public String DataInicioConta {get;set;}
        @AuraEnabled
        public String Genero {get; set;}
        @AuraEnabled
        public String NomeMae {get; set;}
        @AuraEnabled
        public String NumeroConta{get; set;}
        @AuraEnabled
        public String StatusConta {get; set;}
        @AuraEnabled
        public String TipoConta {get; set;}
        @AuraEnabled
        public String UnidadeNegocio {get; set;}
        @AuraEnabled
        public Boolean CartaoTransversal {get; set;}
        @AuraEnabled
        public String CelularSeguro {get; set;}
        @AuraEnabled
        public String CEP {get; set;}
        @AuraEnabled
        public String Rua {get; set;}
        @AuraEnabled
        public String NumeroCasa {get; set;}
        @AuraEnabled
        public String Complemento {get; set;}
        @AuraEnabled
        public String Bairro {get; set;}
        @AuraEnabled
        public String Cidade {get; set;}
        @AuraEnabled
        public String Estado {get; set;}
        @AuraEnabled
        public String Telefone {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String EstadoCivil {get; set;}
        @AuraEnabled
        public String ModoRecebimentoFatura {get; set;}
        @AuraEnabled
        public String TelefoneResidencial {get; set;}
        @AuraEnabled
        public Boolean ClienteBlindado {get; set;}
        @AuraEnabled
        public Boolean ClienteBlindadoFull {get; set;}
        @AuraEnabled
        public Boolean AceitaRecebimentoEmail {get; set;}
        @AuraEnabled
        public Boolean AumentoAltomaticoLimite {get; set;}
        @AuraEnabled
        public List<PickListValues> PickListValues {get; set;}

        public ContaFinanceira(){
            this.PickListValues = new List<PickListValues>();
        }
    }
    
    public class PickListValues{
        @AuraEnabled
        public String Campo {get; set;}
        @AuraEnabled
        public List<Values> Valores {get; set;}

        public PickListValues(){
            this.Valores = new List<Values>();
        }
    }
    public class Values{
        @AuraEnabled
        public String ApiName {get; set;}
        @AuraEnabled
        public String Label {get; set;}    
    }

}