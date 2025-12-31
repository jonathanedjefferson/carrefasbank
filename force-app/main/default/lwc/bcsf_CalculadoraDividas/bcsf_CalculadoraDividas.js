import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/containerSize";

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/CalculadoraDividasController.getContaFinanceira';
import getParametrosMinimos from '@salesforce/apex/CalculadoraDividasController.ObterParametrosBusca';
import calcularJurosEncargos from '@salesforce/apex/CalculadoraDividasController.CalcularJurosEncargos';
import calcularSaldoDevedor from '@salesforce/apex/CalculadoraDividasController.CalcularSaldoDevedor';
import createCase from '@salesforce/apex/CalculadoraDividasController.createCase';


export default class BCSF_CalculadoraDividas extends LightningElement {

    get optionsCalcular() {
        return [
            { label: 'Calcular juros e encargos da próxima fatura', value: 'juros_encargos' },
            { label: 'Calcular saldo devedor total para quitação', value: 'saldo' },
        ];
    }

    get optionsEscolherDados() {
        return [
            { label: 'Sim', value: 'Sim' },
            { label: 'Não', value: 'Não' },
        ];
    }

    date = new Date();
    month = (this.date.getMonth() + 1) < 10 ? '0'+(this.date.getMonth() + 1) : (this.date.getMonth() + 1);
    day = this.date.getDate()  < 10 ? '0' + this.date.getDate() : this.date.getDate();
    @track dateToday = this.day + '/' + this.month + '/' + this.date.getFullYear();
    
    //#region Variaveis 
    spinner = false;
    canal = 'cockpit';
    titleErro = '';
    mensagemErro = 'Houve um comportamento inesperado do sistema, tente novamente em instantes.'; 
    numeroCaso = null;
    caseId = null;

    @api recordId;
    
    @track showCardPrincipal = false;
    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;

    @track numeroConta = '--';
    @track nome = '--';
    @track cpf = '';
    @track idEmpresa = null;
    @track accountId = null;
    @track unidadeDescricao = null;
    @track logoTipo = null;
    @track statusConta = "--";
    @track evento;
    @track origemValue = 'Cobrança';
    @track canalValue = 'Voz';

    @track dataPagamentoSelecionada = null;
    @track valorPagamentoSelecionado = null;

    @track escolhaCalculo;
    @track escolhaDados;
    @track isFluxoJurosEncargos;
    @track isFluxoSaldo;
    @track isDadosSelecionados;
    showSaldoTotal = false;
    showBoxDadosPagamento = false;
    showBoxCase = false;
    
    @track sucessoSimulacao = false;
    @track disableButtonSimular = true;
    @track isErrorValor = false;
    @track isErrorData = false;

