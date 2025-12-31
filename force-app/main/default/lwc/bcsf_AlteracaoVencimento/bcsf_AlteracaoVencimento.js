import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';

import getContaFinanceira from '@salesforce/apex/AlteracaoVencimentoController.getContaFinanceira';
import tratarAsset from '@salesforce/apex/AlteracaoVencimentoController.tratarAsset';
import getDataVencimentoFatura from '@salesforce/apex/AlteracaoVencimentoController.getDataVencimentoFatura';
import getDataVencimentoAtualizadaFatura from '@salesforce/apex/AlteracaoVencimentoController.getDataVencimentoAtualizadaFatura';
import alterarVencimento from '@salesforce/apex/AlteracaoVencimentoController.alterarVencimento';
import criarCaso from '@salesforce/apex/AlteracaoVencimentoController.criarCaso';

export default class Bcsf_AlteracaoVencimento extends LightningElement {
    caseId = '--';
    @track dateToday = this.formatDate(new Date());

    @track spinner = false;
    @track canal = 'cockpit';
    @track area = '';
    @track podeCriarCaso = false;
    @track step01 = true;
    @track step02 = false;
    @track step03 = false;
    @track showPreviewIcon = true;

    @track buttonAvancar = 'Prosseguir';
    @track disableButtonAvancar = true;
    @track disableButtonVoltar = false;
    @track showSelecaoDatas = true;
    @track msgAlert = 'Lembre-se de que, após a efetuação, só será possível modificar a data novamente após um período de 6 meses.';
    @track numeroProtocolo = '--';

    @track cpf = '--';
    @track nome = '--';
    @track dataNascimento = '--';
    @track statusConta = '--';
    @track numeroConta = '--';
    @track celularSeguro = '--';
    @track produto = '--';
    @track vencimentoAtual = '--';
    @track statusVencimento = '--';
    @track dataUltimaAlteracaoVencimento = '--';
    @track tipoConta = '--';
    @track accountId = '--';
    @track unidadeNegocio;
    @track listDatasVencimento01 = [];
    @track listDatasVencimento02 = [];

    @track novoDiaVencimento = '--';
    @track novaDataVencimento = '--';
    @track novaDataFechamento = '--';
    @track valueOrigem = null;
    @track valueCanal = null;
    
