import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import BCSF_SEGUROS_MC from '@salesforce/messageChannel/BCSF_Seguros__c';
import getScript from '@salesforce/apex/bcsf_cmp_SegurosController.searchArticles'

export default class Bcsf_scriptSeguros extends NavigationMixin(LightningElement) {

    //Var Channel
    messageChanel = '';
    subscription;
    
    //Var knowledge
    @track resposta;
    @track pergunta;
    @track dataModificacao;
    @track title;
    
    //Var template
    @track toggleScript = false;
    @track spinner = false;
    @track voteState = false;
    @track likeState = false;
    @track dislikeState = false;
    @track numberLike = 0;
    @track numberDislike = 0;
    @track feedback = '';

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeChannel();
    }

    async GetScript(){
        await getScript({title : this.messageChanel}).then((result) => {
            if(result){
                this.title = result.Title;
                this.pergunta = result.Perguntas__c;
                this.resposta = result.Resposta__c;
                this.dataModificacao = this.FormatDateTime(result.LastModifiedDate);
                this.toggleScript = true;
            }else{
                this.title = 'Artigo não encontrado';
                this.pergunta ='Nenhum artigo encontrado';
                this.resposta = '--';
                this.dataModificacao = 'Ultima atualização: --/--/----, --:--';
                this.toggleScript = true;
            }
        }).catch((error) => {
            this.toggleScript = false;
            console.log('Error: ' + error.message);
            this.showToast('Erro', 'Houve um erro ao buscar Scripts!', 'error');
        });
        this.SpinnerToggle();
    }
    
    subscribeChannel(){
        this.subscription = subscribe(this.messageContext,
                                        BCSF_SEGUROS_MC,
                                        (message) => {
                                            this.handleMessage(message)},
                                            {scope: APPLICATION_SCOPE}
                                        );
    }
    
    //#region funções botões
    handleMessage(message) {
        this.SpinnerToggle();
        this.messageChanel = message.messageToSend;
        this.GetScript();
    }
    handleBtnClose(){
        this.toggleScript = false;
    } 
    handleBtnMaisScript(){
        console.log('aqui');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Knowledge__kav', 
                actionName: 'list'
            },
            state: {
                filterName: 'Todas_as_Bases_de_Conhecimento'
            }
        });
    }
    handleBtnDislike(){
        this.dislikeState = !this.dislikeState;
        if (this.dislikeState) {
            this.likeState = false;
            this.numberDislike += 1;

            if(this.feedback == 'like' || this.feedback == '' && this.numberLike > 0){
                this.numberLike -= 1;
            }
            this.feedback = 'dislike';
        }else {
            this.numberDislike -= 1;
        }
    }
    handleBtnLike(event) {
        this.likeState = !this.likeState;
        if (this.likeState) {
            this.dislikeState = false;
            this.numberLike += 1;

            if(this.feedback == 'dislike' || this.feedback == '' && this.numberLike > 0){
                this.numberDislike -= 1;
            }
            this.feedback = 'like';
        }else {
            this.numberLike -= 1;
        }
    }
    //#endregion

    //#region funções genericas 
    FormatDateTime(dateString) {
        const dateTime = new Date(dateString);
        const options = {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false,
        };
        
        const formatter = new Intl.DateTimeFormat('pt-BR', options);
        return formatter.format(dateTime);
    }

    SpinnerToggle(){
        this.spinner = !this.spinner;
    }

    showToast(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    //#endregion 

}