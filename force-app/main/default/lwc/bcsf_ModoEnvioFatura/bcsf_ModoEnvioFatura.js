import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getContaFinanceira from '@salesforce/apex/BCSF_ModoEnvioFaturaController.getContaFinanceira';
import getTiposEnvioFatura from '@salesforce/apex/BCSF_ModoEnvioFaturaController.GetTiposEnvioFatura';
import updateEmailEnvioFatura from '@salesforce/apex/BCSF_ModoEnvioFaturaController.UpdateEmailEnvioFatura';
import updateTipoEnvioFatura from '@salesforce/apex/BCSF_ModoEnvioFaturaController.UpdateTipoEnvioFatura';
import atualizaEmail from '@salesforce/apex/BCSF_ModoEnvioFaturaController.atualizaEmail';
import criarCaso from '@salesforce/apex/BCSF_ModoEnvioFaturaController.criarCaso';
import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import { NavigationMixin } from 'lightning/navigation';


export default class Bcsf_ModoEnvioFatura extends NavigationMixin(LightningElement) {

    @api cmpAlteracaoCadastral;
    @api recordId;
    @api cmp2viafatura;
    //Váriaveis de layout
    @track spinner = false;
    @track pageOne = true;
    @track pageTwo = false;
    @track pageTree = false;
    @track pageEmail = false;
    @track pageCorreio = false;
    @track pagePhone = false;
    @track pageApp = false;
    @track infoCelularSeguro = false;
    @track disableBtnVoltar = true;
    @track disableBtnAtualizarEmail = false;
    @track disableBtnFinalizar = true;
    @track disableBtnSalvar = true;
    @track tipoEnvioValue = '';
    @track tipoEnvioId = '';
    @track atualizaEmailValue = false;
    @track numProtocolo = '--'
    @track caseId;


    //Dados solicitação e caso
    @track canal = 'cockpit';
    @track sistema = 'cockpit';
    @track area;
    @track origemValue;
    @track canalValue;
    @track evento = null;
    @track novoModoEnvio;
    @track objectInfoData;
    @track defaultRecordTypeId;
    @track alteracaoCadastral = false;
    
    //Dados cliente
    @track email = '--';
    @track emailAntigo = '--';
    @track accountId = '--';
    @track numeroConta = '--';
    @track tipoConta = '--';
    @track statusConta = '--';
    @track telefone = '--';
    @track bairro = '--';
    @track cep = '--';
    @track cidade = '--';
    @track complemento = '--';
    @track rua = '--';
    @track estado = '--'; 
    @track numero = '--';
    @track celularSeguro = '--';
    @track numeroConta;
    @track cpf;
    @track unidadeNegocio;

    @track tipoEnvioOptions;
    @track optionsAlteracao = [{label: 'Alteração modo de envio da fatura', value: 'Alteração  modo de envio da fatura'}];

