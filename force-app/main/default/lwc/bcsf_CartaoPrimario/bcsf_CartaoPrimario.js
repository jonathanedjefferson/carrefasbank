import { LightningElement, track, wire, api } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import getContaFinanceira from '@salesforce/apex/CartaoPrimarioController.getContaFinanceira';
import getCartaoPrimario from '@salesforce/apex/CartaoPrimarioController.getCartaoPrimario';
import definirCartaoPrimario from '@salesforce/apex/CartaoPrimarioController.definirCartaoPrimario';
import createCase from '@salesforce/apex/CartaoPrimarioController.createCase';

export default class BCSF_CartaoPrimario extends LightningElement {
    
    date = new Date();
    month = (this.date.getMonth() + 1) < 10 ? '0'+(this.date.getMonth() + 1) : (this.date.getMonth() + 1);
    day = this.date.getDate()  < 10 ? '0' + this.date.getDate() : this.date.getDate();
    @track dateToday = this.day + '/' + this.month + '/' + this.date.getFullYear();

    //#region Variaveis 
    spinner = false;
    canal = 'cockpit';
    sistema = 'cockpit';
    areaPrincipal = null;

    @api recordId;
    
    @track showCardPrincipal = false;
    @track stepOne = true;
    @track stepTwo = false;

    @track numeroConta = '--';
    @track nome = '--';
    @track cpf = '';
    @track idEmpresa = null;
    @track accountId = null;
    @track tipoConta = null;
    @track logoTipo = null;
    @track origemValue;
    @track canalValue;
    @track disableButtonSalvar = true;

    idSernoCartao = "";
    numeroCartao = "--";
    nomeReduzido = "--";
    statusCartao = "--";
    dataEmissao = "--";
    labelFinalCartao = "--";
    changeEnable = false;
    sucessoAlterarCartao = false;
    numeroCaso = "--";
    caseId = "--";

    //#endregion

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.areaPrincipal = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    //#endregion

    async connectedCallback() {
        this.showSpinner();
        await this.getDadosContaFinanceira();
        await this.obterUltimoCartaoTitular();
        this.closeSpinner();
    }

    async getDadosContaFinanceira() {
        await getContaFinanceira({ recordId: this.recordId })
            .then(result => {
                this.cpf = result.CPF;
                this.numeroConta = result.NumeroConta;
                this.idEmpresa = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.nome = result.Nome;

                if (this.idEmpresa == "1") {
                    this.tipoConta = 'CARREFOUR';
                    this.logoTipo = LogoCarrefour;
                } else if (this.idEmpresa == "2") {
                    this.tipoConta = 'ATACADÃO';
                    this.logoTipo = LogoAtacadao;
                }else if (this.idEmpresa == "6"){
                    this.tipoConta = "SAM'S CLUB";
                    this.logoTipo = LogoSamsClub;
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
            });
    }

   //#region métodos handle

    handleButtonCancelar(event) {
        this.closeQuickAction();
    }

    async handleButtonSalvar(event) {
        this.showSpinner(); 
        await this.definirCartaoPrimario();

        if(this.sucessoAlterarCartao){
            this.CriarCaso();
        } else {
            this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado do sistema, tente novamente em instantes.', 'error', 'sticky', false);
            this.closeSpinner();
        }
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

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined) {
                this.disableButtonSalvar = true;
        } else {
            this.disableButtonSalvar = false;
        }
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
        this.dispatchEvent(new CustomEvent('closeparentmodal'));
        
    }

    refreshPage() {
        this.dispatchEvent(new CustomEvent('refreshpage'));
    }

    //#endregion

    // Lista de todos os cartões da conta financeira com status NORM
    async obterUltimoCartaoTitular() {
        await getCartaoPrimario({
            contaFinanceiraId: this.recordId,
            numeroConta: this.numeroConta,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            idEmpresa: this.idEmpresa,
            area: this.areaPrincipal,
            canal: this.canal,
            sistema: this.sistema
        }).then(result => {
            if (result != null) {
                var numeroCartao = result.NumeroCartao;
                var ultimosDigitosCartao;
                if(numeroCartao){
                    var cartao = numeroCartao.split('.');
                    if(cartao.length === 4){
                        ultimosDigitosCartao = cartao[3];
                    } else if (numeroCartao.length == 16){
                        ultimosDigitosCartao = numeroCartao.substring(12,16);
                    } else {
                        ultimosDigitosCartao = '--';
                    }
                }
              
                this.idSernoCartao = result.NumeroSernoId;
                this.numeroCartao = result.NumeroCartao;
                this.nomeReduzido = result.NomeReduzido;
                this.statusCartao = result.Status;
                this.dataEmissao = result.DataEmissao;
                this.isCartaoPrimario = result.IsCartaoPrimario;
                this.labelFinalCartao = 'Cartão Final ' + ultimosDigitosCartao;

                if(!this.isCartaoPrimario){
                    this.changeEnable = true;
                } else {
                    this.changeEnable = false;
                }  
            } else {
                this.showToast('Cartão indisponível', 'Ocorreu um erro ao obter cartão titular.', 'warning', 'sticky', true);
            }

            this.showCardPrincipal = true;
        }).catch(error => {
            console.log('carregarContactlessEnabled: ' + error);
            this.showToast('Consulta de cartões.', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', 'dismissible', true);
        });
    }

    async definirCartaoPrimario() {        
        await definirCartaoPrimario({
            contaFinanceiraId: this.recordId,
            numeroConta: this.numeroConta,
            numeroCartaoSerno: this.idSernoCartao,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            idEmpresa: this.idEmpresa,
            area: this.areaPrincipal,
            canal: this.canal,
            sistema: this.sistema
        }).then(result => {
            // resultado da alteração de cartão primário
            this.sucessoAlterarCartao = result;
        }).catch(error => {
            console.log(error);
        });
    }

    async CriarCaso(evento) {
        await createCase({
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
            evento: evento
        }).then(result => {
            if (result != null) {
                this.stepOne = false;
                this.stepTwo = true;
                this.numeroCaso = result.CaseNumber;
                this.caseId = result.Id;
                this.refreshPage();
            } else {
                this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
            }
            this.closeSpinner();
        }).catch(error => {
            console.log(error);
            this.closeSpinner();
            this.showToast('Error', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
        });
    }

}