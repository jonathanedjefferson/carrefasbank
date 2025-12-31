import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';
import LogoTransversal from '@salesforce/resourceUrl/LogoTransversal';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import getCartaoTitular from '@salesforce/apex/DesbloqueioContaController.getCartaoTitular';
import getContaFinanceira from '@salesforce/apex/DesbloqueioContaController.getContaFinanceira';
import desbloquearConta from '@salesforce/apex/DesbloqueioContaController.DesbloquearConta';
import createCaseDesbloqueioConta from '@salesforce/apex/DesbloqueioContaController.createCaseDesbloqueioConta';


export default class Bcsf_DesbloqueioConta extends LightningElement {

    date = new Date();
    month = (this.date.getMonth() + 1) < 10 ? '0'+(this.date.getMonth() + 1) : (this.date.getMonth() + 1);
    day = this.date.getDate()  < 10 ? '0' + this.date.getDate() : this.date.getDate();
    @track dateToday = this.day + '/' + this.month + '/' + this.date.getFullYear();
    
    //#region Variaveis 
    spinner = false;
    canal = 'cockpit';
    sistema = 'cockpit';
    areaPrincipal = null;
    closeModalComponent = true;
    sucessoDesbloqueio = false;
    titleErro = '';
    msgErro = '';
    numeroCaso = null;
    caseId = null;
    @track checked2via = false;
    showButton2Via = false;

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
    @track numeroCartao = "--";
    @track nomeReduzido = "--";
    @track dataValidade = "--";
    @track origemValue;
    @track canalValue;
    
    @track disableButtonSalvar = false;

    //#endregion

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

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

    connectedCallback() {
        this.showSpinner();
        this.getDadosContaFinanceira();

        this.closeSpinner();
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

                if(result.CartaoTransversal === true){
                    this.logoTipo = LogoTransversal;
                }

                this.getCartaoTitular();
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
            });
    }

    async getCartaoTitular(){
        await getCartaoTitular({ contaFinanceiraId: this.recordId })
            .then(result => {
                this.dataValidade = result.DataValidade;
                this.numeroCartao = result.NumeroCartao;
                this.nomeReduzido = result.NomeReduzido;
                this.tipoProduto = result.TipoProduto;

                if(this.dataValidade == '--'){
                    this.cartaoExpirado =  false;
                } else {
                    const dataAtual = new Date();
                    dataAtual.setDate(1);
                    this.cartaoExpirado = dataAtual >= new Date('01/' + this.dataValidade);
                }

                this.showCardPrincipal = true;
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre o cartão titular!', 'error', true);
            });
    }

   //#region métodos handle

    handleButtonCancelar() {
        this.closeQuickAction();
    }

    handleButtonVoltar() {
        this.stepTwo =  false;
        this.stepOne = true;
    }

    handleSegundavia(event){
        this.checked2via = event.target.checked;
    }

    async handleButtonSalvar(event) {
        this.showSpinner(); 
        await this.desbloqueioConta();

        if(this.sucessoDesbloqueio){
            this.CriarCaso();  
            this.stepTwo = false;
            this.stepThree = true;
            this.showButton2Via = !this.cartaoExpirado && !this.checked2via;
        } else {
            this.showToast(this.titleErro, this.msgErro, 'error', 'sticky', true);
        }

        this.closeSpinner();
    }

    handleButtonIrCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
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

    handleButtonSegundaViaCartao(event) {
        this.showCardPrincipal = false;
        this.abrirSegundaViaCartao = true;
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
        if (this.closeParentComponent) {
            this.abrirSegundaViaCartao = false;
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    //#endregion

    async desbloqueioConta() {        
        await desbloquearConta({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idEmpresa: this.idEmpresa,
            canal: this.canal,
            area: this.areaPrincipal,
            sistema: this.sistema
        }).then(result => {
            if (result){
                if(result.statusAPI == 'OK') {
                    this.sucessoDesbloqueio = true;  
                } else if (result.statusAPI == 'ERRO_PERFILIZACAO'){
                    this.sucessoDesbloqueio = false;
                    this.titleErro =  'Esta conta não pode ser desbloqueada';
                    this.msgErro = 'Status da conta não permite desbloqueio.';
                } else {
                    this.sucessoDesbloqueio = false;
                    this.titleErro =  'Falha ao realizar a solicitação';
                    this.msgErro = 'Houve um comportamento inesperado do sistema, tente novamente em instantes.'
                }
            }
        }).catch(error => {
            console.log(error);
        });
    }

    async CriarCaso() {
        await createCaseDesbloqueioConta({
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

    irParaConfirmacao(){
        this.disableButtonSalvar = true;
        this.stepOne = false;
        this.stepTwo = true;
    }

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined) {
            this.disableButtonSalvar = true;
        } else {
            this.disableButtonSalvar = false;
        }
    }

}