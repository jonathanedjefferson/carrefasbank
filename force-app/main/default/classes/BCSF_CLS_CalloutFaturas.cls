public class BCSF_CLS_CalloutFaturas {
    @AuraEnabled
    public static String buscarFaturaAberta(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){        
        try {
            CarrefourAPICallout__mdt mdt;
            if(Test.isRunningTest()){
                mdt = (CarrefourAPICallout__mdt)Json.deserialize('{"Method__c": "POST","Endpoint__c": "123","Path__c" : "123","Body__c": "123"}', CarrefourAPICallout__mdt.class);
            } else {
                mdt = getAPIMDT('ObterFaturaAberta');
            }
            
            mdt.Path__c = mdt.Path__c.replace('{0}', numeroConta);
            mdt.Body__c = mdt.Body__c.replace('+cpfCliente+', cpfCliente).replace('+unidadeNegocio+', unidadeNegocio);

            List<ObterTokenAcessoAPI.Input> listInputToken = new List<ObterTokenAcessoAPI.Input>();
            ObterTokenAcessoAPI.Input inputToken = new ObterTokenAcessoAPI.Input();
            inputToken.canal = canal;
            listInputToken.add(inputToken);

            //PEGANDO METADADO CUSTOM organizationType
            organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');


            HttpRequest req = new HttpRequest();
            if(!Test.isRunningTest()){
                req.setHeader('Authorization', 'Bearer ' + ObterTokenAcessoAPI.getAccessToken(listInputToken).get(0).AccessToken);
            }
            req.setMethod(mdt.Method__c);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-uat',UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : '');
            req.setEndpoint(mdt.Endpoint__c + mdt.Path__c);
            req.setBody(mdt.Body__c);
            
            Http http = new Http();
            HTTPResponse response = http.send(req);
            String body = response.getBody();
            
            // REGISTRANDO LOG DE INTEGRAÇÃO
            LogIntegracaoBO.InsertLog(
                mdt.DeveloperName, 
                mdt.Endpoint__c + mdt.Path__c, 
                mdt.Method__c, 
                mdt.Body__c, 
                cpfCliente, 
                String.valueOf(response.getStatusCode()), 
                response.getBody(),
                unidadeNegocio,
                canal.capitalize()
            );    
            return response.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String buscarFaturaFechada(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){
        String mock = '{"faturasFechadas":[{"valorFatura":{"valor":-1665.46,"moeda":"R$"},"dataVencimento":"2025-04-08T00:00:00","dataFechamento":"2025-03-26T00:00:00","pagamentoMinimo":{"valor":-909.16,"moeda":"R$"}},{"valorFatura":{"valor":-2104.39,"moeda":"R$"},"dataVencimento":"2025-03-08T00:00:00","dataFechamento":"2025-02-23T00:00:00","pagamentoMinimo":{"valor":-569.05,"moeda":"R$"}}]}';
        Date dtFimDate = System.Date.today();
        Date dtInicioDate = dtFimDate.addMonths(-12);
        
        String dtInicio = String.valueOf(dtInicioDate);
        String dtFim = String.valueOf(System.Date.today());
        
        try {
            CarrefourAPICallout__mdt mdt;
            if(Test.isRunningTest()){
                mdt = (CarrefourAPICallout__mdt)Json.deserialize('{"Method__c": "POST","Endpoint__c": "123","Path__c" : "123","Body__c": "+cpfCliente+ +unidadeNegocio+"}', CarrefourAPICallout__mdt.class);
            } else {
                mdt = getAPIMDT('ObterFaturasFechadas');
            }
            
            mdt.Path__c = mdt.Path__c.replace('{0}', numeroConta);

            List<ObterTokenAcessoAPI.Input> listInputToken = new List<ObterTokenAcessoAPI.Input>();
            ObterTokenAcessoAPI.Input inputToken = new ObterTokenAcessoAPI.Input();
            inputToken.canal = canal;
            listInputToken.add(inputToken);
            
            //PEGANDO METADADO CUSTOM organizationType
            organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');

            HttpRequest req = new HttpRequest();
            if(!Test.isRunningTest()){
                req.setHeader('Authorization', 'Bearer ' + ObterTokenAcessoAPI.getAccessToken(listInputToken).get(0).AccessToken);
            }
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-uat',UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : '');

            req.setBody(mdt.Body__c.replace('+cpfCliente+', cpfCliente).replace('+unidadeNegocio+', unidadeNegocio));
            req.setEndpoint(mdt.Endpoint__c + mdt.Path__c + '?mesInicio=' + dtInicio + '&mesTermino='+ dtFim);
            req.setMethod(mdt.Method__c);
            
            Http http = new Http();
            HTTPResponse response = http.send(req);
            
            // REGISTRANDO LOG DE INTEGRAÇÃO
            LogIntegracaoBO.InsertLog(
                mdt.DeveloperName, 
                mdt.Endpoint__c + mdt.Path__c, 
                mdt.Method__c, 
                mdt.Body__c, 
                cpfCliente, 
                String.valueOf(response.getStatusCode()), 
                response.getBody(),
                unidadeNegocio,
                canal.capitalize()
            );  
            
            return response.getBody();
            //return mock;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DetalhesFatura> buscarDetalhesFatura(String numeroConta, String dataVencimento, String cpfCliente, String unidadeNegocio, String canal){
        String mock = '{ "faturaDetalhada": { "tipoFatura": "Aberta", "valorFatura": { "valor": 0, "moeda": "String" }, "dataVencimento": "2022-05-23T18:03:12.980Z", "totalDescontos": { "valor": 0, "moeda": "String" }, "totalDescontosUltimoAno": {"valor": 0, "moeda": "String" }, "pagamentoMinimo": { "valor": 0, "moeda": "String" }, "pagamentoEfetuado": { "valor": 0, "moeda": "String" }, "linhaDigitavel": "String", "codigoBarras": "String", "lancamentos": [{ "numeroCartao": "String", "idTransacao": "String", "chaveParticaoTransacao": "String", "dataTransacao": "2025-04-08", "dataProcessamento": "String", "tipoLancamento": "Compra", "descricao": "String", "reasonCode": "String", "valor": { "valor": 0, "moeda": "String" }, "idCategoria": "Supermercado", "nomeCategoria": "String", "identificadorOnUs": "OffUs", "quantidadeParcelas": 0, "numeroParcela": 0, "detalhesLancamentoParcela": { "quantidadeParcelas": 0, "numeroParcelaTransacao": 0,"parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0}, "idTransacaoVinculada": "String", "descontos": [ { "nomeProduto": "String", "quantidadeProdutos": 0, "valorTotalDesconto": { "valor": 0, "moeda": "String" } } ], "modoTransacao": "String", "codigoAutorizacao": "String", "numeroConta": "String", "dataVencimentoFatura": "2022-05-23T18:03:12.980Z", "modoTransacaoNumerico": "String" } ] }}';
        
        dataVencimento = dataVencimento.replace('/', '-');
        
        try {
            CarrefourAPICallout__mdt mdt;
            if(Test.isRunningTest()){
                mdt = (CarrefourAPICallout__mdt)Json.deserialize('{"Method__c": "POST","Endpoint__c": "123","Path__c" : "123","Body__c": "123"}', CarrefourAPICallout__mdt.class);
            } else {
                mdt = getAPIMDT('ObterDetalhesFaturas');
            }
            
            mdt.Path__c = mdt.Path__c.replace('{0}', numeroConta).replace('{1}', dataVencimento);
            
            List<ObterTokenAcessoAPI.Input> listInputToken = new List<ObterTokenAcessoAPI.Input>();
            ObterTokenAcessoAPI.Input inputToken = new ObterTokenAcessoAPI.Input();
            inputToken.canal = canal;
            listInputToken.add(inputToken);

            //PEGANDO METADADO CUSTOM organizationType
            organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');

            Http h = new Http();
            HttpRequest req = new HttpRequest();
            if(!Test.isRunningTest()){
                req.setHeader('Authorization', 'Bearer ' + ObterTokenAcessoAPI.getAccessToken(listInputToken).get(0).AccessToken);
            }
            req.setEndpoint(mdt.Endpoint__c + mdt.Path__c);
            req.setMethod(mdt.Method__c);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-uat',UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : '');
            req.setBody(mdt.Body__c.replace('+cpfCliente+', cpfCliente).replace('+unidadeNegocio+', unidadeNegocio));
            HttpResponse resp = h.send(req);
            
            List<DetalhesFatura> detalhesLst = new List<DetalhesFatura>();
            if(resp.getStatusCode() == 200) {
                
                BCSF_DetalhesFaturaService response = new BCSF_DetalhesFaturaService();
                if (Test.isRunningTest()) {
                   response = BCSF_DetalhesFaturaService.parse(mock);
                }  else {
                   response = BCSF_DetalhesFaturaService.parse(resp.getBody());
                }

                for(BCSF_DetalhesFaturaService.Lancamentos lancamentos :response.faturaDetalhada.lancamentos) {
                    DetalhesFatura detalhes = new DetalhesFatura();
                    detalhes.numeroCartao = lancamentos.numeroCartao;
                    detalhes.dataTransacao = lancamentos.dataTransacao;
                    detalhes.descricao = lancamentos.descricao;
                    detalhes.descricaoGrupo = lancamentos.descricaoGrupo;
                    detalhes.valor = lancamentos.valor.valor;
                    detalhes.faturaIndisponivel = false;
                    detalhes.reasonCode = lancamentos.reasonCode;
                    detalhes.idTransacao = lancamentos.idTransacao;
                    detalhes.dataProcessamento = lancamentos.dataProcessamento;
                    detalhes.tipoLancamento = lancamentos.tipoLancamento;
                    detalhes.moeda = lancamentos.valor.moeda;
                    detalhes.numeroConta = lancamentos.numeroConta;
                    detalhes.chaveParticaoTransacao = lancamentos.chaveParticaoTransacao;
                    detalhes.dataVencimentoFatura = lancamentos.dataVencimentoFatura;
                    detalhes.reasonCode = lancamentos.reasonCode;    
                    
                    detalhes.pagamentoEfetuado = response.faturaDetalhada.pagamentoEfetuado;

                    detalhesLst.add(detalhes);
                }
                if(resp.getStatusCode() == 404) {
                    DetalhesFatura detalhes = new DetalhesFatura();
                    detalhes.faturaIndisponivel = true;
                    
                    detalhesLst.add(detalhes);
                }
            }

            // REGISTRANDO LOG DE INTEGRAÇÃO
            LogIntegracaoBO.InsertLog(
                mdt.DeveloperName, 
                mdt.Endpoint__c + mdt.Path__c, 
                mdt.Method__c, 
                mdt.Body__c, 
                cpfCliente, 
                String.valueOf(resp.getStatusCode()), 
                resp.getBody(),
                unidadeNegocio,
                canal.capitalize()
            );   
            
            return detalhesLst;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static CarrefourAPICallout__mdt getAPIMDT(String developerName) {
        CarrefourAPICallout__mdt[] retMDT = [SELECT id, MasterLabel, DeveloperName, Body__c, Endpoint__c, Path__c,  Method__c from CarrefourAPICallout__mdt where DeveloperName =: developerName];
        if (retMDT.size() > 0) {
            return retMDT[0];
        } else {
            return null;
        }
    }

    public class DetalhesFatura {
        @AuraEnabled public String numeroCartao;
        @AuraEnabled public String dataTransacao;
        @AuraEnabled public String descricao;
        @AuraEnabled public String descricaoGrupo;
        @AuraEnabled public Decimal valor;
        @AuraEnabled public Boolean faturaIndisponivel;
        @AuraEnabled public String reasonCode;
        @AuraEnabled public String idTransacao;
        @AuraEnabled public String dataProcessamento;
        @AuraEnabled public String tipoLancamento;
        @AuraEnabled public String moeda;
        @AuraEnabled public String numeroConta;
        @AuraEnabled public String chaveParticaoTransacao;
        @AuraEnabled public String dataVencimentoFatura;
        @AuraEnabled public BCSF_DetalhesFaturaService.ValorFatura pagamentoEfetuado;
    }

    public class DetalhesEstorno {
        @AuraEnabled public String casoId;
        @AuraEnabled public String descricao;
        @AuraEnabled public String origin;
        @AuraEnabled public String canal;
        @AuraEnabled public Date dataRegulatoria;
        @AuraEnabled public String accountid;
        @AuraEnabled public String unidadeNegocio;
        @AuraEnabled public String contafinanceiraid;
        @AuraEnabled public Decimal encargosRotativos;
        @AuraEnabled public Decimal encargosAtraso;
        @AuraEnabled public Decimal tarifaAvaliacao;
        @AuraEnabled public Decimal tarifaAnuidade;
        @AuraEnabled public Decimal encargosPagamento;
        @AuraEnabled public Decimal encargosSaqueVisa;
        @AuraEnabled public Decimal encargosSaqueMaster;
        @AuraEnabled public Decimal tarifaRetirada;
        @AuraEnabled public Decimal tarifaTelesaqueVista;
        @AuraEnabled public Decimal tarifaSaqueVistaMastercard; 
        @AuraEnabled public Decimal tarifaSaqueVistaInternacionalMaster;
        @AuraEnabled public Decimal tarifaSaqueVistaVisa;
        @AuraEnabled public Decimal tarifaSaqueVistaInternacionalVisa;
        @AuraEnabled public Decimal tarifaSaqueVistaTecban;
        @AuraEnabled public Decimal tarifaSaqueParceladoTecban;
        @AuraEnabled public Decimal iofDiarioSaqueParcelado;
        @AuraEnabled public Decimal iofDiarioSaqueVista;
        @AuraEnabled public Decimal iofAdicionalSaqueVista;
        @AuraEnabled public Decimal iofDiarioPagContasVista;
        @AuraEnabled public Decimal iofAdicionalPagContasVistas;
        @AuraEnabled public Decimal jurosOpPagContas;
        @AuraEnabled public Decimal total;
    }
    
//--------------------botao estornar
    @AuraEnabled
    public static Case criaOuVinculaCaso(String detalhesEstornoJson, String faturasSelecionadasJson){
        
        Case cas;
        DetalhesEstorno detalhesEstorno = (DetalhesEstorno) System.JSON.deserialize(detalhesEstornoJson, DetalhesEstorno.class);
        List<DetalhesFatura> faturasSelecionadas = (List<DetalhesFatura>) System.JSON.deserialize(faturasSelecionadasJson, List<DetalhesFatura>.class);

        Database.SaveResult sr;

        if(detalhesEstorno.casoId == null){
            cas = new Case();
            initCase(detalhesEstorno, cas);
            cas.ContaFinanceira__c = detalhesEstorno.contafinanceiraid;
            cas.AccountId = detalhesEstorno.accountid;
            cas.Status = 'New';
                
            sr = Database.insert(cas);

        } else{
            List<Case> caseList = [SELECT Id, CaseNumber, ContaFinanceira__c FROM Case WHERE Id =: detalhesEstorno.casoId];
            
            if(caseList.isEmpty()) throw new AuraHandledException('Não foi possível concluir o vínculo. O caso escolhido não foi encontrado na base.');
            cas = caseList[0];
            initCase(detalhesEstorno, cas);

            sr = Database.update(cas);
        }

        if(!sr.isSuccess())
            throw new AuraHandledException('Não foi possível concluir o processo. Motivo: ' + sr.getErrors()[0].getMessage());
        
        List<Database.SaveResult> srLancamentos = criarLancamentosContestados(cas, faturasSelecionadas);
        
        if(!srLancamentos.isEmpty() && !srLancamentos[0].isSuccess()) 
            throw new AuraHandledException('Não foi possível concluir o processo. Motivo: ' + srLancamentos[0].getErrors()[0].getMessage());

        List<Case> caso = [SELECT Id, CaseNumber FROM Case WHERE Id =: cas.Id];
        
        return caso[0];
    }

    private static Decimal getAbsoluteValue(Decimal value){
        return value == null ? 0 : math.abs(value);
    }

    private static void initCase(DetalhesEstorno detalhesEstorno, Case cas){
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

    private static List<Database.SaveResult> criarLancamentosContestados(Case cas, List<DetalhesFatura> faturasSelecionadas){
        List<LancamentoContestado__c> lancamentoList = new List<LancamentoContestado__c>();

        for(DetalhesFatura fatura : faturasSelecionadas){
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



    @AuraEnabled
    public static Boolean verificaAlcada(String areaPrincipal){
        List<AlcadasEncargosTarifasAnuidade__mdt> listAlcada = [SELECT Id FROM AlcadasEncargosTarifasAnuidade__mdt WHERE AreaPrincipal__c = :areaPrincipal];
        if (listAlcada.size() > 0) {
            return true;
        }
        return false;
    }

//-----------------------------
    
    public class BaseException extends Exception {}

}