    @track atualizarEmailOptions = [
        { label: 'Sim', value: true },
        { label: 'Não', value: false },
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.cmp2viafatura != true) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            console.log(error);
        }
    }

    navegarParaAlteracao(){
        this.handleBtnFechar();
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:"ContaFinanceira__c.AlteracaoDadosCadastrais"
            },
            state: {
                recordId: this.recordId
            }
        });
    }

    connectedCallback() { 
        this.showSpinner();
        getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.numeroConta = result.NumeroConta;
                this.cpf = result.CPF;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;  
                this.email = result.Email;
                this.emailAntigo = result.Email;
                this.numeroConta = result.NumeroConta;
                this.tipoConta = result.TipoConta;
                this.statusConta = result.StatusConta;
                this.telefone = result.Telefone;
                this.bairro = result.Bairro;
                this.cep = result.CEP;
                this.cidade = result.Cidade;
                this.complemento = result.Complemento;
                this.rua = result.Rua;
                this.estado = result.Estado;
                this.numero = result.Numero;
                this.celularSeguro = result.CelularSeguro;

                
                this.GetTiposEnvioFatura();
            } catch (error) {
                console.log('Erro catch() getContaFinanceira: '+ error);   
                this.showToast('Erro', 'Ouve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getContaFinanceira: '+ error.body.message);
            this.showToast('Erro', 'Ouve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }

    GetTiposEnvioFatura(){
        getTiposEnvioFatura({
            canal: this.canal,
            cpf: this.cpf,
            idEmpresa: this.unidadeNegocio
        }).then((result) => {
            if(result.StatusAPI == 'OK') {
                let opcoes = [];
                
                result.tiposEnvioFatura.forEach(item => {
                    let valueItem;
    
                    if (item == 1) {
                        valueItem = 'Correio';
                    } else if (item == 2) {
                        valueItem = 'E-mail';
                    } else if (item == 4) {
                        valueItem = 'APP e Site';
                    } else if (item == 8) {
                        valueItem = 'WhatsApp';
                    } else if (item == 16) {
                        valueItem = 'SMS';
                    }
                    opcoes.push(
                        {label: valueItem, value: valueItem, id: item}
                    );
                });
                this.tipoEnvioOptions = opcoes;
            }else{
                throw new Error('API Error');
            }
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro GetTiposEnvioFatura: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar os tipos de envios', 'error', true);
        });
    }

    UpdateEmailEnvioFatura(){
        updateEmailEnvioFatura({
            idEmpresa: this.unidadeNegocio, 
            sistema: this.sistema, 
            canal: this.canal, 
            area: this.area, 
            cpf: this.cpf, 
            numeroConta: this.numeroConta, 
            emailToUpdate: this.email
        }).then((result) => {
            if(result.StatusAPI == 'OK') {
                this.alteracaoCadastral = true;
                this.UpdateTipoEnvioFatura();
            }else{
                throw new Error('API Error');
            }
        }).catch(error => {
            console.log('Erro UpdateEmailEnvioFatura: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao atualizar E-mail de envio da fatura', 'error', true);
        });
    }

    UpdateTipoEnvioFatura(){
        updateTipoEnvioFatura({
            idEmpresa: this.unidadeNegocio, 
            sistema: this.sistema, 
            canal: this.canal, 
            area: this.area, 
            cpf: this.cpf, 
            numeroConta: this.numeroConta, 
            tipoEnvioFatura: this.tipoEnvioId,
            alteracaoCadastral: this.alteracaoCadastral
        }).then((result) => {
            if(result.StatusAPI == 'OK') {
                this.CriarCaso();
            }else{
                throw new Error('API Error');
            }
        }).catch(error => {
            console.log('Erro UpdateTipoEnvioFatura: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao atualizar o tipo de envio da fatura', 'error', true);
        });
    }

    CriarCaso(){
        criarCaso({
            contaFinanceiraId: this.recordId, 
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio, 
            origem: this.origemValue, 
            evento: this.evento, 
            tipoEnvio: this.tipoEnvioValue,
            canal: this.canalValue,
            cpf: this.cpf,
            idEmpresa: this.idEmpresa
        }).then((result) => {
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.pageTwo = false;
            this.pageTree = true;

            if(this.tipoEnvioId == 2 && this.atualizaEmailValue == true)
                this.AtualizaEmail();
            this.closeSpinner();
            
        }).catch(error => {
            console.log('Erro CriarCaso: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao Criar Caso', 'error', true);
        });
    }
    AtualizaEmail(){
        atualizaEmail({
            contaFinanceiraId: this.recordId, 
            emailToUpdate: this.email
        }).catch(error => {
            console.log('Erro AtualizaEmail: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao atualizar email', 'error', true);
        });
    }
    

//#region - Métodos Handle
    handleTipoEnvioChange(event) {
        this.tipoEnvioValue = event.target.value;
        this.novoModoEnvio = event.target.value;
        this.tipoEnvioId = event.target.options.find(option => option.value == event.detail.value).id;

        this.disableBtnSalvar = false;
        this.pagePhone = false;
        this.pageCorreio = false;
        this.pageApp = false;
        this.pageEmail = false;
        this.alertCelularSeguro = true;

        if(this.tipoEnvioId == 1){
            this.pageCorreio = true;
        }else if(this.tipoEnvioId == 2){
            this.pageEmail = true;
        }else if(this.tipoEnvioId == 4){
            this.pageApp = true;
        }else if(this.tipoEnvioId == 8 || this.tipoEnvioId == 16){
            this.pagePhone = true;
            if(this.celularSeguro != 'Sim'){
                this.disableBtnSalvar = true;
                this.infoCelularSeguro = true;
            }
        }
    }
    handleEmailChange(event) {
        this.email = event.target.value;
        this.disableBtnAtualizarEmail = false;
        if(this.email != this.emailAntigo){
            this.atualizaEmailValue = true;
            this.disableBtnAtualizarEmail = true;
        }
    }
    handleAtualizarEmailChange(event) {
        this.atualizaEmailValue = event.detail.value;
    }
    handleBtnSalvar() {
        if(this.pageOne){
            this.pageOne = false;
            this.pageTwo = true;
            this.disableBtnVoltar = false;
        }
    }
    handleBtnVoltar(){
        if(this.pageTwo){
            this.pageOne = true;
            this.pageTwo = false;
            this.disableBtnVoltar = true;
        }
    }
    handleBtnFechar(){
        this.closeQuickAction();
    }
    handleBtnFinalizar(){
        this.pageTwo = false;
        this.pageTree = true;
    }
    handleBtnFinalizar(){
        this.showSpinner();
        if(this.tipoEnvioId == 2 && this.atualizaEmailValue == true){
            this.UpdateEmailEnvioFatura();
        }else{
            this.UpdateTipoEnvioFatura();
        }
    }
    handleChangeOrigem(event){
        this.origemValue = event.target.value;
    }
    handleChangeCanal(event){
        this.canalValue = event.target.value;
        if(this.novoModoEnvio != null && this.evento != null){
            this.disableBtnFinalizar = false;
        }
    }
    handleTipoAlteracao(event){
        this.evento = event.target.value;
    }
    handleTipoAlterado(event){
        this.novoModoEnvio = event.target.value;
    }
    handleBtnIrCase(event){
        window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
    }
//#endregion

//#region - Métopdos Padrões
    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    closeQuickAction() {
        if (this.cmp2viafatura || this.cmpAlteracaoCadastral) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    
//#endregion
}