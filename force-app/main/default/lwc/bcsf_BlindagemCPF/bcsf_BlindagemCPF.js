import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; 
import USER_DRT from '@salesforce/schema/User.DRT__c';

import getContaFinanceira from '@salesforce/apex/BlindagemCPFController.obterContaFinanceira';
import getContaCliente from '@salesforce/apex/BlindagemCPFController.obterContaCliente';
import criarClienteBlindado from '@salesforce/apex/BlindagemCPFController.criarCliente';

export default class Bcsf_BlindagemCPF extends LightningElement {

    @track recordId;

    @track lblBtnVoltar = 'Cancelar';
    @track lblBtnAvancar = 'Finalizar';
    @track motivosBlindagem  = [];
    @track dadosCliente = {};
    @track spinner;
    @track tipoBlindagemSelecionada = 'Blindagem Simples';
    @track fullBlindagem = false;
    @track motivo = 'INVASÃO DE CONTA';
    @track showDescMotivo;
    @track descMotivo;
    @track drtUser;


    get tiposDePindagem() {
        return [
            { label: 'Blindagem Simples', value: 'Blindagem Simples'},
            { label: 'Blindagem Full', value: 'Blindagem Full' },
        ];
    }

    motivosBlindagemSimples = [
        { label: 'INVASÃO DE CONTA', value: 'INVASÃO DE CONTA'},
        { label: 'OUTRO', value: 'OUTRO' }
    ];

    motivosBlindagemFull = [
        { label: 'FUNC BANCO', value: 'FUNC BANCO'},
        { label: 'FUNC COMEX', value: 'FUNC COMEX'},
        { label: 'FUNC DVA', value: 'FUNC DVA'}
    ]

    get desativarAvancar(){

        const tipoInvalido = !this.tipoBlindagemSelecionada;
        const motivoInvalido = !this.motivo;
        const descMotivoInvalido = this.showDescMotivo && !this.descMotivo;
 
        return (
            tipoInvalido ||
            motivoInvalido ||
            descMotivoInvalido
        );
    }


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_DRT] })
    getUserRecord({ error, data }) {
        if (data) {
            this.drtUser = data.fields.DRT__c.value;
        } else if (error) {
            this.logError('getUserRecord', error);
        }
    }

    connectedCallback(){
        this.carregarDados();
    }

    async carregarDados(){
        this.showSpinner();
        if (this.recordId.startsWith("001")) {
            await this.obterContaCliente();
        } else {
            await this.obterContaFinanceira();
        } 

        this.motivosBlindagem = this.motivosBlindagemSimples;
        this.closeSpinner();
    }

    async obterContaFinanceira(){
        await getContaFinanceira({ 
            recordId: this.recordId 
        })
        .then(result => {
            this.dadosCliente = {
                cpf: result.CPF,
                unidadeNegocio: result.UnidadeNegocio,
                titularConta: result.Nome
            }
        })
        .catch(error => {
            this.showToast('Erro ao obter conta financeira', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
            this.logError('obeterContaFinanceira', error);
        });
    }

    async obterContaCliente(){
        await getContaCliente({ 
            recordId: this.recordId 
        })
        .then(result => {
            this.dadosCliente = {
                cpf: this.formatarCPF(result.CPF__c),
                titularConta: result.Name
            }
        })
        .catch(error => {
            this.showToast('Erro ao obter conta cliente', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
            this.logError('obterContaCliente', error);
        });
    }

    async criarClienteBlindado(){

        const inputCriarClienteBlindado = {
            cpf: this.dadosCliente.cpf,
            nome: this.dadosCliente.titularConta,
            usuario: this.drtUser,
            descricao: showDescMotivo ? this.descMotivo : this.motivo,
            fullBlindagem: this.fullBlindagem,
        };

        await criarClienteBlindado({ 
            cliente: inputCriarClienteBlindado,
            canal: 'Cockpit'
        })
        .then(result => {
            this.dadosCliente = {
                cpf: result.CPF__c,
                titularConta: result.Name
            }
        })
        .catch(error => {
            this.showToast('Erro ao criar cliente blindado', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
            this.logError('criarClienteBlindado', error);
        });

    }

    tipoBlindagemHandler(event){
        const tipoBlindagem = event.target.value;
        this.tipoBlindagemSelecionada = tipoBlindagem;

        this.motivo = '';
        this.showDescMotivo = false;

        if(tipoBlindagem == 'Blindagem Simples'){
            this.motivosBlindagem = this.motivosBlindagemSimples;
            this.fullBlindagem = false;
        } else if(tipoBlindagem == 'Blindagem Full'){
            this.motivosBlindagem = this.motivosBlindagemFull;
            this.fullBlindagem = true;
        }
    }

    motivoHandler(event){
        const motivo = event.target.value;
        this.motivo = motivo;

        if(motivo == 'OUTRO'){
            this.showDescMotivo = true;
        }else{
            this.showDescMotivo = false;
        }
    }
    
    descMotivoHandler(event){
        this.descMotivo = event.target.value;
    }

    showSpinner(){
        this.spinner = true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent())
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

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'Bcsf_cmp_CreditoPessoalDadosBancarios'); 
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

    limparCPF(cpf) {
        return cpf ? cpf.replace(/\D/g, '') : '';
    }

    formatarCPF(cpf) {
        return cpf ? cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4") : '';
    }

    async handleProsseguir() {
        this.showSpinner();
    
        const inputCriarClienteBlindado = {
            cpf: this.limparCPF(this.dadosCliente.cpf),
            nome: this.dadosCliente.titularConta,
            usuario: this.drtUser,
            descricao: this.showDescMotivo ? this.descMotivo : this.motivo,
            fullBlindagem: this.fullBlindagem,
            siglaUnidadeNegocio: this.dadosCliente.unidadeNegocio
        };

        try {
            const result = await criarClienteBlindado({
                cliente: inputCriarClienteBlindado,
                canal: 'Cockpit'
            });

            if (result && result.criadoComSucesso) {
                this.showToast('Sucesso', 'Blindagem de CPF realizada!', 'success');
                this.closeQuickAction();
            } else {
                this.showToast('Erro', 'Falha ao blindar cliente. Verifique os dados ou tente novamente.', 'error');
            }
        } catch (error) {
            this.showToast('Erro', 'Ocorreu um erro inesperado.', 'error');
        } finally {
            this.closeSpinner();
        }
    }
}