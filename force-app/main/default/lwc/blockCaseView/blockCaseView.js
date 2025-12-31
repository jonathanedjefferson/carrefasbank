import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNTID from '@salesforce/schema/Case.AccountId';

export default class BlockCaseView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isOpen = true;
    @api message = 'Você não possui permissão para acessar esse protocolo';
    currentUrl = window.location.href;
    accountId;


    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNTID] })
    caseDataWired({ error, data }) {
        if (data) {
            this.accountId = getFieldValue(data, ACCOUNTID);
        } else if (error) {
            console.log('Error: ' + error);
        }
    };

    connectedCallback() {
        //Caso esteja no editor da flexipage o componente não deve executar o comportamento
        if (this.checkFlexiPageEditor()) {
            console.log('Está no editor da flexipage, não deve iniciar o componente')
            return;
        }

        setTimeout(() => { 
            this.setNavigation();
        }, 5000);
    }

    checkFlexiPageEditor() {
        if (this.currentUrl.includes('flexipageEditor')) {
            this.isOpen = false;
            return true;
        }

        return false;
    }

    setNavigation() {
        this.accountId ? this.redirecionarAccount() : this.navigateToCaseListView();
    }

    navigateToCaseListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'
            }
        });
    }
    
    redirecionarAccount(){
        const host = window.location.host;
        let url =  'https://' + host + '/'+ this.accountId;

        window.location.assign(url);
    }
}