import { LightningElement, api, track, wire } from 'lwc'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ASSUNTO_FIELD from '@salesforce/schema/Case.AssuntoAtendimento__r.CamposDefinidos__c';
import getFieldSet from '@salesforce/apex/bcsf_CaseFieldSetsController.getFieldSet'
export default class FieldsetsCase extends LightningElement {
    @api recordId;
    @api objectApiName = 'Case';

    fields;
    assuntoAtendimento;
    showComponent = false;

    @wire(getRecord, { recordId: '$recordId', fields: [ASSUNTO_FIELD] })
    wiredAccount({ error, data }) {

        console.log('recordId: ', this.recordId);
        if (data) {

            this.assuntoAtendimento = getFieldValue(data, ASSUNTO_FIELD);

            if (this.assuntoAtendimento != null) {
                this.showComponent = true;
                this.getFieldSet();
            }
        } else {
            console.log('As informações de AssuntoAtendimento não foram encontradas ');
        }
    }

    getFieldSet() {
        getFieldSet({ fieldSetName: this.assuntoAtendimento })
            .then(result => {
                this.fields = result;
            })
            .catch(error => {
                this.showComponent = false;
                console.log('Ocorreu um erro no getFieldSet: ' + JSON.stringify(error));
            })
    }

    handleSuccess(event) {
        this.showNotification('Sucesso', 'As informações adicionais foram salvas no caso.', 'success')
    }

    showNotification(title, msg, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        })
        this.dispatchEvent(evt);
    }
}