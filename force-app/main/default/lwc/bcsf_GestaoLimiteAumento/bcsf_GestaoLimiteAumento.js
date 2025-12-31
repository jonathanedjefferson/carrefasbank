import { LightningElement, track, api, wire } from 'lwc';
import { formatarValor } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/GestaoLimiteController.obterContaFinanceira';
import criarCaso from '@salesforce/apex/GestaoLimiteController.criarCaso';
import aumentarLimite from '@salesforce/apex/GestaoLimiteController.aumentarLimite';
import getExtratoCompacto from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.getExtratoCompacto';

import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class BCSF_GestaoLimiteAumento extends LightningElement {

    //#region Variaveis 
    spinner = false;
    @api recordId;
    closeModalComponent = true;

    showCardPrincipal = false;
    stepOne = false;
    stepTwo = false;
    stepThree = false;
    disableButtonFinalizar = true;
    msgErro = '';
    apresentarHistorico;

    numeroConta = '';
    nomeTitular = '';
    cpf = '';
    idEmpresa = null;
    unidadeDescricao = '';
    logoTipo = '';
    statusConta = null;
    accountId = null;
    canal = 'cockpit';
    limiteTotal;
    limiteTotalFormatado;
    limiteDisponivel;
    limiteDisponivelFormatado;

    valorLimiteDesejado;
    valorLimiteDesejadoFormatado;
    valorRendaComprovada;
    origemValue;
    canalValue;

    numeroCaso = null;
    caseId = null;
    
    //#endregion

    //#region wire's

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    //#endregion

    async connectedCallback() {
        this.showSpinner();
        await this.getContaFinanceira();
        await this.getExtratoFaturaCompacto();
        this.closeSpinner();
    }

    //#region handle

    handleButtonVoltar() {
        if(this.stepTwo){
            this.stepTwo =  false;
            this.stepOne = true;
        } else {
            this.closeQuickAction();
        }
    }

    async handleButtonProsseguir(){
        if(this.stepOne){
            this.stepOne = false;
            this.stepTwo = true;
            this.stepThree = false;
            this.valorLimiteDesejadoFormatado = formatarValor(this.valorLimiteDesejado);
        } else if(this.stepTwo){
            await this.aumentarLimite();
        }
    }

    handleButtonIrCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }

    handleValorLimiteDesejado(event) {
        this.valorLimiteDesejado = event.target.value;
        if(this.valorLimiteDesejado == this.limiteTotal){
            this.msgErro = 'Valor informado é igual ao limite atual';
        } else if(this.valorLimiteDesejado < this.limiteTotal){
            this.msgErro = 'Valor informado é inferior ao limite atual';
        } else {
            this.msgErro = '';
        }
    }

    handleValorRendaComprovada(event) {
        this.valorRendaComprovada = event.target.value;
    }

    handleChangeOrigem(event) {
        this.origemValue = event.target.value;
        this.canalValue = null;
        this.verifyDisabled();
    }

    handleChangeCanal(event) {
        this.canalValue = event.target.value;
        this.verifyDisabled();
    }

    handleButtonHistoricoLimite(){
        this.showCardPrincipal = false;
        this.apresentarHistorico = true;
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

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //#endregion

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null  || this.canalValue == undefined) {
                this.disableButtonFinalizar = true;
        } else {
            this.disableButtonFinalizar = false;
        }
    }

    get disableButtonProsseguir(){
        return this.valorLimiteDesejado == null || this.valorLimiteDesejado == undefined 
                || this.valorRendaComprovada == null || this.valorRendaComprovada == undefined
                || this.valorLimiteDesejado == '' || this.valorRendaComprovada == ''
                || this.hasError;;
    }

    get today(){
        let date = new Date();
        let month = (date.getMonth() + 1) < 10 ? '0'+(date.getMonth() + 1) : (date.getMonth() + 1);
        let day = date.getDate()  < 10 ? '0' + date.getDate() : date.getDate();
        return day + '/' + month + '/' + date.getFullYear();
    }

    get hasError(){
        return this.msgErro !== '';
    }

    //#region chamadas controller

    async getContaFinanceira(){
        try {
            const result = await getContaFinanceira({ recordId: this.recordId });
            this.cpf = result.CPF;
            this.nomeTitular = result.Nome;
            this.numeroConta = result.NumeroConta;
            this.idEmpresa = result.UnidadeNegocio;
            this.accountId = result.AccountId;
            this.statusConta = result.StatusConta;
    
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
        } catch (error) {
            console.log(error);
            this.showToast('Erro', 'Houve um erro ao buscar informações da Conta Financeira.', 'error', true);
        }
    }

    async getExtratoFaturaCompacto() {
        try {
            const result = await getExtratoCompacto({
                numeroConta: this.numeroConta,
                cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
                unidadeNegocio: this.idEmpresa,
                canal: this.canal
            });
            
            if (result.statusResponse == 'OK') {
                this.limiteTotal = result.limiteComprasCarrefour;
                this.limiteDisponivel = result.saldoDisponivelCompras;
                this.limiteTotalFormatado = formatarValor(result.limiteComprasCarrefour);
                this.limiteDisponivelFormatado = formatarValor(result.saldoDisponivelCompras);
                this.showCardPrincipal = true;
                this.stepOne = true;
            } else {
                this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true, 'sticky');
            }
        } catch (error) {
            this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true, 'sticky');
            console.error('Erro ao buscar Limites', error);
        }
    }

    async aumentarLimite() {
        this.showSpinner();
        aumentarLimite({
            numeroConta: this.numeroConta,
            unidadeNegocio: this.idEmpresa,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal: this.canal,
            valorRendaComprovada: this.valorRendaComprovada,
            valorLimiteSolicitado: this.valorLimiteDesejado 
        }).then(result => {
            this.sucesso = null;
            if (result != null && result.statusAPI === 'OK') {
                this.criarCasoAumentoLimite();
            } else {
                this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true, 'sticky');
                this.closeSpinner();
            }
        }).catch(error => {
            console.log(error);
            this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true, 'sticky');
            this.closeSpinner();
        });
    }

    async criarCasoAumentoLimite() {
        await criarCaso({
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
            evento: 'Aumento de limite'
        }).then(result => {
            if (result){
                this.stepOne = false;
                this.stepTwo = false;
                this.stepThree = true;
                this.numeroCaso = result.CaseNumber;
                this.caseId = result.Id;   
                this.closeSpinner();
            }
        }).catch(error => {
            console.log(error);
            this.closeSpinner();
            this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
        });
    }
}