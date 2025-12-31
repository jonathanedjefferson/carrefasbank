import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { EnclosingTabId, getTabInfo, openSubtab, focusTab } from 'lightning/platformWorkspaceApi';

import calloutFaturaAberta from '@salesforce/apex/BCSF_CLS_CalloutFaturas.buscarFaturaAberta';
import calloutFaturaFechada from '@salesforce/apex/BCSF_CLS_CalloutFaturas.buscarFaturaFechada';
import criaOuVinculaCaso from '@salesforce/apex/BCSF_CLS_CalloutFaturas.criaOuVinculaCaso';
import verificaAlcada from '@salesforce/apex/BCSF_CLS_CalloutFaturas.verificaAlcada';
import getCodeBarras from '@salesforce/apex/MelhorDiaCompraCockpitController.getDataULtimaFatura';
import { NavigationMixin } from 'lightning/navigation';


import NUMERO_CONTA from '@salesforce/schema/ContaFinanceira__c.NumeroConta__c';
import CPF_CLIENTE from '@salesforce/schema/ContaFinanceira__c.NomeCliente__r.CPF__c';
import UNIDADE_NEGOCIO from '@salesforce/schema/ContaFinanceira__c.UnidadeNegocio__c';
import ACCOUNTID from '@salesforce/schema/ContaFinanceira__c.NomeCliente__c';
import CaseNumber from '@salesforce/schema/Case.CaseNumber';
import StayInTouchSignature from '@salesforce/schema/User.StayInTouchSignature';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import MANAGER_ID from '@salesforce/schema/User.ManagerId';

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
export default class Bcsf_cmp_faturas extends NavigationMixin(LightningElement) {

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

    @track bloq_limparTudo = true;
    @track bloq_estornar = true;

    @track UserId = USER_ID;
    @track ManagerId;
    @track AreaPrincipal;
    @track modalSegundaVia = false;
    @track codigoBarras = '--';
    @track modalBoletoAvulso = false;

    get cliente_infos() {
        return {
            numeroConta: this.numeroConta,
            cpfCliente: this.cpfCliente,
            unidadeNegocio: this.unidadeNegocio,
        }
    }

    @wire(EnclosingTabId) tabId;

    @wire(getRecord, { recordId: '$recordId', fields: [NUMERO_CONTA, CPF_CLIENTE, UNIDADE_NEGOCIO, ACCOUNTID] })
    contaFinanceiraWired({ error, data }) {
        if (data) {

            this.numeroConta = getFieldValue(data, NUMERO_CONTA);
            this.cpfCliente = getFieldValue(data, CPF_CLIENTE);
            this.accountid = getFieldValue(data, ACCOUNTID);
            this.unidadeNegocio = data.fields.UnidadeNegocio__c.value;

            this.GetCodeBarras();
            this.fetchFaturaAberta();
            this.fetchFaturasFechadas();
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
                let info_faturaAberta = JSON.parse(result).faturaAberta;
                this.moeda = info_faturaAberta.limiteTotal.moeda;

                info_faturaAberta.dataVencimento = Intl.DateTimeFormat('pt-BR').format(new Date(info_faturaAberta.dataVencimento));
                info_faturaAberta.limiteDisponivel.valor = Intl.NumberFormat('pt-BR').format(new Number(info_faturaAberta.limiteDisponivel.valor));
                info_faturaAberta.limiteTotal.valor = Intl.NumberFormat('pt-BR').format(new Number(info_faturaAberta.limiteTotal.valor));
                info_faturaAberta.valorFatura.original = info_faturaAberta.valorFatura.valor;
                info_faturaAberta.valorFatura.valor = Intl.NumberFormat('pt-BR').format(new Number(this.inverteValor(info_faturaAberta.valorFatura.valor)));

                this.faturaAberta = {
                    dados: info_faturaAberta,
                }

                this.faturaAbertaTable = true;
            } else {
                throw new Error('Serviço indisponível. Por favor, tente novamente.');
            };
        })
            .catch(error => {
                this.showErrorToast('Erro ao exibir faturas', error.message);
            })
    }

    fetchFaturasFechadas() {
        calloutFaturaFechada({
            numeroConta: this.numeroConta,
            cpfCliente: this.cpfCliente,
            unidadeNegocio: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result) {
                this.loaded = true;
                this.faturasFechadas = JSON.parse(result).faturasFechadas;

                this.faturasFechadas.forEach(fat => {
                    let dtVencimento = new Date(fat.dataVencimento);
                    let month = dtVencimento.toLocaleString('pt-BR', { month: 'short' });
                    fat.valorFatura.original = fat.valorFatura.valor;
                    fat.valorFatura.valor = Intl.NumberFormat('pt-BR').format(new Number(this.inverteValor(fat.valorFatura.valor)));
                    fat.dataVencimento = Intl.DateTimeFormat('pt-BR').format(new Date(fat.dataVencimento));
                    fat.dataFechamento = Intl.DateTimeFormat('pt-BR').format(new Date(fat.dataFechamento));
                    fat.pagamentoMinimo.valor = Intl.NumberFormat('pt-BR').format(new Number(this.inverteValor(fat.pagamentoMinimo.valor)));
                    fat.mesRef = month + '/' + new Intl.DateTimeFormat('pt', { year: 'numeric' }).format(dtVencimento);

                    let config_Tabela = {
                        botao_limpar_bloq: true,
                        idx: fat.dataVencimento,
                        dados: fat,
                        linhas_selecionadas: [],
                        setSelectedRows: []
                    }

                    this.fatFechadasArr.push(config_Tabela);

                });
            }
        })
            .catch(error => {
                this.loaded = true;
                this.showErrorToast('Erro ao exibir faturas', error.message);
            });
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
        this.template.querySelectorAll('c-bcsf_cmp_detalhes_fatura').forEach(child => child.limparSelecao());
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
        console.log('----------------------');
        console.log(JSON.stringify(detalhesEstorno));
        console.log('----------------------');
        console.log(JSON.stringify(this.faturasSelecionadas));
        console.log('----------------------');

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
            label: 'Autorização On-us e Off-us',
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
}