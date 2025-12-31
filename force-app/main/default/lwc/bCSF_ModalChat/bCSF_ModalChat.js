import { LightningElement, track, api } from 'lwc';
import ASSUNTO_FIELD from '@salesforce/schema/Case.Assunto__c';
import EVENTO_FIELD from '@salesforce/schema/Case.Evento__c';

export default class ModalPopupLWC extends LightningElement {
    //@api recordId;
    @api objectApiName = 'Case';

    _recordId;

    @api set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    assuntoField = ASSUNTO_FIELD;
    eventoField = EVENTO_FIELD;

    @track isModalOpen = false;

    openModal() {
        this.isModalOpen = true;
        console.log('ID: ' + this.recordId);
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
}