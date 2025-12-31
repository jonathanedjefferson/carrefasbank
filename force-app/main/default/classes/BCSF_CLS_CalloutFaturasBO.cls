public class BCSF_CLS_CalloutFaturasBO {

    public static Case criaOuVinculaCaso(String detalhesEstornoJson, String faturasSelecionadasJson){

        Case cas;
        BCSF_CLS_CalloutFaturasTO.DetalhesEstorno detalhesEstorno = (BCSF_CLS_CalloutFaturasTO.DetalhesEstorno) System.JSON.deserialize(detalhesEstornoJson, BCSF_CLS_CalloutFaturasTO.DetalhesEstorno.class);
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> faturasSelecionadas = (List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura>) System.JSON.deserialize(faturasSelecionadasJson, List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura>.class);

        Database.SaveResult sr;

        if(detalhesEstorno.casoId == null){
            cas = new Case();
            initCase(detalhesEstorno, cas);
            cas.ContaFinanceira__c = detalhesEstorno.contafinanceiraid;
            cas.AccountId = detalhesEstorno.accountid;
            cas.Status = 'New';
                
            sr = Database.insert(cas);

        } else{
            cas = CaseDAO.getInstance().getById(detalhesEstorno.casoId);
            
            if(cas == null) throw new AuraHandledException('Não foi possível concluir o vínculo. O caso escolhido não foi encontrado na base.');

            initCase(detalhesEstorno, cas);

            sr = Database.update(cas);
        }

        if(!sr.isSuccess())
            throw new AuraHandledException('Não foi possível concluir o processo. Motivo: ' + sr.getErrors()[0].getMessage());
        
        List<Database.SaveResult> srLancamentos = criarLancamentosContestados(cas, faturasSelecionadas);
        
        if(!srLancamentos.isEmpty() && !srLancamentos[0].isSuccess()) 
            throw new AuraHandledException('Não foi possível concluir o processo. Motivo: ' + srLancamentos[0].getErrors()[0].getMessage());

        Case caso = CaseDAO.getInstance().getById(cas.Id);
        
        return caso;
    }

    private static Decimal getAbsoluteValue(Decimal value){
        return value == null ? 0 : math.abs(value);
    }

    private static void initCase(BCSF_CLS_CalloutFaturasTO.DetalhesEstorno detalhesEstorno, Case cas){
        cas.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CAS_Atendimento').getRecordTypeId();
        cas.Assunto__c = 'Encargos, Tarifas e Anuidade';
        cas.Type = 'Solicitação';
        cas.CampoControle__c = true;
        cas.UnidadeNegocio__c = detalhesEstorno.unidadeNegocio;
        cas.Description = detalhesEstorno.descricao;
        cas.Origin = detalhesEstorno.Origin;
        cas.CanalEntrada__c = detalhesEstorno.Canal;
        cas.DataRegulatoria__c = detalhesEstorno.dataRegulatoria;
        cas.EncargosRotativos__c = getAbsoluteValue(detalhesEstorno.encargosRotativos);
        cas.EncargosAtraso__c = getAbsoluteValue(detalhesEstorno.encargosAtraso);
        cas.EncargosSaqueVisa__c = getAbsoluteValue(detalhesEstorno.encargosSaqueVisa);
        cas.EncargosSaqueMaster__c = getAbsoluteValue(detalhesEstorno.encargosSaqueMaster);
        cas.EncargosPagamento__c = getAbsoluteValue(detalhesEstorno.encargosPagamento);
        cas.TarifaEmergencial__c = getAbsoluteValue(detalhesEstorno.tarifaAvaliacao);
        cas.TarifaAnuidade__c = getAbsoluteValue(detalhesEstorno.tarifaAnuidade);
        cas.TarifaRetiradaEspecie__c = getAbsoluteValue(detalhesEstorno.tarifaRetirada);
        cas.ValorSolicitado__c = getAbsoluteValue(detalhesEstorno.total);
        cas.TarifaTelesaqueVista__c = getAbsoluteValue(detalhesEstorno.tarifaTelesaqueVista);
        cas.TarifaSaqueVistaMastercard__c  = getAbsoluteValue(detalhesEstorno.tarifaSaqueVistaMastercard);
        cas.TarifaSaqueVistaIntlMastercad__c = getAbsoluteValue(detalhesEstorno.tarifaSaqueVistaInternacionalMaster);
        cas.TarifaSaqueVistaVisa__c = getAbsoluteValue(detalhesEstorno.tarifaSaqueVistaVisa);
        cas.TarifaSaqueVistaIntlVisa__c = getAbsoluteValue(detalhesEstorno.tarifaSaqueVistaInternacionalVisa);
        cas.TarifaSaqueVistaTecBan__c = getAbsoluteValue(detalhesEstorno.tarifaSaqueVistaTecban);
        cas.TarifaSaqueParceladoTecBan__c = getAbsoluteValue(detalhesEstorno.tarifaSaqueParceladoTecban);
        cas.IOFDiarioSaqueParcelado__c = getAbsoluteValue(detalhesEstorno.iofDiarioSaqueParcelado);
        cas.IOFDiarioSaqueVista__c = getAbsoluteValue(detalhesEstorno.iofDiarioSaqueVista);
        cas.IOFAdicionalSaqueVista__c = getAbsoluteValue(detalhesEstorno.iofAdicionalSaqueVista);
        cas.IOFDiarioPagContasVista__c = getAbsoluteValue(detalhesEstorno.iofDiarioPagContasVista);
        cas.IOFAdicionalPagContasVista__c = getAbsoluteValue(detalhesEstorno.iofAdicionalPagContasVistas);
        cas.JurosOpPagamentoContas__c = getAbsoluteValue(detalhesEstorno.jurosOpPagContas);
    }

    private static List<Database.SaveResult> criarLancamentosContestados(Case cas, List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> faturasSelecionadas){
        List<LancamentoContestado__c> lancamentoList = new List<LancamentoContestado__c>();

        for(BCSF_CLS_CalloutFaturasTO.DetalhesFatura fatura : faturasSelecionadas){
            lancamentoList.add(new LancamentoContestado__c(
                Caso__c = cas.Id,
                ContaFinanceira__c = cas.ContaFinanceira__c,
                NumeroCartao__c = fatura.numeroCartao,
                NumeroConta__c = fatura.numeroConta,
                IdTransacao__c = fatura.idTransacao,
                DataTransacao__c = Date.valueOf(fatura.dataTransacao),
                DataProcessamento__c = Date.valueOf(fatura.dataProcessamento),
                TipoLancamento__c = fatura.tipoLancamento,
                Descricao__c = fatura.descricao,
                ReasonCode__c = fatura.reasonCode,
                Valor__c = getAbsoluteValue(fatura.valor),
                Moeda__c = fatura.moeda,
                DataVencimentoFatura__c = Date.valueOf(fatura.dataVencimentoFatura),
                ChaveParticaoTransacao__c = fatura.chaveParticaoTransacao
            ));
        }

        return Database.Insert(lancamentoList);
    }

    public static Boolean verificaAlcada(String areaPrincipal){
        List<AlcadasEncargosTarifasAnuidade__mdt> listAlcada = AlcadasEncargosTarifasAnuidadeDAO.getAlcadaByAreaPrincipal(areaPrincipal);
        if (listAlcada.size() > 0) {
            return true;
        }
        return false;
    }
    
    public class BaseException extends Exception {}
}