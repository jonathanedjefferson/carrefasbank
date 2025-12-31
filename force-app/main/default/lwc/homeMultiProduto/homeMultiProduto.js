import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
const FIELDS = [
    'User.Profile.Name'
];
import getContasFinanceiras from '@salesforce/apex/HomeMultiProdutoController.getContasFinanceiras';

const COLUMNS_CARTAO_CREDITO = [
    { label: 'Número do Cartão', fieldName: 'linkContaFinanceira', type: 'url', sortable: true, typeAttributes: {label:{ fieldName: 'Name'}}},
    { label: 'Número da Conta', fieldName: 'NumeroConta__c' },
    { label: 'Status da Conta', fieldName: 'StatusConta__c' },
    { label: 'Adesão', fieldName: 'Adesao', type: 'customImage'}
];

const COLUMNS_CONSIGNADO = [
    { label: 'Contrato', fieldName: 'linkContaFinanceira', type: 'url', sortable: true, typeAttributes: {label:{ fieldName: 'NumeroContrato'}}},
    { label: 'Valor (R$)', fieldName: 'amount'},
    { label: 'Data de início', fieldName: 'dataInicio'},
    { label: 'Adesão', fieldName: 'Adesao', type: 'customImage'}
];

const COLUMNS_CASHBACK = [
    { label: 'Número de Contrato', fieldName: 'linkContaFinanceira', type: 'url', sortable: true, typeAttributes: {label:{ fieldName: 'NumeroContrato'}}},
    { label: 'Status do Contrato', fieldName: 'statusContrato'}
];

const COLUMNS_CONTA_DIGITAL = [
    { label: 'Número da conta', fieldName: 'linkContaFinanceira', type: 'url', sortable: true, typeAttributes: {label:{ fieldName: 'NumeroConta__c'}}},
    { label: 'Status da contao', fieldName: 'StatusContaDigital__c'}
];

const LOGO_TIPOS =[
    { bu: '1', value: '/resource/LogoCarrefour'},
    { bu: '2', value: '/resource/LogoAtacadao'},
    { bu: '6', value: '/resource/LogoSamsClub'}
];


export default class HomeMultiProduto extends LightningElement {
    @api recordId;
    spinner = true;
    
    columnsCartaoCredito = COLUMNS_CARTAO_CREDITO;
    columnsConsignado = COLUMNS_CONSIGNADO;
    columnsCashback = COLUMNS_CASHBACK;
    columnsContaDigital = COLUMNS_CONTA_DIGITAL;
    logoTipos = LOGO_TIPOS;

    @track listCartoesCredito;
    @track listConsignado;
    @track listCashback;
    @track listContaDigital;
    @track showConsignado = true;
    @track showCartaoCredito = true;
    @track showCashback = true;
    @track showContaDigital = true;

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS}) 
    currentUserInfo({error, data}) {
        if (data) {
            try {
                let perfil = data.fields.Profile.value.fields.Name.value;
                if (perfil.toUpperCase().includes('CONSIGNADO')) {
                    this.showConsignado = true;
                    this.showCartaoCredito = false;
                    this.showCashback = false;
                    this.showContaDigital = false;
                }
            } catch (error) {
                console.log('ERROR Catch @Wire: ' + error);
            }
        } else if (error) {
            this.error = error ;
            console.error('ERROR @Wire: ', error);
        }
    }

    async connectedCallback(){
        this.showSpinner();
        await this.GetContasFinanceiras();
        this.closeSpinner();
    }

    async GetContasFinanceiras(){
        await getContasFinanceiras({
            AccountId: this.recordId
        }).then(result=>{
            try {
                let credito = [];
                let consignado = [];
                let cashback = [];
                let contaDigital = [];

                result.forEach(item => {
                    let data = item.DataInicioConta__c != null? item.DataInicioConta__c.split('-') : '--';
                    item.dataInicio = data != '--' ? data[2] + '/' + data[1] + '/' + data[0] : '--';
                    item.amount = item.ValorTotal__c != null ? this.formatMoeda(item.ValorTotal__c) : '--';
                    item.linkContaFinanceira = '/lightning/r/ContaFinanceira__c/'+ item.Id +'/view';
                    item.NumeroContrato = item.NumeroContrato__c;
 
                    if(item.CartaoTransversal__c === true){
                        item.Adesao = '/resource/LogoTransversal';
                    }else{
                        this.logoTipos.forEach(element => {
                            if (element.bu == item.UnidadeNegocio__c) {
                                item.Adesao = element.value;
                            }
                        });
                    } 
                    
                    if (item.RecordTypeId == null || item.RecordTypeId == undefined || item.RecordType.DeveloperName == 'BCSF_RT_CFI_ContaFinanceira') {
                        credito.push(item);
                    } else if (item.RecordType.DeveloperName == 'BCSFConsignado') {
                        consignado.push(item);
                    } else if (item.RecordType.DeveloperName == 'Comprou_Voltou') {
                        if (item.StatusContrato__c === 'BloqueioDefinitivo'){
                            item.statusContrato = 'Bloqueio Definitivo';
                        } else if (item.StatusContrato__c === 'BloqueioTemporario'){
                            item.statusContrato = 'Bloqueio Temporário';
                        }
                        else {
                            item.statusContrato = item.StatusContrato__c;
                        }
                        cashback.push(item);
                    }else if (item.RecordType.DeveloperName == 'BCSF_RT_CFI_ContaDigital') {
                        contaDigital.push(item);
                    }                             
                });

                this.listCartoesCredito = credito;
                this.listConsignado = consignado;
                this.listCashback = cashback;
                this.listContaDigital = contaDigital;
            } catch (error) {
                console.log('Erro catch() getContasFinanceiras: '+ error);   
                this.showToast('Ocorreu um erro ao buscar Contas Financeiras', 'Por favor, tente mais tarde!', 'error');
            } 
        }).catch(error=>{
            this.closeSpinner();
            console.log('getContasFinanceiras ERROR ' + error.body.message);
            this.showToast('Ocorreu um erro ao buscar Contas Financeiras', 'Por favor, tente mais tarde!', 'error');
        });
    }

    formatMoeda(valor){
        let amount;
        if (!valor.toString().slice(-3).includes('.')){
            amount = 'R$ ' + valor.toString() + ',00';
        }else if (valor.toString().slice(-2).includes('.')){
            amount = 'R$ ' + valor.toString().replace('.', ',') + '0';
        }else {
            amount = 'R$ ' + valor.toString();
        }
        return amount;
    }

    refreshComponent(){
        this.connectedCallback();
    }

    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}