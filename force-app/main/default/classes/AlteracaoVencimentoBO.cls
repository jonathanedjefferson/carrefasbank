public without sharing class AlteracaoVencimentoBO {
    public static ContaFinanceiraTO tratarContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = AlteracaoVencimentoDAO.getContaFinanceiraById(recordId);
        ContaFinanceiraTO contaTratada = new ContaFinanceiraTO();
        contaTratada.NumeroConta = contaFinanceira.NumeroConta__c == null?'--': contaFinanceira.NumeroConta__c;
        contaTratada.Nome = contaFinanceira.NomeCliente__r.Name == null?'--': contaFinanceira.NomeCliente__r.Name;
        contaTratada.CPF = contaFinanceira.NomeCliente__r.CPF__c == null?'--': formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        contaTratada.DataNascimento = contaFinanceira.NomeCliente__r.DataNascimento__c == null?'--': formatarData(contaFinanceira.NomeCliente__r.DataNascimento__c); 
        contaTratada.TipoConta = contaFinanceira.TipoConta__c == null?'--': contaFinanceira.TipoConta__c;
        contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        List<String> listNegocios = new List<String>{'1','2','6'};
        if(!listNegocios.contains(contaTratada.UnidadeNegocio)){
            contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        }
        contaTratada.StatusConta = contaFinanceira.StatusConta__c == null?'--': contaFinanceira.StatusConta__c;
        contaTratada.AccountId = contaFinanceira.NomeCliente__c == null?'--': contaFinanceira.NomeCliente__c;

        contaTratada.CelularSeguro = contaFinanceira.celularSeguro__c?'Possui Celular Seguro': 'Não possui Celular Seguro';
        contaTratada.Numero = contaFinanceira.Numero__c == null?'--': String.valueOf(contaFinanceira.Numero__c);
        contaTratada.Complemento = contaFinanceira.Complemento__c == null?'--': contaFinanceira.Complemento__c;
        contaTratada.Bairro = contaFinanceira.Bairro__c == null?'--': contaFinanceira.Bairro__c;
        contaTratada.Rua = contaFinanceira.Rua__c == null?'--': contaFinanceira.Rua__c;
        contaTratada.Estado = contaFinanceira.Estado__c == null?'--': contaFinanceira.Estado__c;
        contaTratada.Cidade = contaFinanceira.Cidade__c == null?'--': contaFinanceira.Cidade__c;
        contaTratada.Email = contaFinanceira.Email__c == null?'--': contaFinanceira.Email__c;
        contaTratada.TipoEnvio = contaFinanceira.ModoRecebimentoFatura__c == null?'--': contaFinanceira.ModoRecebimentoFatura__c;
        
        System.debug('Debug tipo conta: ' + contaTratada.TipoConta);
        System.debug('Debug unidade de negocio: ' + contaTratada.UnidadeNegocio);

        return contaTratada;
    }

    public static AssetTO tratarAsset(String contaFinanceiraId){
        List<Asset> listCartao = AlteracaoVencimentoDAO.getAssetByContaFinanceira(contaFinanceiraId);
        AssetTO cartaoRetorno = new AssetTO();
        cartaoRetorno.ProductName = '--';

        for (Asset item: listCartao) {
            if (item.CartaoPrimario__c ) {
                cartaoRetorno.ProductName = item.Product2.Name == null?'--': item.Product2.Name;
                break;
            }
        }
        
        return cartaoRetorno;
    }

    public static DataVencimentoTO getDataVencimentoFatura(String cpf, String numeroConta, String canal, String idEmpresa){
        IntegracoesFaturas.OutputGetDataVencimentoFatura outputDataVencimento = IntegracoesFaturas.GetDataVencimentoFatura(cpf, numeroConta, canal, idEmpresa);
        DataVencimentoTO retorno = new DataVencimentoTO();
        retorno.UltimaAlteracaoMenos6Meses = false;
        retorno.StatusAPI = outputDataVencimento.StatusAPI;
        retorno.dataDisponivelAlteracao = '--';
        
        if (outputDataVencimento.StatusAPI.equalsIgnoreCase('OK')) {
            if (outputDataVencimento.dataUltimaAlteracao != null) {
                Date dataVerifica6Meses = Date.valueOf(outputDataVencimento.dataUltimaAlteracao).addDays(186);

                if (Date.today() < dataVerifica6Meses) {
                    retorno.UltimaAlteracaoMenos6Meses = true;
                }
                retorno.dataDisponivelAlteracao = formatarData(dataVerifica6Meses);
            }
            
            retorno.alteracaoPermitida = outputDataVencimento.alteracaoPermitida ? 'Permitido Alterar' : 'Não Permitido Alterar';
            retorno.diaVencimento = outputDataVencimento.dataVencimento == null ? '--' : String.valueOf(Date.valueOf(outputDataVencimento.dataVencimento).day());
            retorno.dataUltimaAlteracao = outputDataVencimento.dataUltimaAlteracao == null ? '--' : formatarData(Date.valueOf(outputDataVencimento.dataUltimaAlteracao));
            retorno.listaDiasVencimento = outputDataVencimento.listaDiasVencimento.size() == 0 ? new List<Integer>() : outputDataVencimento.listaDiasVencimento;
            retorno.dataFechamento = outputDataVencimento.dataFechamento == null ? '--' : formatarData(Date.valueOf(outputDataVencimento.dataFechamento));
            retorno.dataVencimento = outputDataVencimento.dataVencimento == null ? '--' : formatarData(Date.valueOf(outputDataVencimento.dataVencimento));
        }
        return retorno;
    }

    public static DataVencimentoTO getDataVencimentoAtualizadaFatura(String cpf, String numeroConta, String canal, String idEmpresa){
        IntegracoesFaturas.OutputGetDataVencimentoFatura outputDataVencimento = IntegracoesFaturas.GetDataVencimentoAtualizadaFatura(cpf, numeroConta, canal, idEmpresa);
        DataVencimentoTO retorno = new DataVencimentoTO();
        retorno.StatusAPI = outputDataVencimento.StatusAPI;
        
        if (outputDataVencimento.StatusAPI.equalsIgnoreCase('OK')) {           
            retorno.dataFechamento = outputDataVencimento.dataFechamento == null ? '--' : formatarData(Date.valueOf(outputDataVencimento.dataFechamento));
            retorno.dataVencimento = outputDataVencimento.dataVencimento == null ? '--' : formatarData(Date.valueOf(outputDataVencimento.dataVencimento));
        }

        return retorno;
    }
    
    public static AlterarVencimentoTO alterarDataVencimento(String cpf, String numeroConta, String canal, String area, String sistema, String idEmpresa, String novoDiaVencimento){
        IntegracoesFaturas.OutputAlterarVencimento retornoAPI = IntegracoesFaturas.AlterarVencimento(cpf, numeroConta, canal, area, sistema, idEmpresa, novoDiaVencimento);
        AlterarVencimentoTO objRetorno = new AlterarVencimentoTO();
        objRetorno.StatusAPI = retornoAPI.StatusAPI;
        return objRetorno;
    }

    public static Case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Fatura';
        cs.Evento__c = 'Alteração de vencimento';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return AlteracaoVencimentoDAO.getCase(cs.id);
    }



    public static String formatarData(Date data){
        String dia = data.day()<10?'0'+data.day():String.valueOf(data.day());
        String mes = data.month()<10?'0'+data.month():String.valueOf(data.month());
        String ano = String.valueOf(data.year());
        String dataFormatada = dia+'/'+mes+'/'+ano;
        return dataFormatada;
    }

    public static String formatarCPF(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna o CPF original se não tiver 11 dígitos
        }
        String retorno = cpf.substring(0, 3) + '.' + cpf.substring(3, 6) + '.' + cpf.substring(6, 9) + '-' + cpf.substring(9, 11);
        return retorno;
    }

    public class AssetTO{
        @AuraEnabled
        public String ProductName{get; set;}
    }

    public class ContaFinanceiraTO{
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String Nome{get; set;}
        @AuraEnabled
        public String NumeroConta{get; set;}
        @AuraEnabled
        public String CPF {get; set;}
        @AuraEnabled
        public String DataNascimento {get; set;}
        @AuraEnabled
        public String StatusConta {get; set;}
        @AuraEnabled
        public String TipoConta {get; set;}
        @AuraEnabled
        public String CelularSeguro {get; set;}
        @AuraEnabled
        public String CEP {get; set;}
        @AuraEnabled
        public String Rua {get; set;}
        @AuraEnabled
        public String Numero {get; set;}
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
        public String TipoEnvio {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String UnidadeNegocio {get; set;}
    }

    public class DataVencimentoTO{
        @AuraEnabled
        public String alteracaoPermitida{get; set;}
        @AuraEnabled
        public String dataUltimaAlteracao{get; set;}
        @AuraEnabled
        public String diaVencimento{get; set;}
        @AuraEnabled
        public String dataVencimento{get; set;}
        @AuraEnabled
        public String dataFechamento{get; set;}
        @AuraEnabled
        public String dataDisponivelAlteracao{get; set;}
        @AuraEnabled
        public String StatusAPI{get; set;}
        @AuraEnabled
        public Boolean UltimaAlteracaoMenos6Meses{get; set;}
        @AuraEnabled
        public List<Integer> listaDiasVencimento {get; set;}
    }

    public class AlterarVencimentoTO{
        @AuraEnabled
        public String StatusAPI{get; set;}
    }
}