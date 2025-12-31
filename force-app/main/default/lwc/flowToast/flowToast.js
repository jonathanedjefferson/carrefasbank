import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FlowToast extends LightningElement {

    @api mode;
    @api variant;
    @api message;
    @api title

    connectedCallback(){
        this.showToastMessage();
    }

    showToastMessage() {
        const toast = new ShowToastEvent({
            title: this.title,
            mode: this.mode,
            variant: this.variant,
            message: this.message
        });
        this.dispatchEvent(toast);
    }

}