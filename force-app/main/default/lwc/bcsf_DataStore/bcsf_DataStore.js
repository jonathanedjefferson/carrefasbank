import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import BCSF_IDENTIFICACAO_POSITIVA from '@salesforce/messageChannel/BCSF_IdentificacaoPositiva__c';

export default class BCSF_DataStore extends LightningElement {
    @wire(MessageContext)
    messageContext;

    subscription = null;
    latestMessage = null;
    checkInterval = null;
    _isComponentPresent = false;

    connectedCallback() {
        this.handleSubscribe();
        // this.startChecker();
    }

    handleSubscribe() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                BCSF_IDENTIFICACAO_POSITIVA,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );

        }
    }

    handleMessage(message) {
        console.log('📩 Mensagem LMS recebida:', message);
        if (message.valor === 'Sim' || message.valor === 'Não') {
            this.latestMessage = message.valor;
            console.log('🟢 Assinado no canal LMS: BCSF_IdentificacaoPositiva');
        } else {
            this.reenviarMensagem();
            console.log('Reenviar mensagen foi chamado');
            console.log('🟢 Assinado no canal LMS: BCSF_AtivarInativarCartao ' + message.valor);
        }

    }
    reenviarMensagem() {
        console.log('📤 Reenviando mensagem armazenada:', this.latestMessage);
        publish(
            this.messageContext,
            BCSF_IDENTIFICACAO_POSITIVA,
            { valor: this.latestMessage }
        );
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
            console.log('🔴 Cancelada a assinatura do canal LMS.');
        }

        if (this.checkInterval) {
            clearInterval(this.checkInterval);
            this.checkInterval = null;
        }
    }
}