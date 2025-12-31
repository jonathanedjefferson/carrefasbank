import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { EnclosingTabId, getTabInfo, openSubtab, focusTab } from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import calloutFaturaAberta from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.buscarFaturaAberta';
import calloutFaturaFechada from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.buscarFaturaFechada';
import getInfoDivida from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.consultarSituacaoAcordo';
import getExtratoCompacto from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.getExtratoCompacto';
import criaOuVinculaCaso from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.criaOuVinculaCaso';
import verificaAlcada from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.verificaAlcada';
import getCodeBarras from '@salesforce/apex/MelhorDiaCompraCockpitController.getDataULtimaFatura';


import NOME_CLIENTE from '@salesforce/schema/ContaFinanceira__c.NomeCliente__r.Name';
import NUMERO_CONTA from '@salesforce/schema/ContaFinanceira__c.NumeroConta__c';
import CPF_CLIENTE from '@salesforce/schema/ContaFinanceira__c.NomeCliente__r.CPF__c';
import UNIDADE_NEGOCIO from '@salesforce/schema/ContaFinanceira__c.UnidadeNegocio__c';
import ACCOUNTID from '@salesforce/schema/ContaFinanceira__c.NomeCliente__c';
import CaseNumber from '@salesforce/schema/Case.CaseNumber';
import StayInTouchSignature from '@salesforce/schema/User.StayInTouchSignature';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import MANAGER_ID from '@salesforce/schema/User.ManagerId';
import getAllButtonsFatura from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.getAllButtonsFatura';

const columns = [
    {
        label: 'Data da transação', fieldName: 'dataTransacaoFormatada', type: "text", hideDefaultActions: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }, cellAttributes: { alignment: 'center' },
    },
    { label: 'Número do cartão', fieldName: 'numeroCartao', type: 'text', cellAttributes: { alignment: 'center' }, hideDefaultActions: true },
    { label: 'Descrição', fieldName: 'descricao', type: 'text', wrapText: true, cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Valor', fieldName: 'valor', type: 'currency', cellAttributes: { alignment: 'center' }, hideDefaultActions: true }
];

const columns2 = [
    { label: 'Account Name', fieldName: 'accountName', cellAttributes: { alignment: 'center' }, hideDefaultActions: true }
];

export default class Bcsf_cmp_faturasV2 extends  NavigationMixin(LightningElement) {

    constructor() {
        super();
        this.template.addEventListener('updateResumo', this.handleUpdateEvent.bind(this));
    }
    cmpFalecimento = true;
    closeModalComponent = true;
    columns = columns;
    columns2 = columns2;
    section = [];

    @api recordId;

    @track faturaAberta;
    @track faturasFechadas;

    @track fatFechadasArr = [];

    @track faturasSelecionadas = [];

    @track faturaAbertaTable;

    @track nomeTitular;
    @track numeroConta;
    @track cpfCliente;
    @track moeda;
    @track unidadeNegocio;
    @track accountid;
    @track description;
    @track casoCriado;
    @track origin;
    @track canal;
    @track dataRegulatoria;

    @track loaded = false;
    @track setSelectedRows = [];
    @track showEstornoModal = false;
    @track showNovoCaso = false;

    @track isLigadoButtonContestacao = false;
    @track isLigadoButtonAntecipacao = false;

    @track bloq_limparTudo = true;
    @track bloq_estornar = true;

    @track UserId = USER_ID;
    @track ManagerId;
    @track AreaPrincipal;
    @track codigoBarras = '--';
    @track modalSegundaVia = false;
    @track modalBoletoAvulso = false;
    @track modalSaldoVencido = false;

    //Limites
    @track ultimaAlteracaoLimite = '-';
    @track limiteTotalCartao = '-';
    @track limiteTotalCompras = '-';
    @track limiteAutorizadoEmergencial = '-';
    @track limiteTotalSaque = '-';
    @track limiteDisponívelSaque = '-';
    @track debitoTotal = '-';
    @track debitoPendente = '-';
    @track formaPagamento = '-';
    @track dataEnquadramento = '-';
    @track saldoRemanescente = '-';
    @track saldoVencidoAtualizado = '-';
    @track dataUltimoPagamento = '-';
    @track dataReimpressaoFatura = '-';
    @track saldoEncargosAtraso = '-';
    @track saldoMulta = '-';
    @track saldoMora = '-';
    @track showBtnResumoSaldoVencido;
    @track showDataReeimpressaoFatura;
    @track showUltimaAlteracaoLimite;

