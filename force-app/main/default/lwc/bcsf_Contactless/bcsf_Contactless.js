import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import getCartaoesContactlessEnabled from '@salesforce/apex/ContactlessController.getCartaoesContactlessEnabled';
import getContaFinanceira from '@salesforce/apex/ContactlessController.getContaFinanceira';
import getContactlessStatus from '@salesforce/apex/ContactlessController.ContactlessBuscarStatus';
import setContactlessStatus from '@salesforce/apex/ContactlessController.ContactlessAlterarStatus';
import createCaseContactless from '@salesforce/apex/ContactlessController.createCaseAlterarStatusContactless';

export default class BCSF_Contactless extends LightningElement {
    
    //#region Variaveis 
    spinner = false;
    optionsCartoes = [];
    canal = 'cockpit';
    sistema = 'cockpit';
    areaPrincipal = null;
    msgAlertSemCartoes = "Não existe nenhum cartão disponível para ajuste no Pagamento por aproximação";
    msgAlertUmCartao = "Apenas este cartão está disponível";
    closeModalComponent = true;

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
    
    @track valueCartaoSelecionado = null;
    @track disableButtonCancelar = false;
    @track disableButtonSalvar = true;
    @track possuiUmCartaoContacless = false;
    @track possuiCartoesContacless = false;
    @track statusContactlessInicial = false;
    @track abrirSegundaViaCartao= false;

    @track numeroCartao = "";
    @track nomeReduzido = "";
    @track statusCartao = "";
    @track tipoCartaoChip = "";
    @track solicitar2Via = false;
    // indica se o cartão possui a tecnologia contactless
    @track contactless = false;
    // indica se o contactless está ativado ou desativado
    @track statusContactless = false;
    
    idSernoCartao = "";
    primeirosDigitosCartao = "";
    ultimosDigitosCartao = "";
    sucessoAlterarStatus = false;

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
        await this.carregarContactlessEnabled();
        
        if(this.possuiUmCartaoContacless && this.contactless){
            await this.contactlessBuscarStatus();
        }

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

    async handleChangeCartaoSelecionado(event) {
        this.showSpinner(); 
        this.idSernoCartao = event.detail.value;
        this.numeroCartao = '';
        this.nomeReduzido = '';
        this.primeirosDigitosCartao = '';
        this.ultimosDigitosCartao = '';
        var cartaoEncontrado = false;

        this.optionsCartoes.forEach(item => {
            if(item.value == this.idSernoCartao){
               this.numeroCartao = item.numeroCartao;
               this.nomeReduzido = item.nomeReduzido;
               this.primeirosDigitosCartao = item.primeirosDigitosCartao;
               this.ultimosDigitosCartao = item.ultimosDigitosCartao;
               this.contactless = item.contactless;
               this.statusCartao = item.statusCartao;
               this.tipoCartaoChip = item.tipoCartaoChip;
               cartaoEncontrado = true;
            }
        });

        // Verificar se o pagamento por aproximação do cartão está ativado ou desativado.
        if(cartaoEncontrado){
            if(this.contactless){
                await this.contactlessBuscarStatus();
            } else {
                this.stepTwo = true;
                this.solicitar2Via = !this.contactless && this.tipoCartaoChip;
            }
        }

        this.closeSpinner();
    }

