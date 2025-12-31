import { LightningElement, wire, track } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import getBulkRecordDetails from '@salesforce/apex/BulkCaseManagerController.getBulkRecordDetails';
import SUBJECT_FIELD from "@salesforce/schema/Case.Assunto__c";
import EVENT_FIELD from "@salesforce/schema/Case.Evento__c";
import CLOUD_RAIN from "@salesforce/resourceUrl/CloudRain";
import EMPTY_STATE from "@salesforce/resourceUrl/EmptyState";

const COLUMNS = [
    { label: 'Número do Caso', fieldName: 'caseNumber', type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Empresa', fieldName: 'bussinessUnit', type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Tipo de importação', fieldName: 'importType', type: 'text', wrapText: true, cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Conta', fieldName: 'account', type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Assunto', fieldName: 'subject', type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Evento', fieldName: 'event', type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    { label: 'Erro', fieldName: 'errorMessage', type: 'text', cellAttributes: { alignment: 'left' }, hideDefaultActions: true, wrapText: true }
];

const BUSINESS_UNITS = {
    1: 'Carrefour', 
    2: 'Atacadão',
    6: 'Sams CLub'
}

export default class BulkCaseImportErrors extends LightningElement {
    columns = COLUMNS;
    errorData;
    filters = {
        itensPerPage: '10',
        startIndex: '0'
    };
    showEmptyState = false;
    hasError = false;
    currentPage = 1;
    totalPages = 1;
    selectedFilterValue = {
        subject: '', 
        event: '', 
        importType: ''
    };
    itensPerPage = '10';
    itensPerPageOptions = [
        { label: '5', value: '5' },
        { label: '10', value: '10' },
        { label: '20', value: '20' }
    ];
    importTypes = [
        { label: 'Abertura massificada', value: 'Abertura massificada' },
        { label: 'Fechamento massificado', value: 'Fechamento massificado' }
    ]

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: SUBJECT_FIELD })
    caseSubjects({ error, data }) {
        if (data) {
            this.subjects = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: EVENT_FIELD })
    caseEvents({ error, data }) {
        if (data) {
            this.events = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        this.getData();
    }

    getData() {
        getBulkRecordDetails({lMapFilters : this.filters}).then(response => {
            if (response.records.length === 0) {
                this.errorData = [];
                this.showEmptyState = true;
                return;
            }

            this.showEmptyState = false;
            this.errorData = response.records.map( record => ({
                caseNumber: record.CaseNumber__c,
                bussinessUnit: this.getBusinessUnitLabel(record.BusinessUnit__c), 
                importType: record.ImportType__c, 
                account: record.AccountNumber__c,
                subject: record.Subject__c,
                event: record.Event__c,
                errorMessage: record.ErrorMessage__c
            }))

            this.totalPages = Math.ceil(response.totalItems / parseInt(this.itensPerPage));
        })
        .catch(error => {
            this.hasError = true;
            this.showEmptyState = true;
            console.error(error);
        })
    }

    handleSearch() {
        this.filters = {};
        
        if (this.selectedFilterValue.event) {
            this.filters['event'] = this.selectedFilterValue.event;
        }

        if (this.selectedFilterValue.subject) {
            this.filters['subject'] = this.selectedFilterValue.subject;
        }

        if (this.selectedFilterValue.importType) {
            this.filters['importType'] = this.selectedFilterValue.importType;
        }

        this.filters['itensPerPage'] = this.itensPerPage;
        this.filters['startIndex'] = parseInt(this.itensPerPage) * (this.currentPage - 1);

        this.getData();
    }

    getBusinessUnitLabel(businessUnit) {
        return BUSINESS_UNITS[businessUnit];
    }

    handleSubjectSelection(event) {
        this.selectedFilterValue.subject = event.detail.value;
    }

    handleEventSelection(event) {
        this.selectedFilterValue.event = event.detail.value;
    }

    handleTypeSelection(event) {
        this.selectedFilterValue.importType = event.detail.value;
    }

    handleItensPerPage(event) {
        this.itensPerPage = event.detail.value;
        this.currentPage = 1;
        this.handleSearch();
    }

    handlePreviousPage() {
        if (this.currentPage <= 1) {
            return;
        }

        this.currentPage--;
        this.handleSearch();
    }
    
    handleNextPage() {
        if (this.currentPage >= this.totalPages) {
            return;
        }

        this.currentPage++;
        this.handleSearch();
    }

    get hasData() {
        return this.errorData && this.errorData.length > 0;
    }

    get emptyStateImg() {
        return this.hasError ? EMPTY_STATE : CLOUD_RAIN;
    }

    get message() {
        return this.hasError ? 'Falha ao realizar a busca' 
            : 'Não existem erros em importação disponíveis';
    }

    get subMessage() {
        return this.hasError ? 'Houve um comportamento inesperado do sistema, tente novamente.' 
            : 'Quando houver alguma informação disponível, ela aparecerá aqui.';
    }
}