    get cliente_infos() {
        return {
            numeroConta: this.numeroConta,
            cpfCliente: this.cpfCliente,
            unidadeNegocio: this.unidadeNegocio,
        }
    }

    @wire(EnclosingTabId) tabId;

    @wire(getRecord, { recordId: '$recordId', fields: [NOME_CLIENTE, NUMERO_CONTA, CPF_CLIENTE, UNIDADE_NEGOCIO, ACCOUNTID] })
    contaFinanceiraWired({ error, data }) {
        if (data) {

            this.nomeTitular = getFieldValue(data, NOME_CLIENTE);
            this.numeroConta = getFieldValue(data, NUMERO_CONTA);
            this.cpfCliente = getFieldValue(data, CPF_CLIENTE);
            this.accountid = getFieldValue(data, ACCOUNTID);
            this.unidadeNegocio = data.fields.UnidadeNegocio__c.value;
            this.faturaAbertaTable = true;
            this.loaded = true;
            this.getLogo(this.unidadeNegocio);
            this.GetExtratoCompacto()
            this.GetInfoDivida();
            this.GetCodeBarras();
            this.fetchFaturaAberta();
            this.fetchFaturasFechadas();
            this.getAllButtonsFatura();
        } else if (error) {
            console.log('Error: ' + error);
        }
    };

    @wire(getRecord, { recordId: USER_ID, fields: [MANAGER_ID, AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.AreaPrincipal = data.fields.AreaPrincipal__c.value;
            this.ManagerId = data.fields.ManagerId.value;
        } else if (error) {
            this.error = error;
        }
    }


    fetchFaturaAberta() {
        calloutFaturaAberta({ 
            numeroConta: this.numeroConta, 
            cpfCliente: this.cpfCliente, 
            unidadeNegocio: this.unidadeNegocio,
            canal: 'cockpit' 
        }).then(result => {
            if (result) {
                let info_faturaAberta = JSON.parse(result);

                info_faturaAberta.valorFatura = {
                    moeda: info_faturaAberta.valorParcial.moeda,      
                    valor: info_faturaAberta.valorParcial.valor
                }

                this.moeda = info_faturaAberta.limiteTotal.moeda;
                info_faturaAberta.dataVencimentoOriginal = info_faturaAberta.dataVencimento;
                info_faturaAberta.dataVencimento = Intl.DateTimeFormat('pt-BR').format(new Date(info_faturaAberta.dataVencimento));
                info_faturaAberta.limiteDisponivel.valor = Intl.NumberFormat('pt-BR').format(new Number(info_faturaAberta.limiteDisponivel.valor));
                info_faturaAberta.limiteTotal.valor = Intl.NumberFormat('pt-BR').format(new Number(info_faturaAberta.limiteTotal.valor));
                info_faturaAberta.valorFatura.original = info_faturaAberta.valorParcial.valor;
                info_faturaAberta.valorFatura.valor = Intl.NumberFormat('pt-BR').format(new Number(this.inverteValor(info_faturaAberta.valorParcial.valor)));
                
                this.faturaAberta = {
                    dados: info_faturaAberta,
                }
                
                this.faturaAbertaTable = true;
            } else {
                throw new Error('Serviço indisponível. Por favor, tente novamente.');
            };
        })
        .catch(error =>{
            this.showErrorToast('Erro ao exibir faturas', error.message);
        })
    }


    fetchFaturasFechadas() {
        calloutFaturaFechada({
            numeroConta: this.numeroConta, 
            cpfCliente: this.cpfCliente, 
            unidadeNegocio: this.unidadeNegocio,
            canal: 'cockpit'
        })
        .then(result => {
            if (result) {
                this.fatFechadasArr = [];
                this.loaded = true;
                this.faturasFechadas = JSON.parse(result);

                this.faturasFechadas.forEach(fat => {
                    if (!fat.dataVencimento) return;

                    let dtVencimento = new Date(fat.dataVencimento);
                    let month = dtVencimento.toLocaleString('pt-BR', { month: 'short' });
                    let mesAno = fat.dataVencimento;

                    fat.valorFatura.original = fat.valorFatura.valor;
                    fat.valorFatura.valor = Intl.NumberFormat('pt-BR').format(new Number(fat.valorFatura.valor));

                    fat.mesAno = mesAno;
                    fat.dataVencimentoOriginal = fat.dataVencimento;
                    fat.dataVencimento = Intl.DateTimeFormat('pt-BR').format(new Date(fat.dataVencimento));

                    fat.pagamentoMinimo.valor = Intl.NumberFormat('pt-BR').format(new Number(fat.pagamentoMinimo.valor));

                    fat.mesRef = month + '/' + new Intl.DateTimeFormat('pt', { year: 'numeric' }).format(dtVencimento);
                    fat.creditos = fat.creditos;

                    let config_Tabela = {
                        botao_limpar_bloq: true,
                        idx: fat.dataVencimento,
                        dados: fat,
                        linhas_selecionadas: [],
                        setSelectedRows: []
                    };

                    this.fatFechadasArr.push(config_Tabela);
                });
            }
        })
        .catch(error => {
            this.loaded = true;
            this.showErrorToast('Erro ao exibir faturas', error.message);
        });
    }

    showErrorToast(title, message) {
        console.error(`${title}: ${message}`);
    }
    async GetCodeBarras() {
        await getCodeBarras({
            numeroConta: this.numeroConta,
            cpf: this.cpfCliente,
            unidade: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result != null) {
                this.codigoBarras = result.codigoBarras;
            } else {
                this.codigoBarras = '--';
                throw new Error('Erro de Serviço');
            };
        })
            .catch(error => {
                this.showErrorToast('Erro ao buscar código de barras', error.message);
                console.error('Erro ao buscar código de barras', error.message);
            })
    }

