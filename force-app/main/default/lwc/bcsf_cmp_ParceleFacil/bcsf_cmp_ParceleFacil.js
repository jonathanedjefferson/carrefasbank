import { LightningElement, track, api, wire } from 'lwc';
import { createMessageChannel, publish, MessageContext } from 'lightning/messageService';
import BCSF_SEGUROS_MC from '@salesforce/messageChannel/BCSF_Seguros__c';


export default class bcsf_cmp_ParceleFacil extends LightningElement {

    channel
    @api recordId;
    @track pageSimular = true;
    @track pageOfertas = true;
    @track pageContratados = true;
    @track pageSelected;

    @wire(MessageContext)
    messageContext

    connectedCallback(){
        this.channel = createMessageChannel(BCSF_SEGUROS_MC);
    }

    handleGetScript() {
        let messageParcele
        if(this.pageContratados){
            messageParcele = "Parcele Facil Contratados"
        }
        if(this.pageOfertas){
            messageParcele = "Parcele Facil Pendentes"
        }
        if(this.pageSimular){
            messageParcele = "Parcele Facil Simular"
        }
        const message = {
            messageToSend: messageParcele
        };
        publish(this.messageContext, BCSF_SEGUROS_MC, message).catch(error=>{
            console.log('Erro getSCript: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar Script!', 'error', true);
        });
    }

    handleSimular(){
        this.pageSimular = true;
        this.pageContratados = false;
        this.pageOfertas = false;
    }
    handleOfertas(){
        this.pageOfertas = true;
        this.pageSimular = false;
        this.pageContratados = false;
    }
    handleContratados(){
        this.pageContratados = true;
        this.pageOfertas = false;
        this.pageSimular = false;
    }
}