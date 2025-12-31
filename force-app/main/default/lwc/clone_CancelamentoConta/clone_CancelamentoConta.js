import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import CASE_OBJECT from '@salesforce/schema/Case';
import SITUACAO_SERVICOS_FIELD from '@salesforce/schema/Case.SituacaoSegurosServicos__c';
import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';
import criarCaso from '@salesforce/apex/BCSF_CancelamentoContaController.criarCaso';
import getlistStatusCancelamento from '@salesforce/apex/BCSF_CancelamentoContaController.getStatusCancelamentoConta';
import cancelamentoConta from '@salesforce/apex/BCSF_CancelamentoContaController.cancelamentoConta';
import updateContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.atualizarContaFinanceira';
import getInfoStatus from '@salesforce/apex/BCSF_BloqueioCartaoController.getInfoStatus';

export default class clone_CancelamentoConta extends LightningElement {

     //#region Variaveis 
     spinner = false;
     logoTipo;
     optionsStatus = [];
     optionsOrigem;
     numProtocolo;
     caseId;
     @api recordId;
     @track statusContaInfo = 'Informação indisponível';
     @track valueAssunto = 'Cancelamento de cartão de crédito';
     @track buttonPross = true;
     @track newValueStatus = null;
     @track showButtonProsseguir = true;
     @track disableButton = true;
     @track stepOne = true;
     @track stepTwo = false;
     @track showCardPrincipal = true;
     @track stepThree = false;
     @track valueStatus = null;
     @track valueMotivo = null;
     @track valueEvento = null;
     @track valueOrigem = null;
     @track valueCanal = null;
     @track valueSituacaoServicos = null;
     @track currentStep = '1';
     @track nome = '--';
     @track numeroConta = '--';
     @track statusConta = '--';
     @track tipoConta = '--';
     @track cpf = '--';
     @track dataNascimento = '--';
     @track hasErrorSteps = false;
     @track hasErrorSteps = false;
     @track unidadeNegocio = null;
     @track accountId = null;
     @track UserId = USER_ID;
     @track canal = 'cockpit';
     @track Area = null;
     //#endregion
 
     //#region wire's
 
     @wire(CurrentPageReference)
     getStateParameters(currentPageReference) {
         if (currentPageReference) {
             this.recordId = currentPageReference.state.recordId;
         }
     }
 
     @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
     currentUserInfo({ error, data }) {
         if (data) {
             this.Area = data.fields.AreaPrincipal__c.value;
         } else if (error) {
             this.error = error;
         }
     }
     @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
     CaseInfo;
 
     @wire(getPicklistValues, { recordTypeId: '$CaseInfo.data.defaultRecordTypeId', fieldApiName: SITUACAO_SERVICOS_FIELD })
     setPicklistOptionSituacaoServicos({ error, data }) {
         if (data) {
             this.optionSituacaoServicos = data.values;
         } else if (error) {
             console.log(error);
         }
     }
 
     //#endregion
 
     connectedCallback() {
 
         getContaFinanceira({ contaFinanceiraId: 'a028B000001OYdWQAW' })
             .then(result => {
             
                 this.nome = result.Nome;
                 this.numeroConta = result.NumeroConta;
                 this.cpf = result.CPF;
                 this.dataNascimento = result.DataNascimento;
                 this.unidadeNegocio = result.TipoConta;
                 this.accountId = result.AccountId;
                 this.statusConta = result.StatusConta;
         
 
                 if (result.TipoConta == "1") {
                     this.tipoConta = 'Carrefour';
                     this.logoTipo = LogoCarrefour;
                 } else if (result.TipoConta == "2") {
                     this.tipoConta = 'Atacadão';
                     this.logoTipo = LogoAtacadao;
                 } else if (result.TipoConta == "6") {
                     this.tipoConta = "Sam's Club";
                     this.logoTipo = LogoSamsClub;
                 }
                     this.carregarListaStatus();
                     this.GetStatusInfo(result.StatusConta);      
             })
             .catch(error => {
                 console.log('Erro getContaFinanceira: ' + error.body.message);
                 this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
             });
         ;
     }
 
     //#region métodos handle
     handleChangeStatusCancelamento(event) {
         this.valueStatus = event.detail.value;
         this.newValueStatus = event.detail.value.split(' - ')[0];
         this.verifyDesable();
     }
     handleChangeMotivoCancelamento(event) {
         this.valueMotivo = event.detail.value;
         this.verifyDesable();
     }
     handleChangeEvento(event) {
         this.valueEvento = event.detail.value;
         this.verifyDesable();
     }
     handleChangeOrigem(event) {
         this.valueOrigem = event.detail.value;
         this.verifyDesable();
     }
     handleChangeCanal(event) {
         this.valueCanal = event.detail.value;
         this.verifyDesable();
     }
     
