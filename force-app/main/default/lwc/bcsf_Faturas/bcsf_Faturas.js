import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { EnclosingTabId, getTabInfo, openSubtab } from 'lightning/platformWorkspaceApi';

import criaOuVinculaCaso from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.criaOuVinculaCaso';
import verificaAlcada from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.verificaAlcada';

import obterResumoFaturaConta from '@salesforce/apex/ResumoFaturaController.obterResumoFaturaConta';
import obterResumoFaturaMes from '@salesforce/apex/ResumoFaturaController.obterResumoFaturaMes';

import calloutDetalhesFatura from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.buscarDetalhesFatura';
import calloutDetalhesFaturaAberta from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.buscarDetalhesFaturaAberta';

import { loadStyle } from "lightning/platformResourceLoader";
import cssFatura from "@salesforce/resourceUrl/TelaFatura";

import NUMERO_CONTA from '@salesforce/schema/ContaFinanceira__c.NumeroConta__c';
import CPF_CLIENTE from '@salesforce/schema/ContaFinanceira__c.NomeCliente__r.CPF__c';
import UNIDADE_NEGOCIO from '@salesforce/schema/ContaFinanceira__c.UnidadeNegocio__c';
import ACCOUNTID from '@salesforce/schema/ContaFinanceira__c.NomeCliente__c';
import CaseNumber from '@salesforce/schema/Case.CaseNumber';
import StayInTouchSignature from '@salesforce/schema/User.StayInTouchSignature';
import { NavigationMixin } from 'lightning/navigation';

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

export default class BCSF_Faturas extends NavigationMixin(LightningElement) {

    constructor() {
        super();
        this.template.addEventListener('updateResumo', this.handleUpdateEvent.bind(this));
    }

    closeModalComponent = true;
    columns = columns;
    columns2 = columns2;
    section = [];
    loaded = false;
    spinner = false;

    @api recordId;
    @track listaFaturas = [];
    @track faturasSelecionadas = [];
    @track faturaAbertaTable;

    @track numeroConta;
    @track cpfCliente;
    @track unidadeNegocio;
    @track accountid;

    @track origin;
    @track canal;
    @track dataRegulatoria;


    @track valorLimiteTotal = null;
    @track valorLimiteDisponivel = null;
    @track moeda = null;

    @track setSelectedRows = [];
    @track showEstornoModal = false;
    @track showNovoCaso = false;

    @track isLigadoButtonContestacao = false;

    @track bloq_limparTudo = true;
    @track bloq_estornar = true;

    @track UserId = USER_ID;
    @track ManagerId;
    @track AreaPrincipal;
    @track modalSegundaVia = false;
    @track codigoBarras = '--';
    @track modalBoletoAvulso = false;

    countFaturasAnteriores = 0;
    @track loadMore = false;

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

            this.obterResumoFaturaConta();

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

    async connectedCallback() {
        loadStyle(this, cssFatura);
    }

