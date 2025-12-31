public without sharing class RefinanciamentoBO {
    public static ContaFinanceiraTO tratarContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = RefinanciamentoDAO.getContaFinanceiraById(recordId);
        ContaFinanceiraTO contaTratada = new ContaFinanceiraTO();
        contaTratada.Telefone           = contaFinanceira.Telefone__c                           == null ? '--' : contaFinanceira.Telefone__c;
        contaTratada.Celular            = String.valueOf(contaFinanceira.Celular__c)            == null ? '--' : String.valueOf(contaFinanceira.Celular__c);
        contaTratada.NumeroConta        = contaFinanceira.NumeroConta__c                        == null ? '--' : contaFinanceira.NumeroConta__c;
        contaTratada.Nome               = contaFinanceira.NomeCliente__r.Name                   == null ? '--' : contaFinanceira.NomeCliente__r.Name;
        contaTratada.CPF                = contaFinanceira.NomeCliente__r.CPF__c                 == null ? '--' : Util.formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        contaTratada.DataNascimento     = contaFinanceira.NomeCliente__r.DataNascimento__c      == null ? '--' : Util.formatarData(contaFinanceira.NomeCliente__r.DataNascimento__c); 
        contaTratada.UnidadeNegocio     = contaFinanceira.UnidadeNegocio__c                     == null ? '--' : contaFinanceira.UnidadeNegocio__c;
        contaTratada.StatusConta        = contaFinanceira.StatusConta__c                        == null ? '--' : contaFinanceira.StatusConta__c;
        contaTratada.AccountId          = contaFinanceira.NomeCliente__c                        == null ? '--' : contaFinanceira.NomeCliente__c;
        contaTratada.Numero             = contaFinanceira.Numero__c                             == null ? '--' : String.valueOf(contaFinanceira.Numero__c);
        contaTratada.Complemento        = contaFinanceira.Complemento__c                        == null ? '--' : contaFinanceira.Complemento__c;
        contaTratada.Bairro             = contaFinanceira.Bairro__c                             == null ? '--' : contaFinanceira.Bairro__c;
        contaTratada.Rua                = contaFinanceira.Rua__c                                == null ? '--' : contaFinanceira.Rua__c;
        contaTratada.Estado             = contaFinanceira.Estado__c                             == null ? '--' : contaFinanceira.Estado__c;
        contaTratada.Cidade             = contaFinanceira.Cidade__c                             == null ? '--' : contaFinanceira.Cidade__c;
        contaTratada.Email              = contaFinanceira.Email__c                              == null ? '--' : contaFinanceira.Email__c;
        contaTratada.TipoEnvio          = contaFinanceira.ModoRecebimentoFatura__c              == null ? '--' : contaFinanceira.ModoRecebimentoFatura__c;
        contaTratada.NumeroContrato     = contaFinanceira.NumeroContrato__c                     == null ? '--' : contaFinanceira.NumeroContrato__c;
        contaTratada.CelularSeguro      = contaFinanceira.celularSeguro__c                              ? 'Possui Celular Seguro' : 'Não possui Celular Seguro';
        
        return contaTratada;
    }

    public static OutputCalcularSimulacaoRefinanciamento CalcularSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, String idProposta, Boolean usarMargem, Boolean receberTroco, Integer quantidadeParcelas, Decimal valorTroco){
        IntegrationConsignado.OutputCalcularSimulacaoRefinanciamento retornoAPI = IntegrationConsignado.CalcularSimulacaoRefinanciamento(cpf, canal, unidadeNegocio, idProposta, usarMargem, receberTroco, quantidadeParcelas, valorTroco);
        OutputCalcularSimulacaoRefinanciamento retorno = new OutputCalcularSimulacaoRefinanciamento();
        retorno.StatusAPI = retornoAPI.StatusAPI;
        
        if(retornoAPI.StatusAPI.equalsIgnoreCase('OK')){
            for(IntegrationConsignado.Simulacoes item: retornoAPI.simulacoes){
                if(item.taxasDetalhadas != null){
                    DetalhesPorParcela detalhes = new DetalhesPorParcela();
                    detalhes.QuantidadeDeParcelas                                   = item.resumo.prazo;
                    detalhes.NovaTaxa                                               = item.resumo.novaTaxa;
                    detalhes.NovoValorParcela                                       = item.resumo.parcela;
                    detalhes.NovoValorTotal                                         = item.resumo.novoValorEmprestimo;
                    detalhes.ValorTroco                                             = item.resumo.valorTroco;
                    
                    detalhes.requestGravarSimulacao.propostaId                      = idProposta;
                    detalhes.requestGravarSimulacao.valorTotalReceber               = item.resumo.valorTroco;
                    detalhes.requestGravarSimulacao.quantidadeParcelas              = item.resumo.prazo;
                    detalhes.requestGravarSimulacao.valorParcelas                   = item.resumo.parcela;
                    detalhes.requestGravarSimulacao.valorTotalPagar                 = item.taxasDetalhadas.taxasCobradas.valorTotalPagar;
                    detalhes.requestGravarSimulacao.cetAnualPercentual              = item.taxasDetalhadas.jurosCet.cetMaximoCustoEfetivoTotalAnual;
                    detalhes.requestGravarSimulacao.cetMensalPercentual             = item.taxasDetalhadas.jurosCet.cetMaximoCustoEfetivoTotalMensal;
                    detalhes.requestGravarSimulacao.despesasVinculadas              = item.taxasDetalhadas.taxasCobradas.despesasVinculadas;
                    detalhes.requestGravarSimulacao.despesasVinculadasPercentual    = item.taxasDetalhadas.taxasCobradas.despesasVinculadasPercentual;
                    detalhes.requestGravarSimulacao.encargos                        = item.taxasDetalhadas.despesasVinculadas.encargos;
                    detalhes.requestGravarSimulacao.encargosPercentual              = Decimal.valueOf(item.taxasDetalhadas.despesasVinculadas.encargosPercentual);
                    detalhes.requestGravarSimulacao.valorIofAdicional               = item.taxasDetalhadas.despesasVinculadas.iofAdicional;
                    detalhes.requestGravarSimulacao.iofAdicionalPercentual          = Decimal.valueOf(item.taxasDetalhadas.despesasVinculadas.iofAdicionalPercentual);
                    detalhes.requestGravarSimulacao.valorIofDiario                  = item.taxasDetalhadas.despesasVinculadas.iofDiario;
                    detalhes.requestGravarSimulacao.iofDiarioPercentual             = Decimal.valueOf(item.taxasDetalhadas.despesasVinculadas.iofDiarioPercentual);
                    detalhes.requestGravarSimulacao.valorIofTotal                   = item.resumo.iofTotal;
                    detalhes.requestGravarSimulacao.valorJuros                      = item.taxasDetalhadas.despesasVinculadas.encargos;
                    detalhes.requestGravarSimulacao.valorJurosMensal                = item.taxasDetalhadas.jurosCet.valorJurosMensal;
                    detalhes.requestGravarSimulacao.taxaJurosMensal                 = item.resumo.novaTaxa;
                    detalhes.requestGravarSimulacao.taxaJurosAnual                  = item.taxasDetalhadas.jurosCet.taxaJurosAnual;
                    detalhes.requestGravarSimulacao.valorSaldoDevedor               = retornoAPI.valorSaldoDevedor;
                    detalhes.requestGravarSimulacao.valorPrincipal                  = item.resumo.valorFinanciado;
                    detalhes.requestGravarSimulacao.valorTroco                      = item.resumo.valorTroco;
                    detalhes.requestGravarSimulacao.valorFinanciado                 = item.resumo.valorFinanciado;
                    detalhes.requestGravarSimulacao.valorEmprestimoPercentual       = item.resumo.valorEmprestimoPercentual;
                    detalhes.requestGravarSimulacao.seguros                         = 0;
                    detalhes.requestGravarSimulacao.tarifas                         = 0;

                    retorno.ListDetalhesPorParcela.add(detalhes);
                    retorno.ListOpcoesParcelas.add(item.resumo.prazo);
                }
            }
        }

        return retorno;
    }

    public static Case CriarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio, String origem, String canal) {
        RecordType rt = RefinanciamentoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId              = UserInfo.getUserId();
        cs.NomeCliente__c       = accountId;
        cs.RecordTypeId         = rt.Id;
        cs.Status               = 'Closed';
        cs.Assunto__c           = 'Crédito Consignado';
        cs.Evento__c            = 'Refinanciamento';
        cs.Origin               = origem;
        cs.CanalEntrada__c      = canal;
        cs.ContaFinanceira__c   = contaFinanceiraId;   
        cs.UnidadeNegocio__c    = unidadeNegocio;  
        cs.Type                 = 'Execução';
        cs.Priority             = 'Medium';

        insert cs;
        return RefinanciamentoDAO.getCase(cs.id);
    }

    public static Consignado__c CriarConsignado(String contaFinanceiraId, String accountId, String caseId,  String unidadeNegocio, String inputInfoConsignado, String telefone){
        InputConsignado inpCsg = (InputConsignado) System.JSON.deserialize(inputInfoConsignado, InputConsignado.class);
        System.debug('CriarConsignado - telefone -> ' + telefone);
        Account lAccount = [SELECT Id, UltimoContato__c FROM Account WHERE Id =: accountId];
        
        Consignado__c csg = new Consignado__c();
        csg.ContaFinanceira__c                      = contaFinanceiraId;
        csg.Conta__c                                = accountId;
        csg.Caso__c                                 = caseId;
        csg.UnidadeNegocio__c                       = unidadeNegocio;
        csg.NomeCliente__c                          = inpCsg.NomeCliente                            == null ? '--' : inpCsg.NomeCliente;
        csg.Telefone__c                             = telefone                                      == null ? '--' : telefone;
        csg.TelefoneAntigo__c                       = lAccount.UltimoContato__c                     == null ? '--' : lAccount.UltimoContato__c;
        csg.NumeroContrato__c                       = inpCsg.NumeroContrato                         == null ? '--' : inpCsg.NumeroContrato;
        csg.LinkRefinanciamento__c                  = inpCsg.LinkRefinanciamento                    == null ? '--' : inpCsg.LinkRefinanciamento;
        csg.ValorTotalRefinanciamento__c            = inpCsg.ValorTotalRefinanciamento              == null ? '--' : inpCsg.ValorTotalRefinanciamento;
        csg.NovaTaxaRefinanciamento__c              = inpCsg.NovaTaxaRefinanciamento                == null ? '--' : inpCsg.NovaTaxaRefinanciamento;
        csg.NovaParcelaRefinanciamento__c           = inpCsg.NovaParcelaRefinanciamento             == null ? '--' : inpCsg.NovaParcelaRefinanciamento;
        csg.IdOfertaRefinanciemento__c              = inpCsg.IdOfertaRefinanciemento                == null ? '--' : inpCsg.IdOfertaRefinanciemento;
        csg.ValorTrocoRefinanciamento__c            = inpCsg.ValorTrocoRefinanciamento              == '0'  ? '--' : inpCsg.ValorTrocoRefinanciamento;
        csg.QuantidadeParcelasRefinanciamento__c    = inpCsg.QuantidadeParcelasRefinanciamento      == null ? null : inpCsg.QuantidadeParcelasRefinanciamento;
        csg.TrocoRefinanciamento__c                 = inpCsg.TrocoRefinanciamento                   == null ? false : inpCsg.TrocoRefinanciamento;

        insert csg;
        updatePhoneOnAccount(lAccount, telefone);
        return csg;
    }

    private static void updatePhoneOnAccount(Account lAccount, String telefone) {
        if (String.isBlank(telefone)) {
            return;
        }

        lAccount.UltimoContato__c = telefone;
        update lAccount;
    }

