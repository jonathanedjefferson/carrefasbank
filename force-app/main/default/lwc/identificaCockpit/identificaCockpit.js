import { LightningElement, api } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';

import atualizaContaPorCPF from '@salesforce/apex/IdentificaCockpitController.atualizaContaPorCPF';
import identificaContaFinanceira from '@salesforce/apex/IdentificaCockpitController.identificaNumeroConta';

export default class IdentificaCockpit extends LightningElement {
    @api recordId; // Propriedade para armazenar o recordId
    @api objectApiName; // Propriedade para armazenar o nome do objeto

    connectedCallback(){
        if (this.objectApiName == 'Account') {
            this.Conta();
        }else{
            this.ContaFinanceira();
        }
    }

    Conta(){
        atualizaContaPorCPF({
            accountId: this.recordId,
            canal : 'Cockpit'
        }).then(result => {
            if(result != null){
                this.updateComponents();
            }
        }).catch( error => {
            console.log('Erro Conta - atualizaContaPorCPF: '+ error.body.message);
            console.dir(error);
        })
    }

    ContaFinanceira(){
        identificaContaFinanceira({
            contaId: this.recordId,
            canal : 'Cockpit'
        }).then(result => {
            if(result == 'ok'){
                this.updateComponents();
            }
        }).catch( error => {
            console.log('Erro - identifica: '+ error.body.message);
            console.dir(error);
        })
    }

    updateComponents(){
        this.dispatchEvent(new RefreshEvent());
    }
}