    // Dados simulação
    @track dataPagamento;
    @track valorPagamento;
    @track dataVencimentoUltimaFatura;
    @track dataVencimentoProximaFatura;
    @track saldoTotal;
    @track valorFatura;
    @track valorJurosEncargosCiclo;
    @track valorMulta;
    @track valorJurosMora;
    @track valorIOFAdicional;
    @track valorIOFDiario;
    @track valorJurosRotativo;
    @track valorJurosRemuneratorios;
    @track valorJurosRemuneratoriosParceleFacil;
    @track valorJurosRemuneratoriosParcelaPronta;
    @track saldoPostado;
    @track valorParceladosFuturos;
    @track valorDescontoAntecipacao;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        loadStyle(this, modal);
        this.showSpinner();
        this.showCardPrincipal = true;
        this.getDadosContaFinanceira();
    }

    getDadosContaFinanceira() {
        getContaFinanceira({ recordId: this.recordId })
            .then(result => {
                this.cpf = result.CPF;
                this.numeroConta = result.NumeroConta;
                this.idEmpresa = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.nome = result.Nome;
                this.statusConta = result.StatusConta;
                this.tipoProduto = result.TipoConta;

                if (this.idEmpresa == "1") {
                    this.unidadeDescricao = 'CARREFOUR';
                    this.logoTipo = LogoCarrefour;
                } else if (this.idEmpresa == "2") {
                    this.unidadeDescricao = 'ATACADÃO';
                    this.logoTipo = LogoAtacadao;
                }else if (this.idEmpresa == "6"){
                    this.unidadeDescricao = "SAM'S CLUB";
                    this.logoTipo = LogoSamsClub;
                }

                this.getParametrosMinimos();
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
                this.closeSpinner();
            });
    }

   //#region métodos handle

    handleChangeEscolhaCalculo(event) {
        const selectedOption = event.detail.value;
        this.escolhaCalculo = selectedOption;
        if(selectedOption === 'juros_encargos'){
            this.isFluxoJurosEncargos = true;
            this.isFluxoSaldo = false;
            this.showBoxDadosPagamento = false;
            this.dataPagamentoSelecionada = null;
            this.valorPagamentoSelecionado = null;
            this.isErrorData = false;
            this.isErrorValor = false;
            this.escolhaDados = null;
        } else if(selectedOption === 'saldo'){
            this.isFluxoJurosEncargos = false;
            this.isFluxoSaldo = true;
            this.showBoxDadosPagamento = true;
            this.isDadosSelecionados = null;
            this.showBoxCase = true;
            this.isErrorData = false;
            this.isErrorValor = false;
        }
        this.verifyDisabled();
    }

    handleChangeEscolhaDadosPagamento(event) {
        const selectedOption = event.detail.value;
        this.escolhaDados = selectedOption;
        if(selectedOption === 'Sim'){
            this.isDadosSelecionados = true;
            this.showBoxDadosPagamento = true;
            this.showSaldoTotal = false;
            this.isErrorData = false;
            this.isErrorValor = false;
        } else if(selectedOption === 'Não'){
            this.isDadosSelecionados = false;
            this.showSaldoTotal = true;
            this.showBoxDadosPagamento = false;
            this.valorPagamentoSelecionado = null;
            this.dataPagamentoSelecionada = null;
            this.isErrorData = false;
            this.isErrorValor = false;
        }
        this.showBoxCase = true;
        this.verifyDisabled();
    }

    handleButtonVoltar() {
        if(this.stepOne){
            this.dataPagamentoSelecionada = null;
            this.valorPagamentoSelecionado = null;
            if(this.isFluxoSaldo){
                this.escolhaCalculo = null;
                this.showBoxDadosPagamento = false;
                this.showBoxCase = false;
                this.isDadosSelecionados = false;
                this.isFluxoSaldo = false;
            } else if(this.escolhaDados ){
                this.showBoxDadosPagamento = false;
                this.showBoxCase = false;
                this.isDadosSelecionados = false;
                this.escolhaDados = null;
            } else if(this.escolhaDados == false || (this.escolhaCalculo != null && this.escolhaDados == null)){
                 this.isFluxoJurosEncargos = false;
                 this.escolhaCalculo = null;
            } else if (this.escolhaCalculo == null){
                this.closeQuickAction();
            }
        } else if(this.stepTwo ){
            this.stepTwo = false;
            this.stepOne = true;
        }

    }

    async handleButtonSimular(event) {
        this.showSpinner(); 

        if(this.isFluxoJurosEncargos){
            await this.calcularJurosEncargos();
        } else if(this.isFluxoSaldo){
            await this.calcularSaldoDevedor();
        }

        if(this.sucessoSimulacao && this.caseId == null){
            await this.CriarCaso();
            this.stepOne = false;
            this.stepTwo = true;
        } if(this.sucessoSimulacao){
            this.stepOne = false;
            this.stepTwo = true;
        }

        this.closeSpinner();
    }

    handleButtonIrCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }

    handleValorPagamento(event){
        this.valorPagamentoSelecionado = event.detail.value;
        this.verifyDisabled();
    }

    handleDataPagamento(event){
        this.dataPagamentoSelecionada = event.detail.value;
        this.verifyDisabled();
    }

    handleChangeOrigem(event){
        this.origemValue = event.target.value;
        this.canalValue = null;
        this.verifyDisabled();
    }
    handleChangeCanal(event){
        this.canalValue = event.target.value;
        if(this.canalValue === ''){
            this.canalValue = null;
        }
        this.verifyDisabled();
    }

    //#endregion

    //#region métodos Toast, Spinner e verify
    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, mode, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            messageData: [],
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    @api closeParentComponent;
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        
    }
    //#endregion

    async getParametrosMinimos() {      
        await getParametrosMinimos({
            canal: this.canal,
            idEmpresa: this.idEmpresa,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta
        }).then(result => {
            if (result){
                this.showCardPrincipal = false;
                this.stepOne = false;
                if(result.codigoErro === 'OK') {
                    this.showCardPrincipal = true;
                    this.stepOne = true;
                    this.moeda = result.pagamentoMinimo.moeda;
                    this.valorMinLabel =  this.formatCurrencyMoeda(this.moeda, result.pagamentoMinimo.valor);
                    this.valorMinimo = result.pagamentoMinimo.valor;
                    var dateObject = new Date(result.dataInicial);
                    this.dataMinima = this.formatUTCDate(dateObject);
                    dateObject = new Date(result.dataFinal);
                    this.dataMaxima = this.formatUTCDate(dateObject);
                    this.dataMinimaFormatted = this.formatDate(this.dataMinima, false) + ' ';
                    this.dataMaximaFormatted = this.formatDate(this.dataMaxima, false);
                } else if(result.codigoErro === 'ERROR') {
                    this.showToast('Erro', this.mensagemErro, 'error', 'dismissible', true);
                } else {
                    this.showToast('Erro', result.mensagem, 'error', 'dismissible', true);
                }
            } else {
                this.showToast('Erro', this.mensagemErro, 'error', 'dismissible', true);
            }
        }).catch(error => {
            this.showToast('Erro', this.mensagemErro, 'error', 'dismissible', true);
            console.log(error);
        });
        this.closeSpinner();
    }

    async calcularJurosEncargos() {        
        await calcularJurosEncargos({
            canal: this.canal,
            idEmpresa: this.idEmpresa,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            dataPagamento: this.dataPagamentoSelecionada,
            valorPagamento: this.valorPagamentoSelecionado
        }).then(result => {
            this.mensagem = '';
            this.isErrorData = false;
            this.isErrorValor = false;
            if (result){
                if(result.codigoErro == 'OK') {
                    this.sucessoSimulacao = true;
                    this.getDadosSimulacaoFormatted(result);
                    this.evento = 'Juros e encargos da próxima fatura';
                } else if(result.codigoErro === 'ERROR') {
                    this.sucessoSimulacao = false;
                    this.showToast('Erro', this.mensagemErro, 'error', 'dismissible', true);
                } else if(result.codigoErro === '4' || result.codigoErro === '6') {
                    this.sucessoSimulacao = false;
                    this.isErrorData = true;
                    this.isErrorValor = false;
                    this.mensagem = result.mensagem;
                } else if(result.codigoErro === '5') {
                    this.sucessoSimulacao = false;
                    this.isErrorValor = true;
                    this.isErrorData = false;
                    this.mensagem = result.mensagem;
                }
            }
        }).catch(error => {
            console.log(error);
        });
    }

    async calcularSaldoDevedor() {        
        await calcularSaldoDevedor({
            canal: this.canal,
            idEmpresa: this.idEmpresa,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            dataPagamento: this.dataPagamentoSelecionada
        }).then(result => {
            console.log(this.mensagem);
            this.mensagem = '';
            this.isErrorData = false;
            this.isErrorValor = false;
            if (result){
                if(result.codigoErro == 'OK') {
                    this.sucessoSimulacao = true;
                    this.getDadosSimulacaoFormatted(result);
                    this.evento = 'Juros e encargos do saldo total para quitação ';
                } else if(result.codigoErro === 'ERROR') {
                    this.sucessoSimulacao = false;
                    this.showToast('Erro', this.mensagemErro, 'error', 'dismissible', true);
                } else if(result.codigoErro === '4' || result.codigoErro === '6') {
                    this.sucessoSimulacao = false;
                    this.isErrorData = true;
                    this.isErrorValor = false;
                    this.mensagem = result.mensagem;
                } else if(result.codigoErro === '5') {
                    this.sucessoSimulacao = false;
                    this.isErrorValor = true;
                    this.isErrorData = false;
                    this.mensagem = result.mensagem;
                }
            }
        }).catch(error => {
            console.log(error);
        });
    }

    async CriarCaso() {
        await createCase({
            evento: this.evento,
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa
        }).then(result => {
            if (result){
                this.numeroCaso = result.CaseNumber;
                this.caseId = result.Id;   
            }
        }).catch(error => {
            console.log(error);
            this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
        });
    }

    verifyDisabled(){
        if(this.isFluxoJurosEncargos && (this.isDadosSelecionados == null || this.isDadosSelecionados) &&
            (this.valorPagamentoSelecionado == null || this.valorPagamentoSelecionado === '' 
                || this.dataPagamentoSelecionada == null)){
                this.disableButtonSimular = true;
        } else if(this.isFluxoSaldo && this.dataPagamentoSelecionada == null){
            this.disableButtonSimular = true;
        }else if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined) {
            this.disableButtonSimular = true;
        } else {
            this.disableButtonSimular = false;
        }
    }

    getDadosSimulacaoFormatted(result) {
        var dateObject = new Date(result.dataPagamento);
        this.dataPagamento = this.formatUTCDate(dateObject);
        if(this.isFluxoJurosEncargos && !this.isDadosSelecionados){
            this.dataPagamento = '-';
        }

        dateObject = new Date(result.dataVencimentoUltimaFatura);
        this.dataVencimentoUltimaFatura = this.formatUTCDate(dateObject);

        dateObject = new Date(result.dataVencimentoProximaFatura);
        this.dataVencimentoProximaFatura = this.formatUTCDate(dateObject);

        this.valorPagamento = this.formatCurrencyMoeda(this.moeda, result.valorPagamento);
        this.saldoTotal = this.formatCurrencyMoeda(this.moeda, result.saldoTotal);
        this.valorFatura = this.formatCurrencyMoeda(this.moeda, result.valorFatura);
        this.valorPago = this.formatCurrencyMoeda(this.moeda, result.valorPago);
        this.valorJurosEncargosCiclo = this.formatCurrencyMoeda(this.moeda, result.valorJurosEncargosCiclo);
        this.valorMulta = this.formatCurrencyMoeda(this.moeda, result.valorMulta);
        this.valorJurosMora = this.formatCurrencyMoeda(this.moeda, result.valorJurosMora);
        this.valorIOFAdicional = this.formatCurrencyMoeda(this.moeda, result.valorIOFAdicional);
        this.valorIOFDiario = this.formatCurrencyMoeda(this.moeda, result.valorIOFDiario);
        this.valorJurosRotativo = this.formatCurrencyMoeda(this.moeda, result.valorJurosRotativo);
        this.valorJurosRemuneratorios = this.formatCurrencyMoeda(this.moeda, result.valorJurosRemuneratorios);
        this.valorJurosRemuneratoriosParceleFacil = this.formatCurrencyMoeda(this.moeda, result.valorJurosRemuneratoriosParceleFacil);
        this.valorJurosRemuneratoriosParcelaPronta = this.formatCurrencyMoeda(this.moeda, result.valorJurosRemuneratoriosParcelaPronta);

        this.saldoPostado = this.formatCurrencyMoeda(this.moeda, result.saldoPostado);
        this.valorParceladosFuturos = this.formatCurrencyMoeda(this.moeda, result.valorParceladosFuturos);
        this.valorDescontoAntecipacao = this.formatCurrencyMoeda(this.moeda, result.valorDescontoAntecipacao);
        this.valorEncargoRotativoEmAtraso = this.formatCurrencyMoeda(this.moeda, result.valorEncargoRotativoEmAtraso);
    }

    formatCurrencyMoeda(moeda, value) {
        if(value) {
            return moeda + ' ' + value.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
        } else {
            return '-'
        }
    }

    formatDate(date, addDia = false) {
        if (!date) return '-';
        const dt = new Date(date);
        const day = addDia ? String(dt.getDate()+1).padStart(2, '0') : String(dt.getDate()).padStart(2, '0');
        const month = String(dt.getMonth() + 1).padStart(2, '0');
        const year = dt.getFullYear();
        return `${day}/${month}/${year}`;
    }

    formatUTCDate(date){
        const dt = new Date(date);
        const day = String(dt.getUTCDate()).padStart(2, '0');
        const month = String(dt.getUTCMonth() + 1).padStart(2, '0');
        const year = dt.getUTCFullYear();
        return `${day}/${month}/${year}`;
    }

}