    //#region INICIALIZAÇÃO
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    } 

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error ;
        }
    }
    
    async connectedCallback() { 
        this.showSpinner();
        await this.getDadosContaFinanceira();
        await this.getDadosAsset();
        await this.getDadosVencimentoFatura();
        this.closeSpinner();
    }
    //#endregion

    //#region FINALIZAÇÃO
    async finalizarAlteracao(){
        this.showSpinner();
        await this.alterarDataVencimento();
        if (this.podeCriarCaso) {
            await this.criarCaso();
        }
        this.closeSpinner();
    }

    async criarCaso(){
        await criarCaso({
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            origem: this.valueOrigem,
            canal: this.valueCanal
        }).then(result => {
            if (result != null) {
                this.numeroProtocolo = result.CaseNumber
                this.caseId = result.Id;
            }
        }).catch(error => {
            console.log('Erro criarCaso: ');
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao criar protocolo!', 'error', true);
        });
    }

    irCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }
    //#endregion

    //#region BUTTONS / HANDLES
    handleButtonVoltar(){
        if (this.step01) {
            this.closeQuickAction();
        }else if (this.step02) {
            this.step01 = true;
            this.step02 = false;
            
            this.buttonAvancar = 'Prosseguir';
        }else if (this.step03) {
            this.step01 = false;
            this.step02 = true;
            this.step03 = false;

            this.verifyDesable();
        }
    }

    async handleProsseguir(){
        if (this.step01) {
            this.step01 = false;
            this.step02 = true;

            this.buttonAvancar = 'Finalizar';
            this.verifyDesable();
        }else if (this.step02) {
            await this.finalizarAlteracao();

            this.step01 = false;
            this.step02 = false;
            this.step03 = true;

            this.buttonAvancar = 'Ir para o Caso';
            this.disableButtonVoltar = true;
        }else if (this.step03) {
            this.irCaso();
        }
    }

    handleChangeOrigem(event) {
        this.valueOrigem = event.detail.value;
        this.valueCanal = null;
        this.verifyDesable();
    }

    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.verifyDesable();
    }

    handleChangeDataVencimento(event){
        this.novoDiaVencimento = event.target.value;
        this.disableButtonAvancar = false;
    }

    async handleGetDataVencimentoAtualizada(event){
        this.showSpinner();
        await this.getDataVencimentoAtualizada();
        this.closeSpinner();
    }
    //#endregion

    //#region QUERYS
    async getDadosContaFinanceira(){
        await getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.nome = result.Nome;
                this.cpf = result.CPF;
                this.dataNascimento = result.DataNascimento;
                this.statusConta = result.StatusConta;
                this.numeroConta = result.NumeroConta;
                this.celularSeguro = result.CelularSeguro;
                this.tipoConta = result.TipoConta;
                this.accountId = result.AccountId;
                this.unidadeNegocio = result.UnidadeNegocio;
                if(this.celularSeguro == 'Não possui Celular Seguro'){
                    this.possuiCelularSeguro = false;
                }
            } catch (error) {
                console.log('Erro catch() getContaFinanceira: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getContaFinanceira: '+ error);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }


    async getDadosAsset(){
        await tratarAsset({
            contaFinanceiraId: this.recordId
        }).then(resultAsset => {
            try {
                this.produto = resultAsset.ProductName;
            } catch (error) {
                console.log('Erro catch() tratarAsset: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro tratarAsset: '+ error);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }
    //#endregion

    //#region CHAMADAS DE API
    async getDadosVencimentoFatura(){
        await getDataVencimentoFatura({
            cpf: this.cpf.replaceAll('.','').replaceAll('-',''),
            numeroConta: this.numeroConta, 
            canal: this.canal, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            try {
                if (result.StatusAPI == 'CLIENTE SEM PERMISSÃO') {
                    this.showToast('', 'Cliente sem permissão para realizar a ação.', 'error', true);
                }
                if (result.UltimaAlteracaoMenos6Meses) {
                    this.msgAlert = 'Infelizmente não será possível modificar a data neste momento. Estará disponível a partir do dia ' + result.dataDisponivelAlteracao + '.';
                    this.showSelecaoDatas = false;
                }
                if (result.StatusAPI == 'OK') {
                    if (result.listaDiasVencimento.length != 0) {
                        let cont = 0;
                        result.listaDiasVencimento.forEach(item => {
                            if(cont < 8){
                                this.listDatasVencimento01.push(item);
                            }else{
                                this.listDatasVencimento02.push(item);
                            }
                            cont++;
                        });
                    }                        
                    this.vencimentoAtual = result.diaVencimento;
                    this.statusVencimento = result.alteracaoPermitida;
                    this.dataUltimaAlteracaoVencimento = result.dataUltimaAlteracao;
                }else{
                    console.log('Erro API getDataVencimentoFatura');   
                    this.showToast('Erro API', 'Houve um erro ao buscar informações sobre os dados de Fatura!', 'error', true);
                }

            } catch (error) {
                console.log('Erro catch() getDataVencimentoFatura: '+ error);   
                this.showToast('Erro API', 'Houve um erro ao buscar informações sobre os dados de Fatura!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getDataVencimentoFatura: '+ error.body.message);
            this.showToast('Erro API', 'Houve um erro ao buscar informações sobre os dados de Fatura!', 'error', true);
        });
    }

    async alterarDataVencimento(){
        await alterarVencimento({
            cpf: this.cpf.replaceAll('.','').replaceAll('-',''), 
            numeroConta: this.numeroConta, 
            canal: this.canal, 
            area: this.area, 
            sistema: this.area, 
            idEmpresa: this.unidadeNegocio, 
            novoDiaVencimento: this.novoDiaVencimento
        }).then(result => {
            if (result.StatusAPI == 'OK') {
                this.podeCriarCaso = true;
            } else {
                this.showToast('Erro API', 'Houve um comportamento inesperado no sistema, tente novamente!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro alterarVencimento: '+ error.body.message);
            this.showToast('Erro API', 'Houve um comportamento inesperado no sistema, tente novamente!', 'error', true);
        })
    }

    async getDataVencimentoAtualizada(){
        await getDataVencimentoAtualizadaFatura({
            cpf: this.cpf.replaceAll('.','').replaceAll('-',''),
            numeroConta: this.numeroConta, 
            canal: this.canal, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
                if (result.StatusAPI == 'OK') {
                    this.novaDataVencimento = result.dataVencimento;
                    this.novaDataFechamento = result.dataFechamento;
                    this.showPreviewIcon = false;
                } else {
                    console.log('Erro API getDataVencimentoAtualizadaFatura');   
                    this.showToast('Erro API', 'Houve um erro ao buscar informações sobre os dados de Fatura!', 'error', true);
                }
        }).catch(error => {
            console.log('Erro getDataVencimentoAtualizadaFatura: '+ error.body.message);
            this.showToast('Erro API', 'Houve um erro ao buscar informações sobre os dados de Fatura!', 'error', true);
        });
    }
    //#endregion

    //#region INTERAÇÕES COM O USUÁRIO
    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
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
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    verifyDesable(){
        if (this.valueOrigem == null || this.valueOrigem == undefined ||
            this.valueCanal == null || this.valueCanal == undefined) {
            
                this.disableButtonAvancar = true;
        }else{
            this.disableButtonAvancar = false;
        }
    }
    //#endregion

    formatDate(data){
        var dia = data.getDate();
        var mes = data.getMonth() + 1;
        var ano = data.getFullYear();

        if(dia < 10) dia  = '0' + dia;
        if(mes < 10) mes  = '0' + mes;
        
        return dia + '/' + mes + '/' + ano;
    }
}