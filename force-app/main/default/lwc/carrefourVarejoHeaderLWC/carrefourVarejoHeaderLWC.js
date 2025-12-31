import { LightningElement, track } from 'lwc';
import salesimagem from '@salesforce/resourceUrl/CarinaLogo';
import min from '@salesforce/resourceUrl/min';
import fechar from '@salesforce/resourceUrl/fechar';
import BaseChatHeader from 'lightningsnapin/baseChatHeader';

export default class carrefourVarejoHeaderLWC extends BaseChatHeader {
    salesimagem = salesimagem;
    min = min;
    fechar = fechar;

    @track showIdleTimeoutWarning = false;
    @track textLabel;
    @track contadorLabel;

    @track chatLabelClass = 'slds-p-around_medium chat-label'; // Inicialmente com as classes 'slds-p-around_medium' e 'chat-label'

  

    aplicarFadeOut() {
        // Adicione a classe 'fade-out' à classe existente
        this.chatLabelClass += ' fade-out';

        setTimeout(() => {
            // Remova a classe 'fade-out' após o fade-out
            this.chatLabelClass = this.chatLabelClass.replace('fade-out', '').trim();
            this.showIdleTimeoutWarning = false;
        }, 6000); // Tempo em milissegundos (8 segundos no exemplo)
    }

    
    connectedCallback() {
        this.assignHandler("chatTimeoutUpdate", (data) => {

            let labelWithTimeout = data.label
            // .replace("Are you still there? Please send a message within {0}m {1}s or this chat will time out.", "Você ainda esta aí? Por favor, selecione alguma das opções ou envie uma resposta em {0}m {1}s ou esse chat será encerrado.")
            .replace("Você ainda está aí? Envie uma mensagem dentro de {0} minutos e {1} segundos ou este chat atingirá o tempo limite", "Você ainda esta aí? Por favor, selecione alguma das opções ou envie uma resposta em {0}m {1}s ou esse chat será encerrado.")

            .replace("{0}", Math.floor(data.timeoutSecondsRemaining / 60))
            .replace("{1}", data.timeoutSecondsRemaining % 60);


            console.group('dataInteiro - chatTimeoutUpdate')
            console.dir(this.template)
            console.groupEnd();
      

            this.textLabel = labelWithTimeout
            this.showIdleTimeoutWarning = true;
        });

        this.assignHandler("chatTimeoutClear", (data) => {

            console.group('dataInteiro - chatTimeoutClear')
            console.groupEnd();

            this.aplicarFadeOut();
        });

        this.assignHandler("chatEndedState", (data) => {
            this.aplicarFadeOut();
        });


    }

}