    async obterResumoFaturaConta() {
        await obterResumoFaturaConta({
            numeroConta: this.numeroConta,
            cpf: this.cpfCliente.replaceAll('.', '').replaceAll('-', ''),
            unidade: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result != null && result.StatusAPI === 'OK') {

                const listSize = result.faturas.length;
                var index = 0;
                result.faturas.forEach(fatura => {
                    if(!fatura.dataVencimento) return;

                    let mesAnoFatura;
                    let isFaturaAberta;
                    if(fatura.idTipoFatura == 0){
                        mesAnoFatura = 'Fatura Aberta';
                        isFaturaAberta = true;
                        this.moeda = fatura.limiteTotal.moeda;
                        this.valorLimiteDisponivel = Intl.NumberFormat('pt-BR').format(new Number(fatura.limiteDisponivel.valor));
                        this.valorLimiteTotal = Intl.NumberFormat('pt-BR').format(new Number(fatura.limiteTotal.valor));
                        this.faturaAbertaTable = true;
                    } else {      
                        isFaturaAberta = false;   
                        let dataVencimento = new Date(fatura.dataVencimento);
                        let month = dataVencimento.toLocaleString('pt-BR', { month: 'short' });
                        mesAnoFatura = month + '/' + new Intl.DateTimeFormat('pt', { year: 'numeric' }).format(dataVencimento);
                    }

                    if(fatura.ultimaFechada){
                        this.codigoBarras = fatura.linhaDigitavel;
                    } 

                    let valorFaturaFormatado  = Intl.NumberFormat('pt-BR').format(new Number(fatura.valorFatura.valor));
                    let dataVencimentoOriginal = fatura.dataVencimento;
                    let dataVencimentoFormatada = Intl.DateTimeFormat('pt-BR').format(new Date(dataVencimentoOriginal));
                    let dataFechamentoFormatada = Intl.DateTimeFormat('pt-BR').format(new Date(fatura.dataFechamento));
                    fatura.valorMinimo.valor = Intl.NumberFormat('pt-BR').format(new Number(fatura.valorMinimo.valor));
                    fatura.valorPago.valor = Intl.NumberFormat('pt-BR').format(new Number(fatura.valorPago.valor));

                    this.listaFaturas.push(
                        { 
                            idFatura: fatura.idFatura, 
                            isFaturaAberta: isFaturaAberta,
                            isFaturaCarregada: true,
                            idTipoFatura: fatura.idTipoFatura,
                            tipoFatura: fatura.tipoFatura,
                            tipoFaturaClass: 'tagTipoFatura tipoFatura_' + fatura.idTipoFatura,
                            mesAnoFatura: mesAnoFatura,
                            valorFatura: fatura.valorFatura,
                            valorFaturaFormatado: valorFaturaFormatado,
                            dataVencimentoOriginal: dataVencimentoOriginal,
                            dataVencimentoFormatada: dataVencimentoFormatada,
                            dataFechamentoFormatada: dataFechamentoFormatada,
                            valorMinimo: fatura.valorMinimo,
                            valorPago: fatura.valorPago,
                            botao_limpar_bloq: true,
                            linhas_selecionadas: [],
                            setSelectedRows: []
                        }
                    );

                    // Adiciona os próximos meses disponíveis
                    if(index == listSize - 1){
                        let indexFatura = 0;
                        this.loadMore = true;
                        fatura.faturasAnteriores.forEach(faturaAnterior => {
                            let dataFaturaAnterior = new Date(faturaAnterior);
                            let month = dataFaturaAnterior.toLocaleString('pt-BR', { month: 'short' });
                            mesAnoFatura = month + '/' + new Intl.DateTimeFormat('pt', { year: 'numeric' }).format(dataFaturaAnterior);

                            this.listaFaturas.push(
                                {
                                    idFatura: '' + indexFatura,
                                    mesAnoFatura: mesAnoFatura,
                                    mesAno: faturaAnterior,
                                    isFaturaCarregada: false,
                                    botao_limpar_bloq: true,
                                    linhas_selecionadas: [],
                                    setSelectedRows: []
                                }
                            );
                            indexFatura++;
                        });
                        this.countFaturasAnteriores = indexFatura;
                    }
                    index++;
                });

                this.loaded = true;
            } else {
                this.codigoBarras = '--';
                throw new Error('Erro de Serviço');
            };
        }).catch(error => {
            this.loaded = true;
            this.showErrorToast('Erro ao exibir faturas', error.message);
        })
    }

    async obterResumoFaturaMes(mesAno, isLoadMore) {
        await obterResumoFaturaMes({
            numeroConta: this.numeroConta,
            mesAno : mesAno,
            cpf: this.cpfCliente.replaceAll('.', '').replaceAll('-', ''),
            unidade: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result != null && result.StatusAPI === 'OK') {

                var fatura = result.fatura;
                let dataVencimento = new Date(fatura.dataVencimento);
                let month = dataVencimento.toLocaleString('pt-BR', { month: 'short' });
                let mesAnoFatura = month + '/' + new Intl.DateTimeFormat('pt', { year: 'numeric' }).format(dataVencimento);
                let valorFaturaFormatado  = Intl.NumberFormat('pt-BR').format(new Number(fatura.valorFatura.valor));
                let dataVencimentoOriginal = fatura.dataVencimento;
                let dataVencimentoFormatada = Intl.DateTimeFormat('pt-BR').format(new Date(dataVencimentoOriginal));
                let dataFechamentoFormatada = Intl.DateTimeFormat('pt-BR').format(new Date(fatura.dataFechamento));
                fatura.valorMinimo.valor = Intl.NumberFormat('pt-BR').format(new Number(fatura.valorMinimo.valor));
                fatura.valorPago.valor = Intl.NumberFormat('pt-BR').format(new Number(fatura.valorPago.valor));

                var listaFaturas = this.listaFaturas;
                const indexListaFaturas = listaFaturas.findIndex(fatura => fatura.mesAno === mesAno);

                const faturaAtualizada = { 
                    idFatura: fatura.idFatura, 
                    isFaturaAberta: false,
                    isFaturaCarregada: true,
                    idTipoFatura: fatura.idTipoFatura,
                    tipoFatura: fatura.tipoFatura,
                    tipoFaturaClass: 'tagTipoFatura tipoFatura_' + fatura.idTipoFatura,
                    mesAnoFatura: mesAnoFatura,
                    valorFatura: fatura.valorFatura,
                    valorFaturaFormatado: valorFaturaFormatado,
                    dataVencimentoOriginal: dataVencimentoOriginal,
                    dataVencimentoFormatada: dataVencimentoFormatada,
                    dataFechamentoFormatada: dataFechamentoFormatada,
                    valorMinimo: fatura.valorMinimo,
                    valorPago: fatura.valorPago,
                    botao_limpar_bloq: true,
                    linhas_selecionadas: [],
                    setSelectedRows: []
                }
                // Atualiza os dados da fatura carregada
                this.listaFaturas[indexListaFaturas] = faturaAtualizada;

                // Adiciona os próximos meses disponíveis
                if(fatura.faturasAnteriores !== null && fatura.faturasAnteriores.length > 0){
                    if(isLoadMore){
                        fatura.faturasAnteriores.forEach(faturaAnterior => {
                            const indexListaFaturas = listaFaturas.findIndex(fatura => fatura.mesAno === faturaAnterior);
                            if(indexListaFaturas < 0){
                                this.countFaturasAnteriores++;
                                let dataFaturaAnterior = new Date(faturaAnterior);
                                let month = dataFaturaAnterior.toLocaleString('pt-BR', { month: 'short' });
                                mesAnoFatura = month + '/' + new Intl.DateTimeFormat('pt', { year: 'numeric' }).format(dataFaturaAnterior);
        
                                this.listaFaturas.push(
                                    {
                                        idFatura: '' + this.countFaturasAnteriores,
                                        mesAnoFatura: mesAnoFatura,
                                        mesAno: faturaAnterior,
                                        isFaturaCarregada: false,
                                        botao_limpar_bloq: true,
                                        linhas_selecionadas: [],
                                        setSelectedRows: []
                                    }
                                );
                            }
                        });
                    }
                } else {
                    this.loadMore = false;
                }
            } else {
                throw new Error('Erro de Serviço');
            };
            this.closeSpinner();
        }).catch(error => {
            this.closeSpinner();
            this.showErrorToast('Erro ao carregar fatura', error.message);
        })
    }

    loadMoreFaturas(event){
        this.showSpinner();
        const lastIndex = this.listaFaturas.length - 1;
        const mesAno =  this.listaFaturas[lastIndex].mesAno;
        this.obterResumoFaturaMes(mesAno, true);
    }

    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }

    inverteValor(valor) {
        return valor == 0 ? 0 : valor * (-1);
    }

    showDetalhesFatFechada(event) {
        this.showDetalhesFatura(event, false);
    }

    handleSectionToggle(event) {
        this.section = event.detail.openSections;
        this.showSpinner();

        this.section.forEach(idFatura => {
            const faturaSelecionada = this.listaFaturas.find(fatura => fatura.idFatura === idFatura);
            if(faturaSelecionada != null && !faturaSelecionada.isFaturaCarregada){
                console.log('Vou carregar essa fatura: ' + faturaSelecionada.mesAno);
                this.obterResumoFaturaMes(faturaSelecionada.mesAno, false);
            } else {
                console.log('Fatura já carregada: ' + idFatura);
            }
        });
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

    //#region métodos handler

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
                    c__limiteTotal: this.valorLimiteTotal,
                    c__limiteDisponivel: this.valorLimiteDisponivel
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
                        c__limiteTotal: this.valorLimiteTotal,
                        c__limiteDisponivel: this.valorLimiteDisponivel
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

    //#region fim métodos handler

    fetchDetalhes() {

        if(this.is_fatura_aberta){
            this.fetchDetalhesFaturaAberta();
        } else{
            const [dd, mm, yyyy] = this.fatura.dados.dataVencimento.split("/");
            const data_formatada = `${mm}-${yyyy}`;
    
            calloutDetalhesFatura({ 
                numeroConta: this.cliente_infos.numeroConta, 
                dataVencimento: data_formatada, 
                cpfCliente: this.cliente_infos.cpfCliente, 
                unidadeNegocio: this.cliente_infos.unidadeNegocio,
                canal: 'cockpit'
            }).then(result => {
                let infos = JSON.parse(JSON.stringify(result));
                
                infos.forEach(inf => {
                    inf.selecionavel = this.reasonCode_selecionaveis.includes(inf.reasonCode);
                    inf.agrupamentoLancamentos.forEach(agrup => {
                        agrup.selecionavel = this.reasonCode_selecionaveis.includes(agrup.descricaoLancamento.reasonCode);
                    });
                    inf.valor = this.inverteValor(inf.valor);
                    if(inf.dataTransacao) inf.dataTransacaoFormatada = this.formatDate(inf.dataTransacao.toString().slice(0,10));
                    if(inf.numeroCartao) inf.numeroCartao = inf.numeroCartao != this.cliente_infos.numeroConta ? this.formatarCartao(inf.numeroCartao) : null;
                    this.setPagamentoEfetuado(this.fatura.dados.creditos);
                    inf.dataVencimentoFatura = this.fatura.dados.dataVencimentoOriginal;
                    inf.numeroConta = this.cliente_infos.numeroConta;
                });
    
                this.detalhes = this.agruparPorDescricaoGrupo(infos).sort(this.orderByDataTransacao_Cresc);
                this.section = [this.sectionLabel];
            })
        }
    }

    fetchDetalhesFaturaAberta() {

        calloutDetalhesFaturaAberta({ 
            numeroConta: this.cliente_infos.numeroConta,
            cpfCliente: this.cliente_infos.cpfCliente, 
            unidadeNegocio: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            let infos = JSON.parse(JSON.stringify(result));

            infos.forEach(inf => {
                inf.selecionavel = this.reasonCode_selecionaveis.includes(inf.reasonCode);
                inf.agrupamentoLancamentos.forEach(agrup => {
                    agrup.selecionavel = this.reasonCode_selecionaveis.includes(agrup.descricaoLancamento.reasonCode);
                });
                inf.valor = this.inverteValor(inf.valor);
                if(inf.dataTransacao) inf.dataTransacaoFormatada = this.formatDate(inf.dataTransacao.toString().slice(0,10));
                if(inf.numeroCartao) inf.numeroCartao = inf.numeroCartao != this.cliente_infos.numeroConta ? this.formatarCartao(inf.numeroCartao) : null;
                inf.dataVencimentoFatura = this.fatura.dados.dataVencimentoOriginal;
                inf.numeroConta = this.cliente_infos.numeroConta;
            });

            if(!infos[0].faturaIndisponivel) this.detalhes = this.agruparPorDescricaoGrupo(infos).sort(this.orderByDataTransacao_Cresc);
            this.section = [this.sectionLabel];
        })
    }

    //# Listagem de transações de faturas
    
    fetchDetalhesFaturaAberta() {

        calloutDetalhesFaturaAberta({ 
            numeroConta: this.cliente_infos.numeroConta,
            cpfCliente: this.cliente_infos.cpfCliente, 
            unidadeNegocio: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            let infos = JSON.parse(JSON.stringify(result));

            infos.forEach(inf => {
                inf.selecionavel = this.reasonCode_selecionaveis.includes(inf.reasonCode);
                inf.agrupamentoLancamentos.forEach(agrup => {
                    agrup.selecionavel = this.reasonCode_selecionaveis.includes(agrup.descricaoLancamento.reasonCode);
                });
                inf.valor = this.inverteValor(inf.valor);
                if(inf.dataTransacao) inf.dataTransacaoFormatada = this.formatDate(inf.dataTransacao.toString().slice(0,10));
                if(inf.numeroCartao) inf.numeroCartao = inf.numeroCartao != this.cliente_infos.numeroConta ? this.formatarCartao(inf.numeroCartao) : null;
                inf.dataVencimentoFatura = this.fatura.dados.dataVencimentoOriginal;
                inf.numeroConta = this.cliente_infos.numeroConta;
            });

            if(!infos[0].faturaIndisponivel) this.detalhes = this.agruparPorDescricaoGrupo(infos).sort(this.orderByDataTransacao_Cresc);
            this.section = [this.sectionLabel];
        })
    }

}