     handleSituacaoServicos(event) {
         this.valueSituacaoServicos = event.detail.value;
         this.verifyDesable();
     }
     handleProsseguir(event) {
         if(this.stepOne == true){
             this.currentStep = '2';
             this.stepOne = false;
             this.stepTwo = true;
             this.disableButton = false;
             this.showButtonProsseguir = false;
             this.showCardPrincipal = false;
         }else if(this.stepTwo == true){
             this.currentStep = '3';
             this.stepTwo = false;
             this.stepThree = true;
             this.disableButton = true;
             
         }
 
 
     }
     handleButtonVoltar(event) {
         if(this.stepTwo == true){
             this.currentStep = '1';
             this.disableButton = true;
             this.stepOne = true;
             this.stepTwo = false;
             this.showButtonProsseguir = true;
             this.showCardPrincipal = true;
             
         }else if(this.stepThree == true){
             this.currentStep = '2';
             this.stepTwo = true;
             this.stepThree = false;
             this.showCardPrincipal = true;
             this.disableButton = false;
         }
 
 
     }
     handleConfirmaCancelamento(event) {
         this.CancelamentoConta();
     }
     //#endregion
 
     //#region métodos Toast, Spinner e verify
     showSpinner() {
         this.spinner = false;
     }
     closeSpinner() {
         this.spinner = false;
     }
     verifyDesable() {
         if (this.valueStatus == null || this.valueStatus == undefined ||
             this.valueMotivo == null || this.valueMotivo == undefined ||
             this.valueOrigem == null || this.valueOrigem == undefined ||
             this.valueCanal == null || this.valueCanal == undefined ||
             this.valueEvento == null || this.valueEvento == undefined) {
 
             this.buttonPross = true;
         } else {
             this.buttonPross = false;
         }
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
         this.dispatchEvent(new CloseActionScreenEvent());
     }
     //#endregion
 
     carregarListaStatus() {
         this.showSpinner();
         getlistStatusCancelamento({
             canal: this.canal,
             area: this.Area
         }).then(result => {
             if (result.status.length > 0) {
                 let opcoes = [];
                 result.status.forEach(item => {
                     opcoes.push(
                         { label: item.nome + ' - ' + item.descricao, value: item.nome + ' - ' + item.descricao }
                     );
                 });
                 this.optionsStatus = opcoes;
                 this.closeSpinner();
             }else{
                 this.showToast('Aviso!', 'Erro ao buscar lista de status para Cancelar!', 'error', true);
             }
         }).catch(error => {
             console.log('Erro listStatusBloqueioConta: ' + error.body.message);
             this.showToast('Erro', 'Houve um erro ao buscar lista de status para Cancelar!', 'error', true);
         });
     }
 
     GetStatusInfo(status){
         getInfoStatus({
             status: status
         }).then(result => { 
             this.statusContaInfo = result.Descricao__c;
         }).catch(error => {
             console.log('Erro getInfoStatus: '+ error.body.message);
         });
     }
 
     CriarCaso() {
         this.showSpinner();
 
         criarCaso({
             origem: this.valueOrigem,
             contaFinanceiraId: this.recordId,
             accountId: this.accountId,
             statusCancelamento: this.valueStatus,
             requisitoCancelamento: this.valueMotivo,
             unidadeNegocio: this.unidadeNegocio,
             canal: this.valueCanal,
             evento: this.valueEvento,
             assunto: this.valueAssunto
         }).then(result => {
             this.numProtocolo = result.CaseNumber;
             this.caseId = result.Id;
             this.currentStep = '4';
             this.stepTwo = false;
             this.stepThree = true;
             this.disableButton = true;
             this.showCardPrincipal = false;
             this.closeSpinner();
         }).catch(error => {
             console.log('Erro createCase: ' + error.body.message);
             this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
         });
     }
     UpdateContaFinanceira(){
         this.showSpinner();
 
         updateContaFinanceira({
             contaFinanceiraId: this.recordId,
             novoStatus: this.newValueStatus
         }).then(() => {
             this.CriarCaso();
         }).catch(error => {
             console.log('Erro updateAtivo: '+ error.body.message);
             this.showToast('Erro', 'Houve um erro ao atualizar Conta Financeira!', 'error', true);
         });
     }
     CancelamentoConta() {
         this.showSpinner();
         
         cancelamentoConta({
             numeroConta: this.numeroConta,
             novoStatus: this.newValueStatus,
             idEmpresa: this.unidadeNegocio,
             cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
             sistema: this.canal,
             canal: this.canal,
             area: this.Area
         }).then(result => {
             if (result) {
                 this.UpdateContaFinanceira();
             } else {
                 this.showToast('Erro', 'Não foi possivel bloquear o Conta!', 'error', true);
             }
 
         }).catch(error => {
             console.log('Erro bloquearCartao: ' + error.body.message);
             this.showToast('Erro', 'Houve um erro ao bloquear a Conta!', 'error', true);
         })
     }
     irCase() {
         window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
     }
 
}