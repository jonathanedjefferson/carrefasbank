import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import NAME_FIELD from '@salesforce/schema/Lead.LastName';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import STATUS_FIELD from '@salesforce/schema/Lead.Status';

export default class LeadForm extends LightningElement {
    @track name = '';
    @track phone = '';
    @track status = '';

    // opções de status (exemplo, ajuste conforme seu org)
    get statusOptions() {
        return [
            { label: 'Novo', value: 'New' },
            { label: 'Trabalhando', value: 'Working' },
            { label: 'Convertido', value: 'Converted' },
            { label: 'Não Qualificado', value: 'Unqualified' }
        ];
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        if (field === 'Name') {
            this.name = event.target.value;
        } else if (field === 'Phone') {
            this.phone = event.target.value;
        } else if (field === 'Status') {
            this.status = event.target.value;
        }
    }

    handleSave() {
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.name;
        fields[PHONE_FIELD.fieldApiName] = this.phone;
        fields[STATUS_FIELD.fieldApiName] = this.status;

        const recordInput = { apiName: LEAD_OBJECT.objectApiName, fields };

        createRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: 'Lead criado com sucesso!',
                        variant: 'success'
                    })
                );
                this.name = '';
                this.phone = '';
                this.status = '';
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro ao criar Lead',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}