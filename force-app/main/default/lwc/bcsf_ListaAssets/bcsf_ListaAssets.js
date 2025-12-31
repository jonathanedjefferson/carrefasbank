import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';


import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import getAllAtivos from '@salesforce/apex/AssetController.getAllAtivos';
import getAllButtonsAssets from '@salesforce/apex/AssetController.getAllButtonsAssets';

const columns = [
    { label: '', fieldName: 'index', 
        hideLabel: true, 
        hideDefaultActions: true,
        fixedWidth: 50,
        initialWidth: 50,
        cellAttributes: { alignment: 'center' },},
    {   label: 'Nome do ativo', 
        fieldName: 'url', 
        type: 'url',
        typeAttributes: { label:{ fieldName: 'nomeAtivo' }, tooltip: { fieldName: 'nomeAtivo' }}, 
        },
    { label: 'Nome Reduzido', fieldName: 'nomeReduzido' },
    { label: 'Cartão Primário', fieldName: 'isCartaoPrimario', type: 'boolean'},
    { label: 'Número do cartão', fieldName: 'numeroCartao' },
    { label: 'Status', fieldName: 'statusCartao' },
];

export default class BCSF_lista_assets extends LightningElement {
    
    //#region Variaveis 
    spinner = false;
    areaPrincipal = null;
    @track data = [];
    columns = columns;
    @track buttons = [];
    @track menu = [];
    @track moreThanTwoButtons = false;

    @track modalContacless = false;
    @track modalAtivarInativar = false;
    @track modalCartaoPrimario = false;
    closeModalComponent = true;

    @api recordId;
    @track quantidadeAtivos = 0;
    @track item = 'items';

    urlViewAll = '/lightning/r/ContaFinanceira__c/';

    //#endregion

    //#region wire's

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.areaPrincipal = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    //#endregion

    connectedCallback() {
        this.carregarAtivos();
        this.getAllButtonsAssets();

        this.urlViewAll = this.urlViewAll + this.recordId + '/related/Ativos__r/view';
    }

    //#endregion

    //#region métodos Toast, Spinner e verify
    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }




    
    openModalByDeveloperName(developerName){
        if(developerName == 'buttonAssets_contactless'){
            this.modalAtivarInativar = false;
            this.modalCartaoPrimario = false;
            this.modalContacless = true;
            document.body.setAttribute('style', 'overflow: hidden;');
        } else if(developerName == 'buttonAssets_ativarInativar'){
            this.modalContacless = false;
            this.modalCartaoPrimario = false;
            this.modalAtivarInativar = true;
            document.body.setAttribute('style', 'overflow: hidden;');
        } else if(developerName == 'buttonAssets_cartaoPrimario'){
            this.modalContacless = false;
            this.modalAtivarInativar = false;
            this.modalCartaoPrimario = true;
            document.body.setAttribute('style', 'overflow: hidden;');
        }
    }

    buttonHandler(event){
        this.openModalByDeveloperName(event.target.name);
    }

    handleMenuSelectButton(event) {
        this.openModalByDeveloperName(event.detail.value);
    }

    fecharModal(event) {
        document.body.removeAttribute('style', 'overflow: hidden;');
        this.modalContacless = false;
        this.modalAtivarInativar = false;
        this.modalCartaoPrimario = false;
    }

    showToast(titulo, mensagem, variante, mode, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            messageData: [],
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    @api closeParentComponent;
    closeQuickAction() {
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'))
        }else{
            this.modalContacless = false;
            this.modalAtivarInativar = false;
            this.modalCartaoPrimario = false;
            document.body.removeAttribute('style', 'overflow: hidden;');
        }
    }

    refreshPageAction(event) {
        this.carregarAtivos();
    }
    
    //#endregion

    // Lista de todos os cartões da conta financeira
    carregarAtivos() {
        getAllAtivos({
            recordId: this.recordId
        }).then(result => {
            if (result != null && result.length > 0) {
                let opcoes = [];
                var index = 0;
                result.forEach(item => {
                    if(index < 10){
                        index++;
                        opcoes.push(
                            { 
                                index: index,
                                ativoId: item.AssetId,
                                numeroSernoId: item.NumeroSernoId,
                                nomeAtivo: item.NomeAtivo,
                                url: '/lightning/r/' + item.AssetId + '/view',
                                nomeReduzido: item.NomeReduzido,
                                isCartaoPrimario: item.IsCartaoPrimario,
                                numeroCartao: item.NumeroCartao,
                                statusCartao: item.Status
                            }
                        );
                    }
                });
                
                this.data = opcoes;
                if(result.length == 1){
                    this.item = 'item';
                    this.quantidadeAtivos = index;
                }else if(result.length > 10){
                    this.quantidadeAtivos = '10+';
                } else {
                    this.quantidadeAtivos = index;
                }
            }
        }).catch(error => {
            console.log('carregarAtivos: ' + error);
        });
    }

    getAllButtonsAssets() {
        getAllButtonsAssets({
        }).then(result => {
            if (result != null && result.length > 0) {
                let buttonsList = [];
                let menuList = [];
                var quantidadeBotoes = 0;
                result.forEach(item => {
                    
                    if(!item.IsLigado){
                        return;
                    }

                    if(quantidadeBotoes < 2){
                        buttonsList.push(
                            { 
                                label: item.Label, 
                                value: item.DeveloperName,
                                isLigadoButton: item.IsLigado,
                                developerName: 	item.DeveloperName
                        });
                    } else {
                        menuList.push(
                            { 
                                label: item.Label, 
                                value: item.DeveloperName,
                                isLigadoButton: item.IsLigado,
                                developerName: 	item.DeveloperName
                        });

                        this.moreThanTwoButtons = true;
                    }

                    if(item.IsLigado){
                        quantidadeBotoes++;
                    }
                });

                this.buttons = buttonsList;
                this.menu = menuList;
            }
        }).catch(error => {
            console.log('getAllButtonsAssets: ' + error);
        });
    }

}