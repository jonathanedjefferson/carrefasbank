import { api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import LightningModal from 'lightning/modal';
import getCashbackCustomerInfo from '@salesforce/apex/CashbackController.getCashbackCustomerInfo'
import createCase from '@salesforce/apex/CashbackController.createCase'
import CASE_OBJECT from "@salesforce/schema/Case";
import SUBJECT_FIELD from "@salesforce/schema/Case.Assunto__c";
import EVENT_FIELD from "@salesforce/schema/Case.Evento__c";
import CHANNEL_FIELD from "@salesforce/schema/Case.CanalEntrada__c";
import ORIGIN_FIELD from "@salesforce/schema/Case.Origin";

export default class CashbackRefundModal extends LightningModal {
    @api detail;
    customerData;
    isLoading = true;
    caseRecordTypeId;
    subjects;
    events;
    channels;
    channelsOptions = [];
    origins;
    selectedPicklistValues = {};
    description;
    amountValue;
    createdCase;
    createdDate;
    currentPage = 1;
    msgAlert;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    results({ error, data }) {
        if (data) {
            const recordTypes = data.recordTypeInfos;
            const recordTypeInfo = Object.values(recordTypes).find(rt => rt.name === 'BCSF Atendimento');
            if (recordTypeInfo) {
                this.caseRecordTypeId = recordTypeInfo.recordTypeId;
            }
        } else if (error) {
           console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$caseRecordTypeId", fieldApiName: SUBJECT_FIELD })
    caseSubjects({ error, data }) {
        if (data) {
            this.subjects = data.values;
            this.selectedPicklistValues.subject = 'Comprou Voltou';
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$caseRecordTypeId", fieldApiName: EVENT_FIELD })
    caseEvents({ error, data }) {
        if (data) {
            this.events = data.values;
            this.selectedPicklistValues.event = this.detail.type == 'refund' ? 'Valor Cashback Errado' : 'Resgate não reconhecido';
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$caseRecordTypeId", fieldApiName: ORIGIN_FIELD })
    caseOrigins({ error, data }) {
        if (data) {
            this.origins = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$caseRecordTypeId", fieldApiName: CHANNEL_FIELD })
    caseChannels({ error, data }) {
        if (data) {
            this.channels = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        this.fetchCustomerData();
        this.fillFieldAmout();
    }

    fetchCustomerData() {
        getCashbackCustomerInfo({'cpf' : this.detail.cpf}).then(customer => {
            this.customerData = customer;
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error);
        })
    }

    fillFieldAmout() {
        if (this.detail.type == 'refund') {
            return;
        }

        this.amountValue = Math.abs(this.detail?.transactionDetail?.rewardAmountRaw);
    }

    handleForm() {
        if (!this.evaluateRequiredFields()) {
            return;
        }

        this.currentPage++;
    }

    generateProtocol() {
        this.isLoading = true;
        let params = {
            'customerId' : this.customerData.Id,
            'cpf' : this.customerData.CPFBanco__c,
            'subject' : this.selectedPicklistValues.subject,
            'event' : this.selectedPicklistValues.event,
            'origin' : this.selectedPicklistValues.origin,
            'channel' : this.selectedPicklistValues.channel,
            'amountValue' : this.amountValue.toString(),
            'description' : this.description,
            'subjectType' : this.detail.type,
            'transactionId' : this.detail?.transactionDetail?.id,
            'contractNumber' : this.customerData?.NumeroContrato__c,
            'contractStatus' : this.customerData?.StatusContrato__c
        }

        createCase({'lMapParams' : params}).then(createdCase => {
            if (!createdCase) {
                this.isLoading = false;
                this.showNotification('', 'Não foi possível realizar a solicitação devido a uma falha no carregamento dos dados.', 'error');
                return;
            }

            this.createdCase = createdCase;
            this.createdDate = this.getTodayDate();
            this.isLoading = false;
            this.currentPage ++;
        })
        .catch(error => {
            console.error(error);
            this.showNotification('', 'Não foi possível realizar a solicitação devido a uma falha no carregamento dos dados.', 'error');
            this.isLoading = false;
        })
    }

    handleAmountValue(event) {
        this.amountValue = event.detail.value;
    }

    handleDescription(event) {
        this.description = event.detail.value;
    }

    handleChangeOrigin(event) {
        this.selectedPicklistValues.origin = event.detail.value;

        if (this.channels && this.selectedPicklistValues.origin) {
            this.channelsOptions = this.setDependentPicklist(this.channels, this.selectedPicklistValues.origin);
        }
    }

    handleChangeChannel(event) {
        this.selectedPicklistValues.channel = event.detail.value;
    }

    handleNext() {
        switch (this.currentPage) {
            case 1:
                this.handleForm();
                break;
            case 2:
                this.generateProtocol();
                break;
            case 3:
                this.redirectToRecord(this.createdCase.Id);
                break;
        }
    }

    handleClose() {
        let params = {
            'eventType' : 'close', 
            'recordId' : null
        }
        this.close(params);
    }

    redirectToRecord(recordId) {
        let params = {
            'eventType' : 'redirect', 
            'recordId' : recordId
        }
        this.close(params);
    }

    formatCpf(cpf) {
        cpf = cpf.replace(/\D/g,"");
        cpf = cpf.replace(/(\d{3})(\d)/,"$1.$2");
        cpf = cpf.replace(/(\d{3})(\d)/,"$1.$2");
        cpf = cpf.replace(/(\d{3})(\d{1,2})$/,"$1-$2");

        return cpf;
    }
    
    formatCashback(aValue) {
        if (!aValue && aValue != 0) {
            return '-';
        }

        const valueReplaced = parseInt(aValue).toFixed(2).replace('.', ',');
        return `CB$ ${valueReplaced}`;
    }

    getTodayDate() {
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();
        
        return `${day}/${month}/${year}`;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode : 'sticky'
        });

        document.dispatchEvent(evt);
    }

    setDependentPicklist(data, controllerValue) {
        const key = this.origins.findIndex(origin => origin.value === controllerValue);
        return data.filter((opt) => opt.validFor.includes(key));
    }

    evaluateRequiredFields() {
        let allValid = true;
        const amountInput = this.template.querySelectorAll('lightning-input');
        const descriptionInput = this.template.querySelectorAll('lightning-textarea');
        const allComboboxes = this.template.querySelectorAll('lightning-combobox');

        if (!amountInput[0].checkValidity()) {
            amountInput[0].reportValidity();
            allValid = false;
        }

        if (!descriptionInput[0].checkValidity()) {
            descriptionInput[0].reportValidity();
            allValid = false;
        }

        allComboboxes.forEach(combobox => {
            if (!combobox.checkValidity()) {
                combobox.reportValidity();
                allValid = false;
            }
        })

        return allValid;
    }

    handleConsultarOfertas() {
        const url = '/lightning/n/Ofertas_ComprouVoltou';
        window.open(url, '_blank');
    }

    get headerTitle() {
        return (this.detail.type && this.detail.type == 'refund') ? 'Solicitar ajuste de cashback' : 'Contestar resgate';
    }

    get formTitle() {
        return (this.detail.type && this.detail.type == 'refund') ? 'Dados da solicitação de ajuste de cashback' : 'Dados da contestação de resgate';
    }

    get createdCaseSuccessMessage() {
        return (this.detail.type && this.detail.type == 'refund') ? 'Solicitação de ajuste de cashback realizada!' : 'Contestação de resgate realizada!';
    }

    get MsgAlert() {
        return this.detail.type == 'refund' ? 'A solicitação precisará ser analisada pelo setor responsável.' : 'A conta do cliente será bloqueada preventivamente até que a solicitação seja analisada pelo setor responsável.';
    }

    get amountLabel() {
        return (this.detail.type && this.detail.type == 'refund') ? 'Ajuste estimado (CB$)' : 'Valor do resgate (CB$)';
    }

    get disableAmoutInput() {
        return (this.detail.type && this.detail.type == 'reversal');
    }

    get showData() {
        return this.detail && this.customerData && !this.isLoading;
    }

    get amountValueFormated() {
        return this.formatCashback(this.amountValue);
    }

    get maskedCpf() {
        return this.formatCpf(this.customerData.CPFBanco__c);
    }

    get buttonLabel() {
        return this.currentPage == 1 ? 'Prosseguir' : this.currentPage == 2 ? 'Finalizar' : 'Ir para o caso';
    }

    get showPage1() {
        return this.currentPage == 1;
    }

    get showPage2() {
        return this.currentPage == 2;
    }

    get showPage3() {
        return this.currentPage == 3;
    }

    get showReversalAlert() {
        return this.detail?.type === 'reversal' && this.showPage1;
    }
}