import { LightningElement, track, wire, api  } from 'lwc';

export default class bcsf_cmp_illustration extends LightningElement {


    @api illustrationType = false;
    @api headingMessage = '';
    @api bodyMessage = '';
    @api buttonLabel = null;
    @api styleClass = 'slds-p-vertical_xx-large';

    get illustrationTypeNoData() {
        return this.illustrationType === 'NO_DATA';
    }
    get illustrationTypeNoDataDesert(){
        return this.illustrationType === 'NO_DATA_DESERT';
    }
    
    get illustrationTypeNoDataOpenRoad(){
        return this.illustrationType === 'NO_DATA_OPEN_ROAD';
    }

    get illustrationTypeNoEvents(){
        return this.illustrationType === 'NO_EVENTS';
    }

    get illustrationTypeNoAccess(){
        return this.illustrationType === 'NO_ACCESS';
    }

    get illustrationTypeNoAvailableLightning(){
        return this.illustrationType === 'NO_AVALIABLE_LIGHTNING';
    }

    get style() {
        return 'slds-illustration slds-illustration_small ' + this.styleClass;
    }

    get showInfos(){
        return (this.title !== null && this.title !== '') || (this.bodyMessage !== null && this.bodyMessage !== '' );
    }

    get hasButton() {
        return this.buttonLabel !== null;
    }
    
    callParentAction() {
        if (this.buttonLabel !== null) {
            this.dispatchEvent(new CustomEvent('eventotentarnovamente'));
        }
    }

}