    GetExtratoCompacto() {
        getExtratoCompacto({
            numeroConta: this.numeroConta,
            cpf: this.cpfCliente,
            unidadeNegocio: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result.statusResponse == 'OK') {
                const valores = result.valoresLimites;

                this.ultimaAlteracaoLimite = this.validarValoresLimites(valores.dataAlteracaoLimite, 'data');
                this.limiteTotalCartao = this.validarValoresLimites(result.limiteComprasCarrefour, 'valor');
                this.limiteTotalCompras = this.validarValoresLimites(result.saldoDisponivelCompras, 'valor');
                this.limiteAutorizadoEmergencial = this.validarValoresLimites(valores.limiteAutorizacao, 'porcentagem');
                this.limiteTotalSaque = this.validarValoresLimites(valores.limiteSaque, 'valor');
                this.limiteDisponívelSaque = this.validarValoresLimites(valores.limiteDisponivelSaque, 'valor');
                this.debitoTotal = this.validarValoresLimites(result.saldoDevedorNestaData, 'valor');
                this.formaPagamento = this.validarValoresLimites(valores.formaDePagamento, 'texto');
                this.saldoRemanescente = this.validarValoresLimites(valores.saldoRemanescente, 'valor');
                this.dataUltimoPagamento = this.validarValoresLimites(result.dataUltimoPagamento, 'data');
                this.dataReimpressaoFatura = this.validarValoresLimites(valores.dataReeimpressaoFatura, 'data');
                this.showDataReeimpressaoFatura = valores.dataReeimpressaoFatura ? true : false;
                this.showUltimaAlteracaoLimite = valores.dataAlteracaoLimite ? true : false;
                this.showBtnResumoSaldoVencido = valores.saldoVencidoAtualizado ? true : false;
                if(this.showBtnResumoSaldoVencido){
                    this.saldoVencidoAtualizado = this.validarValoresLimites(valores.saldoVencidoAtualizado.saldoAtual, 'valor');
                    this.saldoEncargosAtraso = this.validarValoresLimites(valores.saldoVencidoAtualizado.encargoDeAtraso, 'valor');
                    this.saldoMulta = this.validarValoresLimites(valores.saldoVencidoAtualizado.multa, 'valor');
                    this.saldoMora = this.validarValoresLimites(valores.saldoVencidoAtualizado.mora, 'valor');
                }
            } else {
                throw new Error('Erro de Serviço');
            }
        }).catch(error => {
            this.showErrorToast('Erro', 'Erro ao buscar Limites');
            console.error('Erro ao buscar Limites', error.message);
        })
    }

    GetInfoDivida(){
        getInfoDivida({
            cpf: this.cpfCliente,
            unidadeNegocio: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if(result.situacao){
                this.debitoPendente = result.situacao.codigo == '2' ? this.formatValor(result.divida.valor) : 'Não';
                this.dataEnquadramento = result.situacao.codigo == '2' ? this.formatDate(result.divida.dataEnquadramento) : '-';
            }
        }).catch(error => {
            this.showErrorToast('Erro', 'Erro ao buscar Limites');
            console.error('Erro GetInfoDivida: ', error.message);
        })
    }

    inverteValor(valor) {
        return valor == 0 ? 0 : valor * (-1);
    }

    showDetalhesFatFechada(event) {
        this.showDetalhesFatura(event, false);
    }

    handleSectionToggle(event) {
        this.section = event.detail.openSections;
    }

    onSelectFaturaResumo(event) {
        const linhasSelecionadas = event.detail.selectedRows;

        this.bloq_estornar = linhasSelecionadas.length < 1;

    }

    handleUpdateEvent(event) {
        this.attLinhasResumo(event.detail.linhasSelecionadas, event.detail.linhasRemovidas);
    }

    attLinhasResumo(linhasSelecionadas, linhasRemovidas) {
        this.removeLinhasNoResumo(linhasRemovidas);
        this.adicionaLinhasNoResumo(linhasSelecionadas);

        this.bloq_limparTudo = this.faturasSelecionadas.length < 1;
    }

    removeLinhasNoResumo(linhasRemovidas) {
        if (linhasRemovidas.length < 1) return;

        let temp = [...this.faturasSelecionadas];

        linhasRemovidas.forEach(linha => {
            const remove = this.faturasSelecionadas.find(fatura => fatura.reasonCode === linha.reasonCode && fatura.idTransacao === linha.idTransacao);

            if (remove) {
                const lineIndex = temp.indexOf(remove);
                temp.splice(lineIndex, 1);
            }
        });

        this.faturasSelecionadas = [...temp];
    }

    adicionaLinhasNoResumo(linhasSelecionadas) {
        if (linhasSelecionadas.length < 1) return;

        let novasLinhas = [];

        linhasSelecionadas.forEach(linha => {
            const faturaJaAdicionada = this.faturasSelecionadas.find(fatura => fatura.reasonCode === linha.reasonCode && fatura.idTransacao === linha.idTransacao);

            if (!faturaJaAdicionada) novasLinhas.push(linha);
        });

        novasLinhas.forEach(linha => {
            this.faturasSelecionadas = [...this.faturasSelecionadas, linha];
        });

    }

    limparTodasAsFaturas() {
        this.faturasSelecionadas = [];
        this.bloq_limparTudo = true;

        //Fechadas
        this.template.querySelectorAll('c-bcsf_cmp_detalhes_fatura-v-2').forEach(child => child.limparSelecao());
    }

    //---------------Botão Estornar
    showDecision(event) {
        if (this.AreaPrincipal == null || this.ManagerId == null) {
            this.showErrorToast('Erro', 'Usuário não possui Área Principal ou Gerente');
        } else {
            verificaAlcada({
                areaPrincipal: this.AreaPrincipal
            }).then(result => {
                if (result) {
                    this.showEstornoModal = true;
                } else {
                    this.showErrorToast('Erro', 'Não existe parametros de Alçada de Encargos, Tarifas e Anuidade');
                }
            }).catch(error => {
                this.showErrorToast('Erro', error.body.message);
            });
        }
    }

    handleCloseEstornoModal() {
        this.showEstornoModal = false;
    }

    handleCriarNovo(event) {
        const detalhesEstorno = this.criarDetalhesEstorno(event);
        criaOuVinculaCaso({
            detalhesEstornoJson: JSON.stringify(detalhesEstorno),
            faturasSelecionadasJson: JSON.stringify(this.faturasSelecionadas),
        }).then(caso => {
            this.showSuccessToast(caso.CaseNumber);
            setTimeout(() => {
                window.location.href = `/lightning/r/Case/${caso.Id}/view`;
            }, 3000)
        }).catch(error => {
            console.log('erro ' + error.body.message);
            this.showErrorToast('Erro ao criar novo caso.', error.body.message);
        })
    }

    handleVincular(event) {
        const detalhesEstorno = this.criarDetalhesEstorno(event);

        criaOuVinculaCaso({
            detalhesEstornoJson: JSON.stringify(detalhesEstorno),
            faturasSelecionadasJson: JSON.stringify(this.faturasSelecionadas),
        })
            .then(caso => {
                this.showSuccessToast(caso.CaseNumber);
                setTimeout(() => {
                    window.location.href = `/lightning/r/Case/${caso.Id}/view`;
                }, 3000)
            })
            .catch(error => {
                this.showErrorToast('Erro ao vincular caso.', error.body.message);
            })
    }

    criarDetalhesEstorno(event) {
        return {
            casoId: event.detail.casoId ? event.detail.casoId : null,
            descricao: event.detail.descricao,
            origin: event.detail.origin,
            canal: event.detail.canal,
            dataRegulatoria: event.detail.dataRegulatoria,
            accountid: this.accountid,
            contafinanceiraid: this.recordId,
            unidadeNegocio: this.unidadeNegocio,
            ...this.aggregateFaturasSelecionadas
        };
    }

    showErrorToast(titulo, mensagem) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(caseNumber) {
        const evt = new ShowToastEvent({
            title: 'Caso criado ou vinculado com sucesso',
            message: `Você será direcionado para a página do caso ${caseNumber}`,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    get aggregateFaturasSelecionadas() {
        let encargosRotativos = 0;
        let encargosAtraso = 0;
        let tarifaAvaliacao = 0;
        let tarifaAnuidade = 0;
        let encargosPagamento = 0;
        let encargosSaqueVisa = 0;
        let encargosSaqueMaster = 0;
        let tarifaRetirada = 0;
        let tarifaTelesaqueVista = 0;
        let tarifaSaqueVistaMastercard = 0;
        let tarifaSaqueVistaInternacionalMaster = 0;
        let tarifaSaqueVistaVisa = 0;
        let tarifaSaqueVistaInternacionalVisa = 0;
        let tarifaSaqueVistaTecban = 0;
        let tarifaSaqueParceladoTecban = 0;
        let iofDiarioSaqueParcelado = 0;
        let iofDiarioSaqueVista = 0;
        let iofAdicionalSaqueVista = 0;
        let iofDiarioPagContasVista = 0;
        let iofAdicionalPagContasVistas = 0;
        let jurosOpPagContas = 0;
        let total = 0;

        for (let fatura of this.faturasSelecionadas) {
            total += fatura.valor;
            if (fatura.reasonCode === "nrev") {
                encargosRotativos += fatura.valor;
            } else if (fatura.reasonCode === "pint") {
                encargosAtraso += fatura.valor;
            } else if (fatura.reasonCode === "olmt") {
                tarifaAvaliacao += fatura.valor;
            } else if (fatura.reasonCode === "mntf") {
                tarifaAnuidade += fatura.valor;
            } else if (fatura.reasonCode === "isop") {
                encargosPagamento += fatura.valor;
            } else if (fatura.reasonCode === "carv") {
                encargosSaqueVisa += fatura.valor;
            } else if (fatura.reasonCode === "care") {
                encargosSaqueMaster += fatura.valor;
            } else if (fatura.reasonCode === "TBD") {
                tarifaRetirada += fatura.valor;
            } else if (fatura.reasonCode === "catl") {
                tarifaTelesaqueVista += fatura.valor;
            } else if (fatura.reasonCode === "care") {
                tarifaSaqueVistaMastercard += fatura.valor;
            } else if (fatura.reasonCode === "camc") {
                tarifaSaqueVistaInternacionalMaster += fatura.valor;
            } else if (fatura.reasonCode === "carv") {
                tarifaSaqueVistaVisa += fatura.valor;
            } else if (fatura.reasonCode === "cavs") {
                tarifaSaqueVistaInternacionalVisa += fatura.valor;
            } else if (fatura.reasonCode === "caon") {
                tarifaSaqueVistaTecban += fatura.valor;
            } else if (fatura.reasonCode === "cinf") {
                tarifaSaqueParceladoTecban += fatura.valor;
            } else if (fatura.reasonCode === "biof") {
                iofDiarioSaqueParcelado += fatura.valor;
            } else if (fatura.reasonCode === "bioc") {
                iofDiarioSaqueVista += fatura.valor;
            } else if (fatura.reasonCode === "aioc") {
                iofAdicionalSaqueVista += fatura.valor;
            } else if (fatura.reasonCode === "biop") {
                iofDiarioPagContasVista += fatura.valor;
            } else if (fatura.reasonCode === "aiop") {
                iofAdicionalPagContasVistas += fatura.valor;
            } else if (fatura.reasonCode === "nubp") {
                jurosOpPagContas += fatura.valor;
            }

        }

        return {
            encargosRotativos,
            encargosAtraso,
            tarifaAvaliacao,
            tarifaAnuidade,
            encargosPagamento,
            encargosSaqueVisa,
            encargosSaqueMaster,
            tarifaRetirada,
            tarifaTelesaqueVista,
            tarifaSaqueVistaMastercard,
            tarifaSaqueVistaInternacionalMaster,
            tarifaSaqueVistaVisa,
            tarifaSaqueVistaInternacionalVisa,
            tarifaSaqueVistaTecban,
            tarifaSaqueParceladoTecban,
            iofDiarioSaqueParcelado,
            iofDiarioSaqueVista,
            iofAdicionalSaqueVista,
            iofDiarioPagContasVista,
            iofAdicionalPagContasVistas,
            jurosOpPagContas,
            total
        }
    }
    copyText(event) {
        const textToCopy = event.target.getAttribute('data-text');
        const dummyInput = document.createElement('input');
        document.body.appendChild(dummyInput);
        dummyInput.value = textToCopy;
        dummyInput.select();
        document.execCommand('copy');
        document.body.removeChild(dummyInput);
    }
    segundaViaFaturaHandler() {
        this.modalSegundaVia = true;
    }

    async AutorizacaoHandler() {
        if (!this.tabId) {
            return;
        }

        const tabInfo = await getTabInfo(this.tabId);
        const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;

        await openSubtab(primaryTabId, {
            // recordId: this.recordId, 
            focus: true, 
            icon: 'utility:cart',
            label: 'Autorização On-Us e Off-Us',
            pageReference: {
                type: 'standard__component',
                attributes: {
                    actionName: 'view',
                    componentName: 'c__bcsf_ListaTransacoesOnUsOffUs',
                },
                state: {
                    c__recordId: this.recordId,
                    c__limiteTotal: this.faturaAberta.dados.limiteTotal.valor,
                    c__limiteDisponivel: this.faturaAberta.dados.limiteDisponivel.valor
                }
            }

        });
    }

    async contestacaoComprasHandler() {
        if (!this.tabId) {
            return;
        }

        let primaryTabId = null;
        let tabInfo = await getTabInfo(this.tabId);

        if(tabInfo.isSubtab) {
            tabInfo = await getTabInfo(tabInfo.parentTabId);
        }
        
        // Aba já está aberta
        if(typeof tabInfo.subtabs !== "undefined" && tabInfo.subtabs.length > 0){
            for(let i = 0; i < tabInfo.subtabs.length; i++){
                if(tabInfo.subtabs[i].customTitle == "Contestação de compras"){
                    primaryTabId = tabInfo.subtabs[i].tabId;
                    break;
                }
            }
        }

        if(primaryTabId == null){
            primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
            await openSubtab(primaryTabId, {
                focus: true, 
                icon: 'utility:cart',
                label: 'Contestação de compras',
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        actionName: 'view',
                        componentName: 'c__bcsf_ContestacaoCompra',
                    },
                    state: {
                        c__recordId: this.recordId,
                        c__limiteTotal: this.faturaAberta.dados.limiteTotal.valor,
                        c__limiteDisponivel: this.faturaAberta.dados.limiteDisponivel.valor
                    }
                }
            });
        } else {
            await focusTab(primaryTabId);
        }
    }

    async antecipacaoParcelasHandler() {
        if (!this.tabId) {
            return;
        }

        let primaryTabId = null;
        let tabInfo = await getTabInfo(this.tabId);

        if(tabInfo.isSubtab) {
            tabInfo = await getTabInfo(tabInfo.parentTabId);
        }
        
        if(typeof tabInfo.subtabs !== "undefined" && tabInfo.subtabs.length > 0){
            for(let i = 0; i < tabInfo.subtabs.length; i++){
                if(tabInfo.subtabs[i].customTitle == "Parcelados"){
                    primaryTabId = tabInfo.subtabs[i].tabId;
                    break;
                }
            }
        }

        if(primaryTabId == null){
            primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
            await openSubtab(primaryTabId, {
                focus: true, 
                icon: 'standard:return_order_line_item',
                label: 'Parcelados',
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        actionName: 'view',
                        componentName: 'c__bcsf_cmp_Parcelamentos',
                    },
                    state: {
                        c__recordId: this.recordId,
                    }
                }
            });
        } else {
            await focusTab(primaryTabId);
        }
    }

    getAllButtonsFatura() {
        this.isLigadoButtonContestacao = false;
        getAllButtonsFatura({
        }).then(result => {
            if (result != null && result.length > 0) {               
                result.forEach(item => {
                    if('buttonFaturas_Contestacao_compras' === item.DeveloperName){
                        this.isLigadoButtonContestacao = item.IsLigado;
                    } else if('buttonFaturas_Antecipacao_Parcelas' === item.DeveloperName){
                        this.isLigadoButtonAntecipacao = item.IsLigado;
                    }
                });
            }
        }).catch(error => {
            console.log('getAllButtonsFatura: ' + error);
        });
    }

    fecharModal() {
        this.modalSegundaVia = false;
    }
    @api closeParentComponent;
    closeQuickAction() {
        this.modalSegundaVia = false;
        this.modalBoletoAvulso = false;
    }

    boletoAvulsoHandler(){
        this.modalBoletoAvulso = true;
    }

    fecharModalBoletoAvulso() {
        this.modalBoletoAvulso = false;
    }

    handleOpenModalSaldoVencido(){
        this.modalSaldoVencido = true;
    }

    handleCloseModalSaldoVencido(){
        this.modalSaldoVencido = false;
    }

    getLogo(unidade){
        if (unidade == "1") {
            this.tipoConta = 'CARREFOUR';
            this.logoTipo = LogoCarrefour;
        } else if (unidade == "2") {
            this.tipoConta = 'ATACADÃO';
            this.logoTipo = LogoAtacadao;
        }else if (unidade == "6"){
            this.tipoConta = "SAM'S CLUB";
            this.logoTipo = LogoSamsClub;
        }
    }

    avaliacaoEmergencialHandler(){
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:'ContaFinanceira__c.AvaliacaoEmergencialCredito'
            },
            state: {
                recordId: this.recordId
            }
        });
    }

    aumentoLimiteHandler(){
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:'ContaFinanceira__c.Aumento_de_limite'
            },
            state: {
                recordId: this.recordId
            }
        });
    }

    reducaoLimiteHandler(){
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:'ContaFinanceira__c.Reducao_de_limite'
            },
            state: {
                recordId: this.recordId
            }
        });
    }

    consultaHistoricoLimiteHandler(){
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:'ContaFinanceira__c.Consultar_historico_limite'
            },
            state: {
                recordId: this.recordId
            }
        });
    }


    formatValor(valor){
        return Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        }).format(valor);
    }

    formatDate(data) {
        if (!data) return '--';
        const [ano, mes, dia] = data.split('T')[0].split('-');
        return `${dia}/${mes}/${ano}`;
    }

    validarValoresLimites(valor, formato){
        if((valor || valor === 0) && formato === 'valor'){
            return this.formatValor(valor);
        }else if((valor || valor === 0) && formato === 'data'){
            return this.formatDate(valor);
        }else if((valor || valor === 0) && formato === 'default'){
            return valor;
        }else if((valor || valor === 0) && formato === 'texto'){
            return valor.charAt(0).toUpperCase() + valor.slice(1).toLowerCase();
        }else if((valor || valor === 0) && formato === 'porcentagem'){
            return new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(valor * 100);
        }
        return '-'
    }
}