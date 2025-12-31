import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; 
import NAME_FIELD from '@salesforce/schema/User.Name';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import enviarTermoAdesao from '@salesforce/apex/CreditoPessoalController.enviarTermoAdesao';
import criarCaso from '@salesforce/apex/CreditoPessoalController.criarCaso';

export default class Bcsf_cmp_CreditoPessoalEnviarTermo extends LightningElement {

    /**************************************************
    ***           ESTADOS DE TELA                   ***
    ***************************************************/

    @track labelBotaoVoltar;
    @track step01;
    @track step02;
    @track spinner;
    @track disableButtonProsseguir;
    @track exibirBtnVoltar = true;
    @track classBackgroundColor;


    /**************************************************
    ***           DADOS                             ***
    ***************************************************/

    @api idProposta; 
    @api dadosCliente = {};
    @api origemCaso;
    @api canalCaso;

    @track emailDestinatario;
    @track alterarEmail = false;
    @track assuntoCaso = 'Credito Pessoal';
    @track eventoCaso = 'Reenvio termo de adesão';
    @track numeroProtocolo;
    @track idCaso;
    @track dataProtocolo;
    

    /**************************************************
    ***           REATIVOS                          ***
    ***************************************************/

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    getUserRecord({ error, data }) {
        if (data) {
            this.nomeOperador = data.fields.Name.value;
        } else if (error) {
            this.logError('userRecord', error);
        }
    }

    connectedCallback(){
        this.definirValoresDefault();
    }

    definirValoresDefault(){
        this.step01 = true;
        this.emailDestinatario = this.dadosCliente.email;
        this.labelBotaoAvancar = 'Prosseguir';
        this.disableButtonProsseguir = false;
        this.classBackgroundColor = 'slds-p-horizontal_large';

        if (this.dadosCliente.unidadeNegocio == "1") {
            this.tipoConta = 'CARREFOUR';
            this.logo = LogoCarrefour;
        } else if (this.dadosCliente.unidadeNegocio  == "2") {
            this.tipoConta = 'ATACADÃO';
            this.logo = LogoAtacadao;
        }else if (this.dadosCliente.unidadeNegocio  == "6"){
            this.tipoConta = "SAM'S CLUB";
            this.logo = LogoSamsClub;
        }
    }

    async  enviarTermo() {
        console.log(JSON.stringify(this.dadosBancarios));

        await enviarTermoAdesao({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            idProposta: this.idProposta,
            emailCliente: this.emailDestinatario
        })
        .then(result => {
            console.log(JSON.stringify(result));
            if(result.statusAPI === 'OK'){
                this.criarProtocolo();
            } else {
                this.showToast('Ocorreu um erro inesperado ao enviar o termo!', '', 'error');
                this.closeSpinner();
            }
        }).catch(error => {
            this.showToast('Ocorreu um erro inesperado ao enviar o termo!', '', 'error');
            this.logError('enviarTermo', error);
            this.closeSpinner();
        });
    }


    async criarProtocolo(){

        const caso = {
            "accountId": this.dadosCliente.contaPessoalId,
            "status": 'Closed',
            "assunto": this.assuntoCaso,
            "evento": this.eventoCaso,
            "origem": this.origemCaso,
            "contaFinanceiraId": this.dadosCliente.contaFinanceiraId,
            "unidadeNegocio": this.dadosCliente.unidadeNegocio,
            "tipo": 'Execução',
            "canal": this.canalCaso,
            "prioridade": 'Medium'
        };

        await criarCaso({
            inputs: caso
        }).then((result) => {
            this.numeroProtocolo = result.CaseNumber;
            this.idCaso = result.Id;
            this.dataProtocolo = this.obterDataHora();
            this.step01 = false;
            this.step02 = true;
            this.exibirBtnVoltar = false;
            this.labelBotaoAvancar = 'Finalizar';
            this.closeSpinner();
        }).catch(error => {
            this.showToast('Houve um erro ao Criar Caso', '', 'error', false);
            this.logError('criarProtocolo', error);
            this.closeSpinner();
        });
    }

    
    handleAlterarEmailEnvio(event){
        const input = event.target;
        const email = event.target.value;

        this.emailDestinatario = email;
        let isEmailValido = this.verificarEmailValido(email);
        this.disableButtonProsseguir = !isEmailValido;
    }

    handlerAlterarEmail(event){
        if(event.target.checked){
            this.classBackgroundColor = 'background-color-grey slds-p-horizontal_large';
            this.alterarEmail = true;
            this.disableButtonProsseguir = true;
        } else {
            this.alterarEmail = false;
            this.classBackgroundColor = 'background-color-none slds-p-horizontal_large';
            this.disableButtonProsseguir = false;
        }
    }

    async handleAvancar(){
        if(this.step01){
            this.showSpinner();
            await this.enviarTermo();
        }else if(this.step02){
            this.closeQuickAction();
        }
    }

    handleVoltar(){
        if(this.step01){
            this.closeQuickAction();
        }
    }

    verificarEmailValido(email){
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        return emailRegex.test(email);
    }

    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
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

    obterDataHora() {
        const agora = new Date();
    
        const dia = String(agora.getDate()).padStart(2, '0');
        const mes = String(agora.getMonth() + 1).padStart(2, '0'); // Janeiro é 0
        const ano = agora.getFullYear();
    
        const horas = String(agora.getHours()).padStart(2, '0');
        const minutos = String(agora.getMinutes()).padStart(2, '0');
    
        return `${dia}/${mes}/${ano} - ${horas}:${minutos}`;
    }

    closeQuickAction() {   
        this.dispatchEvent(new CustomEvent('closemodal'))
    }

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'Bcsf_cmp_CreditoPessoalReenviarTermo'); 
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