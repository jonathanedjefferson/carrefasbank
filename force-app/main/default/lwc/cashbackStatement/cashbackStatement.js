import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CPF_BANCO_FIELD from "@salesforce/schema/ContaFinanceira__c.CPFBanco__c";
import STATUS_CONTRATO_FIELD from "@salesforce/schema/ContaFinanceira__c.StatusContrato__c";

export default class CashbackStatement extends LightningElement {
    @api recordId;
    pushedNotification = false;

    @wire(CurrentPageReference)
    getCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: [CPF_BANCO_FIELD, STATUS_CONTRATO_FIELD]}) 
    currentAccountInfo;

    handleError() {
        if (!this.pushedNotification) {
            this.showNotification('', 'Não foi possível carregar o extrato do Comprou Voltou do cliente.', 'error');
            this.pushedNotification = true;
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode : 'sticky'
        });

        this.dispatchEvent(evt);
    }

    get cpf() {
        return getFieldValue(this.currentAccountInfo.data, CPF_BANCO_FIELD);
    }

    get contractStatus() {
        return getFieldValue(this.currentAccountInfo.data, STATUS_CONTRATO_FIELD);
    }

    get showCard() {
        return this.cpf;
    }
}