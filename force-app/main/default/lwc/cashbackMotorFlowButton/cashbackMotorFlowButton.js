import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class CashbackMotorFlowButton extends LightningElement {
    @api url = '/lightning/n/Ofertas_ComprouVoltou';
    @api label = 'Consultar Ofertas';
    @api variant = 'neutral'; 
    @api openIn = '_blank'; 
    @api autoOpen = false; 
    @api advanceOnClick = false; 

    connectedCallback() {
        if (this.autoOpen && this.url) {
            window.open(this.url, this.openIn);   
        }
    }

    handleClick() {
        if (this.url) window.open(this.url, this.openIn);
    }
}