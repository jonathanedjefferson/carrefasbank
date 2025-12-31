import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bcsf_cmp_CreditoPessoalSeguro extends LightningElement {

    /**************************************************
    ***           ESTADOS DE TELA                   ***
    ***************************************************/

    @track spinner;

    /**************************************************
    ***           REATIVOS                          ***
    ***************************************************/


    connectedCallback(){
        
    }

    handleVoltar(){
        this.closeQuickAction();
    }

    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeQuickAction() {   
        this.dispatchEvent(new CustomEvent('closemodal'))
    }

}