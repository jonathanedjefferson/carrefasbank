import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; 
import NAME_FIELD from '@salesforce/schema/User.Name';

import enviarTermoAdesao from '@salesforce/apex/CreditoPessoalController.enviarTermoAdesao';
import criarCaso from '@salesforce/apex/CreditoPessoalController.criarCaso';

export default class Bcsf_cmp_CreditoPessoalEnviarTermo extends LightningElement {

    /**************************************************
    ***           ESTADOS DE TELA                   ***
    ***************************************************/

    @track labelBotaoVoltar;
    @track labelBotaoAvancar;
    @track step01;
    @track step02;
    @track spinner;
    @track exibirBtnVoltar;

    @track opcoesEnvioEmail = [
        { label: 'Envio para e-mail cadastrado', value: 'Envio para e-mail cadastrado'},
        { label: 'Envio para novo e-mail', value: 'Envio para novo e-mail' },
    ];


    /**************************************************
    ***           DADOS                             ***
    ***************************************************/

    @api idProposta; 
    @api detalhesProposta = {};
    @api dadosCliente = {};
    @track nomeOperador;
     
    @track emailDestinatario;
    @track opcaoDeEnvioSelecionada;
    @track assunto;
    @track evento;
    @track origemCaso;
    @track canalCaso;
    @track numeroProtocolo;
    @track idCaso;
    @track dataProtocolo;

    /**************************************************
    ***           REATIVOS                          ***
    ***************************************************/

    get desativarEmailInput(){
        return this.opcaoDeEnvioSelecionada === 'Envio para e-mail cadastrado';
    }

    get desativarAvancar(){

        const origemInvalida = !this.origemCaso;
        const canalInvalido = !this.canalCaso;
        const emailInvalido = !this.verificarEmailValido(this.emailDestinatario);
        
        return (
            origemInvalida ||
            canalInvalido ||
            emailInvalido
        )
    }

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
        this.labelBotaoVoltar = 'Voltar';
        this.labelBotaoAvancar = 'Enviar';
        this.assunto = 'Crédito Pessoal';
        this.evento = 'Reenvio termo de adesão';
        this.step01 = true;
        this.emailDestinatario = this.dadosCliente.email;
        this.opcaoDeEnvioSelecionada = 'Envio para e-mail cadastrado';
        this.exibirBtnVoltar = true;
    }

    async enviarTermo(){
        
        try {
            const result = await enviarTermoAdesao({
                canal: 'Cockpit',
                cpf: this.dadosCliente.cpf,
                unidadeNegocio: this.dadosCliente.unidadeNegocio,
                idProposta: this.idProposta,
                emailCliente: this.emailDestinatario
            });
        
            if (result.statusAPI === 'OK') {
                await this.finalizarSolicitacao();
            } else {
                throw new Error('API ERRO: CP - Enviar Termo');
            }
            
        } catch (error) {
            this.showToast('Ocorreu um erro inesperado ao enviar o termo!', '', 'error');
            this.logError('enviarTermo', error);
        }

    }

    async criarProtocolo(){

        const caso = {
            "accountId": this.dadosCliente.contaPessoalId,
            "status": 'Closed',
            "assunto": 'Credito Pessoal',
            "evento": this.evento,
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
        }).catch(error => {
            this.showToast('Houve um erro ao Criar Caso', '', 'error', false);
            this.logError('criarProtocolo', error);
        });
    }

    async finalizarSolicitacao(){
        await this.criarProtocolo();
        this.step01 = false;
        this.exibirBtnVoltar = false;
        this.labelBotaoAvancar = 'Finalizar';
        this.step02 = true;
    }

    handleTipoDeEnvioEmail(event){
        const opcaoSelecionada = event.target.value;
        this.opcaoDeEnvioSelecionada =  opcaoSelecionada;

        if(opcaoSelecionada === 'Envio para e-mail cadastrado'){
            this.emailDestinatario = this.dadosCliente.email;
        }
    }
    
    handleAlterarEmailEnvio(event){

        const input = event.target;
        const email = event.target.value;

        this.emailDestinatario = email;

        if(!this.verificarEmailValido(email)){
            input.setCustomValidity('Verifique a digitação e tente novamente');
        }else{
            input.setCustomValidity('');
        }
        
    }

    handleOrigemAlterada(event){
        this.origemCaso = event.target.value;
    }

    handleCanalAlterado(event){
        this.canalCaso = event.target.value;
    }
    
    async handleAvancar(){
        if(this.step01){
            this.showSpinner();
            await this.enviarTermo();
            this.closeSpinner();
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
            console.error('componente => ', 'Bcsf_cmp_CreditoPessoalEnviarTermo'); 
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