    async handleButtonSalvar(event) {
        this.showSpinner(); 
        await this.alterarStatusContactless();

        if(this.sucessoAlterarStatus){

            var evento;
            if(this.statusContactless){
                // Ativação Pagamento por Aproximação
                evento = 'Reclamação sobre contactless';
            } else {
                // Desativação Pagamento por Aproximação
                evento = 'Desativar contactless';
            }

            this.CriarCaso(evento);
            this.showToast('Pagamento por aproximação ajustado!', '', 'success', 'sticky', true);
        } else {
            this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado do sistema, tente novamente em instantes.', 'error', 'sticky', false);
        }

        this.closeSpinner();
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

    handleChangeToggle(event){
        this.statusContactless = event.target.checked;
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

    // Lista de todos os cartões da conta financeira com status NORM
    async carregarContactlessEnabled() {
        await getCartaoesContactlessEnabled({
            recordId: this.recordId
        }).then(result => {
            if (result != null && result.length > 0) {
                let opcoes = [];
                result.forEach(item => {

                    var numeroCartao = item.NumeroCartao;
                    var primeirosDigitosCartao, ultimosDigitosCartao;
                    if(numeroCartao){
                        var cartao = numeroCartao.split('.');
                        if(cartao.length === 4){
                            primeirosDigitosCartao = cartao[0];
                            ultimosDigitosCartao = cartao[3];
                        } else if (numeroCartao.length == 16){
                            primeirosDigitosCartao = numeroCartao.substring(0,4);
                            ultimosDigitosCartao = numeroCartao.substring(12,16);
                        }
                    }

                    opcoes.push(
                        { 
                            label: 'Final ' + ultimosDigitosCartao + ' - ' + item.NomeReduzido + ' ('+ item.TitularidadeDescritivo +')',
                            value: item.NumeroSernoId,
                            numeroCartao: item.NumeroCartao,
                            nomeReduzido: item.NomeReduzido,
                            primeirosDigitosCartao: primeirosDigitosCartao,
                            ultimosDigitosCartao: ultimosDigitosCartao,
                            contactless: item.Contactless,
                            statusCartao: item.Status,
                            tipoCartaoChip: item.TipoCartao == 'C'
                        }
                    );
                });

                this.optionsCartoes = opcoes;
                if(opcoes.length == 1){
                    this.stepTwo = true;
                    this.possuiUmCartaoContacless = true;
                    this.idSernoCartao = opcoes[0].value;
                    this.valueCartaoSelecionado = this.idSernoCartao;
                    this.numeroCartao = opcoes[0].numeroCartao;
                    this.nomeReduzido = opcoes[0].nomeReduzido;
                    this.primeirosDigitosCartao = opcoes[0].primeirosDigitosCartao;
                    this.ultimosDigitosCartao = opcoes[0].ultimosDigitosCartao;
                    this.contactless = opcoes[0].contactless;
                    this.statusCartao = opcoes[0].statusCartao;
                    this.tipoCartaoChip = opcoes[0].tipoCartaoChip;
                } else {
                    this.possuiCartoesContacless = true;
                }
            } else {
                this.showToast('Nenhum cartão disponível', 'Não existe nenhum cartão disponível para ajuste no Pagamento por aproximação.', 'warning', 'sticky', true);
            }
            this.showCardPrincipal = true;
        }).catch(error => {
            console.log('carregarContactlessEnabled: ' + error);
            this.showToast('Consulta de cartões Contactless.', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', 'dismissible', true);
        });
    }

    async contactlessBuscarStatus() {       
        await getContactlessStatus({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idCartao: this.idSernoCartao,
            idEmpresa: this.idEmpresa,
            canal: this.canal,
            area: this.areaPrincipal,
            sistema: this.sistema
        }).then(result => {
            if (result != null && result.statusAPI == 'OK') {
                this.statusContactless = result.outputAPI.success;
                this.statusContactlessInicial = result.outputAPI.success;
                this.stepTwo = true;
            } else {
                this.stepTwo = false;
                this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado do sistema, tente novamente em instantes.', 'error', 'dismissible', false);
            }
        }).catch(error => {
            console.log(error);
            this.showToast('Consulta de status do cartão.', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', 'dismissible', true);
        });
    }

    async alterarStatusContactless() {        
        await setContactlessStatus({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idCartao: this.idSernoCartao,
            primeirosDigitosCartao: this.primeirosDigitosCartao,
            ultimosDigitosCartao: this.ultimosDigitosCartao,
            status: this.statusContactless,
            idEmpresa: this.idEmpresa,
            canal: this.canal,
            area: this.areaPrincipal,
            sistema: this.sistema
        }).then(result => {
            if (result != null && result.statusAPI == 'OK') {
                // resultado da alteração de status
                this.sucessoAlterarStatus = result.outputAPI.success;;  
            } else {
                this.sucessoAlterarStatus = false;
            }
        }).catch(error => {
            console.log(error);
        });
    }

    async CriarCaso(evento) {
        await createCaseContactless({
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
            evento: evento
        }).catch(error => {
            console.log(error);
            this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
        });
    }

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined ||
            this.statusContactless.toString() === this.statusContactlessInicial.toString()) {
                this.disableButtonSalvar = true;
        } else {
            this.disableButtonSalvar = false;
        }
    }

}