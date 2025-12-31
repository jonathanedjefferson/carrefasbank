import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/globalCSS';

export default class ComponenteCSS2 extends LightningElement {

    renderedCallback(){
        Promise.all([
            loadStyle(this, styles)
        ]).catch(error => {
            console.log("Error rendered: " + error.body.message);
        });
    }
}