import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BCSF_CP_MC from '@salesforce/messageChannel/BCSF_CreditoPessoal__c';

import getContaFinanceira from '@salesforce/apex/CreditoPessoalController.obterContaFinanceira';
import consultarCliente from '@salesforce/apex/CreditoPessoalController.consultarCliente';

export default class Bcsf_cmp_CreditoPessoal extends LightningElement {
    
    @api recordId;
    statusCP = null;

    @track exibirPaginaAdesao = false;
    @track exibirPaginaConsulta = false;
    @track spinner;

    @wire(MessageContext)
    messageContext;

    @track dadosCliente = {};

    connectedCallback(){
        this.carregarDados();

        this.subscription = subscribe(
            this.messageContext,
            BCSF_CP_MC,
            (message) => this.handleMessage(message)
        );
    }

    async carregarDados(){
        this.showSpinner();
        await this.obterContaFinanceira();
        await this.consultarCliente();
    }

    async obterContaFinanceira(){
        await getContaFinanceira({ 
            recordId: this.recordId 
        })
        .then(result => {
            this.dadosCliente = {
                cpf: result.CPF.replace(/\D/g, ''),
                numeroConta: result.NumeroConta,
                unidadeNegocio: result.UnidadeNegocio,
                titularConta: result.Nome,
                email: result.Email,
                contaFinanceiraId: this.recordId,
                contaPessoalId: result.AccountId,
                nomeCliente: result.Nome
            }
        })
        .catch(error => {
            this.showToast('Erro ao obter conta financeira', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
            this.logError('obterContaFinanceira', error);
        });
    }
    
    async consultarCliente(){
        await consultarCliente({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta
        })
        .then(result => {
            console.log(result);
            if(result.statusAPI === 'OK'){
                this.exibirPaginaConsulta = false;
                if(result.preAprovado == 0 || (result.cpEmAndamento && result.preAprovado == 0)){
                    this.statusCP = {
                        codigo: 1,
                        valorPreAprovado: result.preAprovado,
                        valorMinimoOferta: result.valorMinimoOferta
                    };
                    this.exibirPaginaConsulta = true;
                    this.setSelectedTab('consulta');
                } else if(!result.cartaoSemRestricao){
                    this.statusCP = {
                        codigo: 2,
                        valorPreAprovado: result.preAprovado,
                        valorMinimoOferta: result.valorMinimoOferta
                    };
                    this.exibirPaginaAdesao = true;
                    this.setSelectedTab('adesao');
                } else {
                    this.statusCP = {
                        codigo: 0,
                        valorPreAprovado: result.preAprovado,
                        valorMinimoOferta: result.valorMinimoOferta
                    };
                    this.exibirPaginaAdesao = true;
                    this.setSelectedTab('adesao');
                }
            } else {
                this.statusCP = {
                    codigo: -1,
                    valorPreAprovado: 0,
                    valorMinimoOferta: 0
                };
                this.exibirPaginaAdesao = true;
                this.setSelectedTab('adesao');
            }

            this.closeSpinner();
        })
        .catch(error => {
            this.exibirPaginaAdesao = false;
            this.exibirPaginaConsulta = false;
            this.showToast(null, 'Não foi possível carregar informacões do Crédito Pessoal', 'error', 'sticky');
            this.logError('consultarCliente', error);
            this.closeSpinner();
        });

    }

    handleTabClick(event) {
        const tabName = event.target.dataset.value;

        this.handleTableSected(event);
        if(tabName === 'consulta'){
            this.exibirPaginaConsulta = true;
            this.exibirPaginaAdesao = false;
            publish(this.messageContext, BCSF_CP_MC, {
                action: 'voltarParaInicio'
            });
        } else if(tabName === 'adesao'){
            // TODO: caso cliente não seja elegível e operador force, apresentar componente de adesao com mensagens de erro.
            this.exibirPaginaConsulta = false;
            this.exibirPaginaAdesao = true;
            if(this.statusCP.codigo != 1){
                publish(this.messageContext, BCSF_CP_MC, {
                    action: 'voltarParaInicioAdesao'
                });
            }
        }
    }

    async handleMessage(message){
        if (message.action === 'reiniciarCreditoPessoal') {
            console.log('Reiniciando consulta de cliente - CP');
            await this.carregarDados();
        }
    }

    handleTableSected(event){

        const selectedTab = event.target.dataset.tab;
        const allTabs = this.template.querySelectorAll('.slds-tabs_default__item');
        allTabs.forEach(tab => tab.classList.remove('slds-is-active'));
        event.target.parentElement.classList.add('slds-is-active');

        const allContents = this.template.querySelectorAll('[data-content]');
        allContents.forEach(content => {
            if (content.dataset.content === selectedTab) {
                content.classList.remove('slds-hide');
                content.classList.add('slds-show');
            } else {
                content.classList.remove('slds-show');
                content.classList.add('slds-hide');
            }
        });
    }

    setSelectedTab(tabName){
        const allTabs = this.template.querySelectorAll('.slds-tabs_default__item');
        allTabs.forEach(tab => tab.classList.remove('slds-is-active'));

        allTabs.forEach((tab) => {
            if(tab.children[0].dataset.value === tabName){
                tab.classList.add('slds-is-active');
            }
        });
    }

    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, mode = 'dismissable') {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'bcsf_cmp_CreditoPessoalConsulta'); 
            console.error('metodo => ', metodo); 
            console.error('erro => ', error);  
            if(error.body){
                console.error('error.body.exceptionType => ', error.body.exceptionType);
                console.error('error.body.message => ', error.body.message);
                console.error('error.body.stackTrace => ', error.body.stackTrace);
            }else{
                console.error('error.name => ' + error.name );
                console.error('error.message => ' + error.message );
                console.error('error.stack => ' + error.stack );
            }
        }
    }

}