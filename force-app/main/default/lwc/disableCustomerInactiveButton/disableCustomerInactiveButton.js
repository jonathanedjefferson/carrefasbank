import { LightningElement, track } from 'lwc';
import getResource from "@salesforce/apex/disabeCustomerInactiveButtonController.getStaticRessource";

export default class DisableCustomerInactiveButton extends LightningElement {
    @track intervalId;
    @track disableCustomerInactiveButtonJson = '';

    connectedCallback() {
        this.getStaticRessource();
        this.intervalId = setInterval(() => this.disableButton(), 300); 
    }

    disableButton() {
        try {
            let xpathJson = JSON.parse(this.disableCustomerInactiveButtonJson).xpath;

            xpathJson.forEach(element => {
                let xpath = element;
                let matchingElement = document.evaluate(
                    xpath,
                    document,
                    null,
                    XPathResult.FIRST_ORDERED_NODE_TYPE,
                    null
                ).singleNodeValue;
    
                if (matchingElement) {
                    // clearInterval(this.intervalId);

                    matchingElement.parentElement.setAttribute('aria-disabled', true);
                    matchingElement.parentElement.setAttribute(
                        'style',
                        'display: none;'
                    );
                }
            });

        } catch (error) {
            console.log('ERROR: ' + error);
        }
    }

    getStaticRessource(){
        getResource({}).then(result=>{            
            this.disableCustomerInactiveButtonJson = result;
        }).catch(error=>{
            console.log('ERROR getStaticRessource: ' + error.getMessage());
        });
    }
}