import { LightningElement, wire, api} from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { CurrentPageReference } from "lightning/navigation";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCashbackCustomerInfo from "@salesforce/apex/CashbackAccountStatusControlController.getCashbackCustomerInfo";
import createCase from "@salesforce/apex/CashbackAccountStatusControlController.createCase";
import CASE_OBJECT from "@salesforce/schema/Case";
import CHANNEL_FIELD from "@salesforce/schema/Case.CanalEntrada__c";
import ORIGIN_FIELD from "@salesforce/schema/Case.Origin";

export default class CashbackAccountStatusControl extends NavigationMixin(LightningElement) {
    _recordId;
    caseRecordTypeId;
    subjects = [
        {label: 'Comprou Voltou', value: 'Comprou Voltou'}
    ];
    events = [
        {label: 'Bloqueio preventivo', value: 'Bloqueio preventivo'},
        {label: 'Bloqueio definitivo', value: 'Bloqueio definitivo'},
        {label: 'Desbloqueio de preventivo', value: 'Desbloqueio de preventivo'},
        {label: 'Desbloqueio de definitivo', value: 'Desbloqueio de definitivo'},
        {label: 'Solicitar desbloqueio de preventivo', value: 'Solicitar desbloqueio de preventivo'},
        {label: 'Solicitar desbloqueio de definitivo', value: 'Solicitar desbloqueio de definitivo'}
    ];
    channels;
    origins;
    reasons;
    channelsOptions;
    description;
    customerData;
    selectedPicklistValues = {};
    isLoading = false;
    currentPage = 1;
    actionType;
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

    @wire(CurrentPageReference)
    parseParam(response){
        if (response.type === "standard__quickAction") {
            let quickActionPath = response.attributes.apiName;
            this.actionType = quickActionPath.split(".")[1];
        }
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
            this.handlActionType();
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

    handlActionType() {
        switch (this.actionType) {
            case 'CashbackPreventiveBlocking':
                this.fillCashbackPreventiveBlocking();
                break;
            case 'CashbackPermanentBlocking':
                this.fillCashbackPermanentBlocking();
                break;
            case 'CashbackUnlockAccount':
                this.fillCashbackUnlockAccount();
                break;
            case 'CashbackRequestUnlock':
                this.fillCashbackRequestUnlock();
                break;
        }
    }

    fillCashbackPreventiveBlocking() {
        this.reasons = [{label: 'Suspeita de fraude', value: 'Suspeita de fraude'}, {label: 'Outro', value: 'Outro'}];
        this.selectedPicklistValues = {
            subject: 'Comprou Voltou', 
            event: 'Bloqueio preventivo',
            origin: 'Fraudes', 
            channel: 'Interno'
        };
        this.channelsOptions = [
            {label: 'Interno', value: 'Interno'}
        ];
    }

    fillCashbackPermanentBlocking() {
        this.reasons = [{label: 'Fraude confirmada', value: 'Fraude confirmada'}, {label: 'Outro', value: 'Outro'}];
        this.selectedPicklistValues = {
            subject: 'Comprou Voltou', 
            event: 'Bloqueio definitivo',
            origin: 'Fraudes', 
            channel: 'Interno'
        };
        this.channelsOptions = [
            {label: 'Interno', value: 'Interno'}
        ];
    }

    fillCashbackUnlockAccount() {
        this.reasons = this.customerData.StatusContrato__c == 'BloqueioTemporario' ?
            [
                {label: 'Suspeita de fraude descartada', value: 'Suspeita de fraude descartada'}, 
                {label: 'Segurança da conta reestabelecida', value: 'Segurança da conta reestabelecida'}, 
                {label: 'Outro', value: 'Outro'}
            ] :
            [
                {label: 'Conta Recuperada', value: 'Conta Recuperada'}, 
                {label: 'Outro', value: 'Outro'}
            ];

        this.selectedPicklistValues = {
            subject: 'Comprou Voltou', 
            origin: 'Fraudes', 
            channel: 'Interno'
        };

        this.selectedPicklistValues.event = this.customerData.StatusContrato__c == 'BloqueioTemporario' ? 
            'Desbloqueio de preventivo' : 'Desbloqueio de definitivo';
        
        this.channelsOptions = [
            {label: 'Interno', value: 'Interno'}
        ];
    }

    fillCashbackRequestUnlock() {
        this.selectedPicklistValues = {
            subject: 'Comprou Voltou'
        };

        this.selectedPicklistValues.event = this.customerData.StatusContrato__c == 'BloqueioTemporario' ? 
            'Solicitar desbloqueio de preventivo' : 'Solicitar desbloqueio de definitivo';
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
        let params = {
            origin: this.selectedPicklistValues.origin,
            channel: this.selectedPicklistValues.channel,
            subject: this.selectedPicklistValues.subject,
            event: this.selectedPicklistValues.event,
            reason: this.selectedPicklistValues.reason,
            description: this.description,
            customerId: this.recordId,
            customerCpf: this.customerData.CPFBanco__c,
            actionType: this.actionType,
            contractStatus: this.customerData.StatusContrato__c, 
            contractNumber: this.customerData.NumeroContrato__c
        }

        console.log('params -> ', params);

        createCase({lMapParams: params}).then(lCreatedCase => {
            this.createdCase = lCreatedCase;
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
        console.log('Após a criação do Caso deve redirecionar para o protocolo gerado -> ', recordId);
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
        const descriptionInput = this.template.querySelectorAll('lightning-textarea');
        const allComboboxes = this.template.querySelectorAll('lightning-combobox');

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

    get showPage1() {
        return this.currentPage == 1;
    }

    get showPage2() {
        return this.currentPage == 2;
    }

    get showPage3() {
        return this.currentPage == 3;
    }

    get notCashbackRequestUnlock() {
        return this.actionType && this.actionType != 'CashbackRequestUnlock';
    }

    get isCashbackRequestUnlock() {
        return this.actionType && this.actionType == 'CashbackRequestUnlock';
    }

    //Valores
    get headerTitle() {
        if (['CashbackPreventiveBlocking', 'CashbackPermanentBlocking'].includes(this.actionType)) {
            return 'Bloquear Conta';
        }

        return 'Desbloquear Conta';
    }

    get formTitle() {
        if (['CashbackPreventiveBlocking', 'CashbackPermanentBlocking'].includes(this.actionType)) {
            return 'Dados da solicitação do bloqueio';
        }

        return 'Dados da solicitação do desbloqueio';
    }

    get createdCaseSuccessMessage() {
        if (['CashbackPreventiveBlocking', 'CashbackPermanentBlocking'].includes(this.actionType)) {
            return 'Bloqueio da conta realizado!';
        }

        if (['CashbackUnlockAccount'].includes(this.actionType)) {
            return 'Desbloqueio da conta realizado!';
        }

        return 'Solicitação de desbloqueio de conta realizado!';
    }

    get descriptionPlaceHolder() {
        if (['CashbackPreventiveBlocking', 'CashbackPermanentBlocking'].includes(this.actionType)) {
            return 'Descreva em poucas palavras o motivo do bloqueio';
        }

        return 'Descreva em poucas palavras o motivo do desbloqueio';
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