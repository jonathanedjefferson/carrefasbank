import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id'; 
import USER_DRT from '@salesforce/schema/User.DRT__c';

import getContaFinanceira from '@salesforce/apex/BlindagemCPFController.obterContaFinanceira';
import getContaCliente from '@salesforce/apex/BlindagemCPFController.obterContaCliente';
import removerCliente from '@salesforce/apex/BlindagemCPFController.removerCliente';
import obterClienteBlindado from '@salesforce/apex/BlindagemCPFController.obterCliente'

export default class Bcsf_BlindagemCPFRemover extends LightningElement {

    @track recordId;
    @track drtUser;
    @track lblBtnVoltar = 'Cancelar';
    @track lblBtnAvancar = 'Remover blindagem';
    @track dadosCliente = {};
    @track spinner;
    @track dadosBlindagem = {
        tipo : '-', 
        motivo: '-'
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_DRT] })
    getUserRecord({ error, data }) {
        if (data) {
            this.drtUser = data.fields.DRT__c.value;
        } else if (error) {
            this.logError('getUserRecord', error);
        }
    }

    connectedCallback(){
        this.carregarDados();
    }

    async carregarDados(){
        this.showSpinner();
        if (this.recordId.startsWith("001")) {
            await this.obterContaCliente();
        } else {
            await this.obterContaFinanceira();
        }
        this.closeSpinner();
    }

    async obterContaFinanceira(){
        await getContaFinanceira({ 
            recordId: this.recordId 
        })
        .then(result => {
            this.dadosCliente = {
                cpf: result.CPF,
                unidadeNegocio: result.UnidadeNegocio,
                titularConta: result.Nome
            }

            this.obterDadosBlindagem(result.CPF);
        })
        .catch(error => {
            this.showToast('Erro ao obter conta financeira', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
            this.logError('obeterContaFinanceira', error);
        });
    }

    async obterContaCliente(){
        await getContaCliente({ 
            recordId: this.recordId 
        })
        .then(result => {
            this.dadosCliente = {
                cpf: this.formatarCPF(result.CPF__c),
                titularConta: result.Name
            }

            this.obterDadosBlindagem(result.CPF__c);
        })
        .catch(error => {
            this.showToast('Erro ao obter conta cliente', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
            this.logError('obterContaCliente', error);
        });
    }

    obterDadosBlindagem(cpf) {
        let cpfFormated = this.limparCPF(cpf);
        obterClienteBlindado({
            cpfCliente: cpfFormated,
            canal: 'Cockpit'
        })
        .then(resp => {
            this.dadosBlindagem = {
                tipo: resp.blindagem == 'Simples' ? 'BLINDAGEM SIMPLES' : 'BLINDAGEM FULL',
                motivo: resp.descricao ? resp.descricao.toUpperCase() : ''
            }
        })
        .catch(error => {
            this.showToast('Erro ao obter dados da blindagem', 'Ocorreu um erro inesperado ao obter dados da blindagem!', 'error');
            this.logError('obterClienteBlindado', error);
        });
    }

    RemoverCliente(){
        this.showSpinner();
        const cliente = {
            cpf: this.dadosCliente.cpf.replace(/\D/g, ''),
            usuario: this.drtUser,
            siglaUnidadeNegocio: this.dadosCliente.unidadeNegocio
        };

        removerCliente({ 
            cliente: cliente, 
            canal: 'Cockpit' 
        }).then(result => {
            if (result.statusAPI === 'OK') {
                this.showToast('Sucesso', 'Blindagem de CPF removida com sucesso!', 'success');
                this.closeQuickAction();
            } else {
                this.showToast('Erro', 'Falha ao remover blindagem cliente. Verifique os dados ou tente novamente.', 'error');
                this.closeSpinner();
            }
        })
        .catch(error => {
            this.showToast('Erro', 'Erro inesperado na importação.', 'error', true);
            console.error(error);
        });
    }

    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent())
    }

    formatarCPF(cpf) {
        return cpf ? cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4") : '';
    }

    limparCPF(cpf) {
        return cpf ? cpf.replace(/\D/g, '') : '';
    }

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'Bcsf_cmp_CreditoPessoalDadosBancarios'); 
            console.error('metodo => ', metodo); 
            console.error('erro => ', error);  
            if(error.body){
                console.error('error.body.exceptionType => ', error.body.exceptionType);
                console.error('error.body.message => ', error.body.message);
                console.error('error.body.stackTrace => ', error.body.stackTrace);
            }else{
                console.error('error.name => ' + error.name );
                console.error('error.message => ' + error.message );
                console.error('error.stack => ' + error.stack );
            }
            
        }
    }

    showToast(title, message, variant, close = false) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode: 'dismissable'
            })
        );

        if(close){
            this.spinner = false;
        }
    }
}