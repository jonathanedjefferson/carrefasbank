import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import melhorDiaCompra from '@salesforce/apex/MelhorDiaCompraCockpitController.getMelhorDiaCompra';
import dataUltimaFatura from '@salesforce/apex/MelhorDiaCompraCockpitController.getDataULtimaFatura';
import getContaFinanceira from '@salesforce/apex/MelhorDiaCompraCockpitController.getInfoContaFinanceira';

export default class Bcsf_MelhorDiaCompra extends LightningElement {

    @api recordId;

    spinner = true;

    @track showCardPrincipal = true;
    @track numeroConta;
    @track cpfCliente;
    @track IdEmpresa;
    @track name;
    @track canal;
    @track data = '--/----';
    @track dia = '--';
    @track resultadoFormatado = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback(){
        getContaFinanceira({
            IdCF: this.recordId
        }).then(result =>{
            this.numeroConta = result.NumeroConta__c;
            this.cpfCliente = result.NomeCliente__r.CPF__c;
            this.name = result.NomeCliente__r.FirstName;
            this.unidadeNegocio = result.UnidadeNegocio__c;

            this.MelhorDiaCompra();
        }).catch(error=>{
            this.showToast('Erro', 'Erro getContaFinanceira', 'error', true);
            console.log('Error getContaFinanceira: ' + error.body.message);
        });
    }

    
    MelhorDiaCompra(){
        melhorDiaCompra({
            numeroConta: this.numeroConta, 
            cpf: this.cpfCliente, 
            unidade: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result =>{
            if (result != 'ERROR'){
                this.DataUltimaFatura();
                this.dia = result;
            }else{
                this.showToast('Erro', 'Erro ao verificar o melhor dia de compra', 'error', true);
            }
        }).catch(error =>{
            this.showToast('Erro', 'Erro ao verificar o melhor dia de compra', 'error', true);
            console.log('Error melhorDiaCompra: ' + error.body.message);
        });
    }

    DataUltimaFatura(){
        dataUltimaFatura({
            numeroConta: this.numeroConta, 
            cpf: this.cpfCliente, 
            unidade: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result =>{
            if(result != null){
                let dataFormatada = new Date(result.dataVencimento);
                let mesFormatado = dataFormatada.getMonth() + 1; 
                let anoFormatado = dataFormatada.getFullYear();
                let resultadoFormatado = `${mesFormatado.toString().padStart(2, '0')}/${anoFormatado}`;
                if(resultadoFormatado == '01/1'){
                    this.data = 'Este cliente não possui fatura fechada';
                }else{
                    this.data = resultadoFormatado;
                }
                this.spinner = false;
            }else{
                this.showToast('Erro', 'Erro ao verificar a última fatura fechada', 'error', true);
            }
        }).catch(error =>{
            this.showToast('Erro', 'Erro ao verificar a última fatura fechada', 'error', true);
            console.log('Error dataUltimaFatura: ' + error.body.message);
        });
    }

    showToast(titulo, mensagem, variante, closeModal, mode = 'dismissable') {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    showSpinner(){
        this.spinner = true;
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    
}