// #################### RESPONSE REFERENTE AO MÉTODO 'tratarContaFinanceira' ####################
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
        public String UnidadeNegocio {get; set;}
        @AuraEnabled
        public String CelularSeguro {get; set;}
        @AuraEnabled
        public String NumeroContrato {get; set;}
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
        public String Celular {get; set;}
        @AuraEnabled
        public String TipoEnvio {get; set;}
        @AuraEnabled
        public String Email {get; set;}
    }
// #################### FIM RESPONSE 'tratarContaFinanceira' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'CalcularSimulacaoRefinanciamento' ####################
    public class OutputCalcularSimulacaoRefinanciamento {
        @AuraEnabled
        public String StatusAPI;   
        @AuraEnabled
        public List<Integer> ListOpcoesParcelas;
        @AuraEnabled
        public List<DetalhesPorParcela> ListDetalhesPorParcela;

        public OutputCalcularSimulacaoRefinanciamento(){
            this.ListOpcoesParcelas = new List<Integer>();
            this.ListDetalhesPorParcela = new List<DetalhesPorParcela>();
        }
    }
    
    public class DetalhesPorParcela{
        @AuraEnabled
        public Integer QuantidadeDeParcelas;
        @AuraEnabled
        public Decimal NovaTaxa;
        @AuraEnabled
        public Decimal NovoValorTotal;
        @AuraEnabled
        public Decimal NovoValorParcela;
        @AuraEnabled
        public Decimal ValorTroco;
        @AuraEnabled
        public RequestGravarSimulacao requestGravarSimulacao;

        public DetalhesPorParcela(){
            this.requestGravarSimulacao = new requestGravarSimulacao();
        }
    }

    public class RequestGravarSimulacao{
        @AuraEnabled
        public String propostaId;
        @AuraEnabled
        public Decimal valorTotalReceber;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public Decimal valorParcelas;
        @AuraEnabled
        public Decimal valorTotalPagar;
        @AuraEnabled
        public Decimal cetAnualPercentual;
        @AuraEnabled
        public Decimal cetMensalPercentual;
        @AuraEnabled
        public Decimal despesasVinculadas;
        @AuraEnabled
        public Decimal despesasVinculadasPercentual;
        @AuraEnabled
        public Decimal encargos;
        @AuraEnabled
        public Decimal encargosPercentual;
        @AuraEnabled
        public Decimal valorIofAdicional;
        @AuraEnabled
        public Decimal iofAdicionalPercentual;
        @AuraEnabled
        public Decimal valorIofDiario;
        @AuraEnabled
        public Decimal iofDiarioPercentual;
        @AuraEnabled
        public Decimal seguros;
        @AuraEnabled
        public Decimal valorIofTotal;
        @AuraEnabled
        public Decimal valorJuros;
        @AuraEnabled
        public Decimal valorJurosMensal;
        @AuraEnabled
        public Decimal valorEmprestimoPercentual;
        @AuraEnabled
        public Decimal tarifas;
        @AuraEnabled
        public Decimal taxaJurosMensal;
        @AuraEnabled
        public Decimal taxaJurosAnual;
        @AuraEnabled
        public Decimal valorSaldoDevedor;
        @AuraEnabled
        public Decimal valorPrincipal;
        @AuraEnabled
        public Decimal valorTroco;
        @AuraEnabled
        public Decimal valorFinanciado;
    }
// #################### FIM RESPONSE 'CalcularSimulacaoRefinanciamento' ####################

// #################### INPUT REFERENTE AO MÉTODO 'CriarConsignado' ####################
    public class InputConsignado{
        public String NomeCliente;
        public String Telefone;
        public String NumeroContrato;
        public String LinkRefinanciamento;
        public String ValorTotalRefinanciamento;
        public String NovaTaxaRefinanciamento;
        public String NovaParcelaRefinanciamento;
        public String ValorTrocoRefinanciamento;
        public String IdOfertaRefinanciemento;
        public Decimal QuantidadeParcelasRefinanciamento;
        public Boolean TrocoRefinanciamento;
    }
// #################### FIM INPUT 'CriarConsignado' ####################
}