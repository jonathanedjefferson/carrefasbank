import { api, LightningElement,track } from 'lwc';
import getListOfCases from '@salesforce/apex/BCSF_Obter_Casos_Helper.getListOfRecords';
import userId from '@salesforce/user/Id';
import userHasOuvidoria from '@salesforce/customPermission/BCSF_CP_Ouvidoria';
import userHasProcon from '@salesforce/customPermission/BCSF_CP_Procon';
import userHasCritico from '@salesforce/customPermission/BCSF_CP_CanaisCriticos';
import userHasJuridico from '@salesforce/customPermission/BCSF_CP_BackofficeJuridico';

export default class BCSF_cmp_ModalEstornoFatura extends LightningElement {
    @api open = false;
    @api cpf;
    @track openVinculoCaso = false;
    @track childObjectApiName; //Objeto com campo lookup
    @track targetFieldApiName; //Nome do campo lookup
    @track disabled = false;
    @track value;

    @track searchPlaceholder = "Search";
    @track isValueSelected;
    @track selectedFieldLabel;
    @track selectedFieldCaseNumber;
    @track sObjectName;
    @track disableVinculo = true;

    @track estornoDescription = '';
    @track estornoCanal = '';
    @track estornoOrigin = '';
    @track estornoDataRegulatoria;

    @track dataRegulatoriaObrigatoria = false;
    @track origensComRegulatoriaObrigatoria = ['Ouvidoria', 'Bacen', 'Procon', 'Reclame Aqui', 'Consumidor.gov', 'Jurídico - Ações Cíveis'];

    @track userId = userId;
    @track userPermission = !!userHasOuvidoria || !!userHasProcon || !!userHasJuridico || !!userHasCritico;

    listOfFields;
    searchTerm;

    //CSS
    boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    inputClass = '';

    

    connectedCallback() {
        getListOfCases({cpfCliente : this.cpf}).then(result => {
            let listOfFields = [];
            for(let i = 0; i < result.length; i++) {
                let tempRecord = Object.assign({}, result[i]); //cloning object
                listOfFields.push(tempRecord);
            }
          //  listOfFields.sort(this.compare);
            this.listOfFields = listOfFields;
        })
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onSelect(event) {
        let selectedFieldApiName = event.currentTarget.dataset.id;
        this.selectedFieldLabel = event.currentTarget.dataset.name;
        let selectedFieldType = event.currentTarget.dataset.item;
        this.selectedFieldCaseNumber = event.currentTarget.dataset.casenumber;
        const valueSelectedEvent = new CustomEvent('fieldselected', {
            detail: {
                selectedFieldApiName: selectedFieldApiName,
                selectedFieldType: selectedFieldType,
                selectedFieldLabel: this.selectedFieldLabel,
            }});
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.disableVinculo = false;
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
        this.disableVinculo = true;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

    /**
     * This function compares two fields (for sorting purposes) with each other
     */
    compare(a, b) {
        // Use toUpperCase() to ignore character casing
        const fieldLabelA = a.fieldLabel.toUpperCase();
        const fieldLabelB = b.fieldLabel.toUpperCase();

        let comparison = 0;
        if (fieldLabelA > fieldLabelB) {
            comparison = 1;
        } else if (fieldLabelA < fieldLabelB) {
            comparison = -1;
        }
        return comparison;
    }


    selectedFieldLabel;
    selectedFieldApiName;
    selectedFieldType;

    //depois de pegar o input descrição do user e ;ibera os botoes da próxima etapa 


    get linkButtonDisabled() {
        this.disableVinculo = true;
        
        return this.estornoDescription.length === 0 || this.estornoCanal.length === 0 || this.estornoOrigin.length === 0 || (!this.estornoDataRegulatoria && this.dataRegulatoriaObrigatoria && this.userPermission); 
    }

    get userOuvidoria() {
        return this.userPermission;
    }

    handleDescricaoChange(event) {
        this.estornoDescription = event.detail.value;
    }

    handleOriginChange(event) {
        this.dataRegulatoriaObrigatoria = this.origensComRegulatoriaObrigatoria.includes(event.detail.value);
        this.estornoOrigin = event.detail.value;
    }

    handleCanalChange(event) {
        this.estornoCanal = event.detail.value;
    }

    handleDataChange(event) {
        this.estornoDataRegulatoria = event.detail.value;
    }

    handleClose(event) {
        this.estornoDescription = '';
        this.selectedFieldLabel = undefined;
        this.selectedFieldCaseNumber = undefined;
        this.isValueSelected = false;
        this.openVinculoCaso = false;
        this.disableVinculo = true;
        this.dispatchEvent(new CustomEvent('close'))
    }

    handleNewCaso(event) {
        this.dispatchEvent(new CustomEvent("novocaso", {
            detail: {
                descricao: this.estornoDescription,
                origin: this.estornoOrigin,
                canal: this.estornoCanal,
                dataRegulatoria: this.estornoDataRegulatoria,
            }
        }));
        this.handleClose(event);
    }

    handleVincular(event){
        this.dispatchEvent(new CustomEvent("vinculo", {
            detail: {
                descricao: this.estornoDescription,
                casoId: this.selectedFieldLabel,
                origin: this.estornoOrigin,
                canal: this.estornoCanal,
                dataRegulatoria: this.estornoDataRegulatoria,
            },
        }));
        this.handleClose(event);
    }

    get firstStep() {
        return this.open && !this.openVinculoCaso;
    }

    get secondStep() {
        return this.open && this.openVinculoCaso;
    }

    goToSecondStep() {
        this.selectedFieldLabel = undefined;
        this.isValueSelected = false;
        this.openVinculoCaso = true;
    }

    goBack() {
        this.estornoDescription = '';
        this.openVinculoCaso = false;
    }
}