import { LightningElement, wire, api} from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCashbackCustomerInfo from "@salesforce/apex/CashbackAccountStatusControlController.getCashbackCustomerInfo";
import createCase from "@salesforce/apex/CashbackAccountStatusControlController.createCase";
import CASE_OBJECT from "@salesforce/schema/Case";
import CHANNEL_FIELD from "@salesforce/schema/Case.CanalEntrada__c";
import ORIGIN_FIELD from "@salesforce/schema/Case.Origin";


export default class CashbackCancelAccount extends NavigationMixin(LightningElement) {
    _recordId;
    caseRecordTypeId;
    subjects = [
        {label: 'Comprou Voltou', value: 'Comprou Voltou'}
    ];
    events = [
        {label: 'Cancelamento de conta', value: 'Cancelamento de conta'}
    ];
    channels;
    origins;
    reasons = [
        {label: 'Proteção de dados (LGPD)', value: 'Proteção de dados (LGPD)'},
        {label: 'Problema com saldo/extrato', value: 'Problema com saldo/extrato'},
        {label: 'Outro', value: 'Outro'}
    ];
    channelsOptions;
    description;
    customerData;
    selectedPicklistValues = {
        subject: 'Comprou Voltou', 
        event: 'Cancelamento de conta'
    };
    isLoading = false;
    showDescription = false;
    currentPage = 1;
    createdCase;
    maxAttemps = 0;

    //INIT
    connectedCallback() {
        this.isLoading = true;
    }

    @api set recordId(value) {
        this._recordId = value;
        this.fetchCustomerData();
    }
    
    get recordId() {
        return this._recordId;
    }

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

    //HANDLERS
    handleReasonSelection(event) {
        this.selectedPicklistValues.reason = event.detail.value;

        if (this.selectedPicklistValues.reason == 'Outro') {
            this.showDescription = true;
            return;
        }

        this.showDescription = false;
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
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //SUPPORT
    fetchCustomerData() {
        getCashbackCustomerInfo({accountId: this.recordId}).then(response => {
            this.customerData = response;
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false;
        })
    }

    formatCpf(cpf) {
        cpf = cpf.replace(/\D/g,"");
        cpf = cpf.replace(/(\d{3})(\d)/,"$1.$2");
        cpf = cpf.replace(/(\d{3})(\d)/,"$1.$2");
        cpf = cpf.replace(/(\d{3})(\d{1,2})$/,"$1-$2");

        return cpf;
    }

    setDependentPicklist(data, controllerValue) {
        const key = this.origins.findIndex(origin => origin.value === controllerValue);
        return data.filter((opt) => opt.validFor.includes(key));
    }

    handleForm() {
        if (!this.evaluateRequiredFields()) {
            return;
        }

        this.currentPage++;
    }

    generateProtocol() {
        this.isLoading = true;
        this.description = this.showDescription ? this.description : '';

        let params = {
            actionType: 'CashbackCancelAccount',
            origin: this.selectedPicklistValues.origin,
            channel: this.selectedPicklistValues.channel,
            subject: this.selectedPicklistValues.subject,
            event: this.selectedPicklistValues.event,
            reason: this.selectedPicklistValues.reason,
            description: this.description,
            customerId: this.recordId,
            customerCpf: this.customerData.CPFBanco__c,
            contractStatus: this.customerData.StatusContrato__c, 
            contractNumber: this.customerData.NumeroContrato__c
        }

        createCase({lMapParams : params}).then(createdCase => {
            this.createdCase = createdCase;
            this.currentPage++;
            this.isLoading = false;
        })
        .catch(error => {
            this.maxAttemps ++;
            console.error(error);
            this.isLoading = false;
            this.showToast('', this.toastErrorMessage, 'error', 'sticky');
        })
    }

    showToast(titulo, mensagem, variante, modelo) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: modelo
        });

        this.dispatchEvent(evt);
    }

    redirectToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    evaluateRequiredFields() {
        let allValid = true;
        const allComboboxes = this.template.querySelectorAll('lightning-combobox');
        allComboboxes.forEach(combobox => {
            if (!combobox.checkValidity()) {
                combobox.reportValidity();
                allValid = false;
            }
        })

        if (this.showDescription) {
            const descriptionInput = this.template.querySelectorAll('lightning-textarea');
            if (!descriptionInput[0].checkValidity()) {
                descriptionInput[0].reportValidity();
                allValid = false;
            }
        }
        
        return allValid;
    }

    getTodayDate() {
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();
        
        return `${day}/${month}/${year}`;
    }

    //Controle de estado
    get showData() {
        return this.customerData && this.selectedPicklistValues;
    }

    get descriptionPlaceHolder () {
        return 'Descreva em poucas palavras o motivo do cancelamento';
    }

    get createdCaseSuccessMessage() {
        return 'Cancelamento de conta realizado!';
    }

    get contractStatus() {
        let contractStatusValues = {
            'Ativo' : 'Ativo',
            'Inativo' : 'Inativo',
            'BloqueioDefinitivo' : 'Bloqueio definitivo',
            'BloqueioTemporario' : 'Bloqueio temporário'
        }

        return contractStatusValues[this.customerData.StatusContrato__c];
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

    get maskedCpf() {
        return this.formatCpf(this.customerData.CPFBanco__c);
    }

    get createdDate() {
        return this.getTodayDate();
    }

    get nextButtonName() {
        return this.currentPage == 1 ? 'Prosseguir' : this.currentPage == 2 ? 'Finalizar' : 'Ir para o caso';
    }

    get disableButtons() {
        return this.isLoading || this.maxAttemps >= 3;
    }

    get toastErrorMessage() {
        return this.maxAttemps >= 3 ? 
            'Não foi possível realizar a solicitação devido a uma falha no carregamento dos dados. Tente novamente mais tarde' : 
            'Não foi possível realizar a solicitação devido a uma falha no carregamento dos dados.';
    }
}